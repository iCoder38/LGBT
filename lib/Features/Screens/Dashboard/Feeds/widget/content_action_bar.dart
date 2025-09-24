// File: lib/widgets/content_likeCommentShare.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// PostActionsBar with per-user like tracking + optimistic instant UI
/// Now includes optional callbacks:
///  - onLikeResult(Map<String,dynamic>) called ONLY after a **like** completes
///  - onCommentPressed(String feedId) called when comment icon tapped
///  - onSharePressed(String feedId) called when share icon tapped
class PostActionsBar extends StatefulWidget {
  final String feedId;
  final bool showLikeIcon;

  /// Called after like transaction completes successfully (only on LIKE).
  /// Receives the feed document data as Map<String, dynamic>.
  final void Function(Map<String, dynamic> feedData)? onLikeResult;

  /// Called when user taps comment icon.
  /// Receives the feedId so parent can open comment screen.
  final void Function(String feedId)? onCommentPressed;

  /// Called when user taps share icon. Called after the share increment is attempted.
  /// Receives the feedId so parent can perform share flow.
  final void Function(String feedId)? onSharePressed;

  const PostActionsBar({
    Key? key,
    required this.feedId,
    this.showLikeIcon = true,
    this.onLikeResult,
    this.onCommentPressed,
    this.onSharePressed,
  }) : super(key: key);

  @override
  State<PostActionsBar> createState() => _PostActionsBarState();
}

class _PostActionsBarState extends State<PostActionsBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isProcessing = false;

  /// optimisticLocal: when user taps, we set these immediately so UI shows instant change
  bool?
  _optimisticUserLiked; // null = no optimistic change, true/false = optimistic override
  int _optimisticDelta = 0; // +1 or -1 temporarily applied to likesCount

  DocumentReference<Map<String, dynamic>> get _feedRef =>
      _db.collection('LGBT_TOGO_PLUS/FEEDS/LIST').doc(widget.feedId);
  DocumentReference<Map<String, dynamic>> _likeRef(String uid) =>
      _feedRef.collection('likes').doc(uid);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int _coerceToInt(Object? value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Toggle like in a transaction (server-side)
  Future<void> _toggleLikeTransaction(String uid) async {
    final feedRef = _feedRef;
    final likeRef = _likeRef(uid);

    await _db.runTransaction((txn) async {
      final likeSnap = await txn.get(likeRef);
      final feedSnap = await txn.get(feedRef);

      final currentCount = _coerceToInt(feedSnap.data()?['likesCount']);

      if (likeSnap.exists) {
        // unlike
        txn.delete(likeRef);
        txn.update(feedRef, {'likesCount': FieldValue.increment(-1)});
      } else {
        // like
        txn.set(likeRef, {
          'createdAt': FieldValue.serverTimestamp(),
          'userId': uid,
        });
        txn.update(feedRef, {'likesCount': FieldValue.increment(1)});
      }
    });
  }

  /// Try to increment share count on server, and call share callback afterwards.
  Future<void> _incrementShareOnServer() async {
    try {
      await _feedRef.update({'sharesCount': FieldValue.increment(1)});
      // notify parent that share was pressed (after server op)
      if (widget.onSharePressed != null) widget.onSharePressed!(widget.feedId);
    } catch (e) {
      debugPrint('incrementShare error: $e');
      // still call callback so UI can open share sheet even if increment failed
      if (widget.onSharePressed != null) widget.onSharePressed!(widget.feedId);
    }
  }

  /// Fetch feed doc and return as `Map<String, dynamic>`. Safe fallback to empty map.
  Future<Map<String, dynamic>> _fetchFeedData() async {
    try {
      final snap = await _feedRef.get();
      return snap.data() ?? <String, dynamic>{};
    } catch (e) {
      debugPrint('Failed to fetch feed data: $e');
      return <String, dynamic>{};
    }
  }

  // Called when user taps heart. Immediate UI change, then transaction.
  void _onLikePressed(
    bool currentlyUserLiked,
    int serverLikes,
    String uid,
  ) async {
    if (_isProcessing) return;

    final newUserLiked = !currentlyUserLiked;

    // immediate local optimistic update
    setState(() {
      _optimisticUserLiked = newUserLiked;
      _optimisticDelta = newUserLiked ? 1 : -1;
    });

    // small animation on like
    if (newUserLiked) {
      _animController.forward().then((_) {
        if (mounted) _animController.reverse();
      });
    }

    _isProcessing = true;
    try {
      await _toggleLikeTransaction(uid);

      // success: server will push authoritative state; clear optimistic markers
      if (mounted) {
        setState(() {
          _optimisticUserLiked = null;
          _optimisticDelta = 0;
        });
      }

      // --- CALL CALLBACK ONLY WHEN NEW ACTION IS A LIKE ---
      if (newUserLiked && widget.onLikeResult != null) {
        final feedData = await _fetchFeedData();
        try {
          widget.onLikeResult!(feedData);
        } catch (e) {
          debugPrint('onLikeResult callback threw: $e');
        }
      }
    } catch (e) {
      // rollback optimistic UI on error
      if (mounted) {
        setState(() {
          _optimisticUserLiked = null;
          _optimisticDelta = 0;
        });
      }
      debugPrint('toggle like failed: $e');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _auth.currentUser;

    // Feed stream for counts
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _feedRef.snapshots(),
      builder: (context, feedSnap) {
        if (feedSnap.hasError) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ActionItem(child: Icon(Icons.error), label: '—'),
              _ActionItem(child: Icon(Icons.mode_comment_outlined), label: '—'),
              _ActionItem(child: Icon(Icons.send_outlined), label: '—'),
            ],
          );
        }

        if (!feedSnap.hasData) {
          return const SizedBox(
            height: 44,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final feedData = feedSnap.data!.data() ?? <String, dynamic>{};
        final serverLikes = _coerceToInt(feedData['likesCount']);

        // SAFE comments count handling:
        // Prefer explicit 'commentsCount' field if present,
        // otherwise fallback to 'total_comments', otherwise 0.
        final commentsCount = feedData.containsKey('commentsCount')
            ? _coerceToInt(feedData['commentsCount'])
            : feedData.containsKey('total_comments')
            ? _coerceToInt(feedData['total_comments'])
            : 0;

        final sharesCount = _coerceToInt(feedData['sharesCount']);

        // Apply optimistic delta to displayed likes
        final displayedLikes = (serverLikes + _optimisticDelta).clamp(
          0,
          1 << 60,
        );

        // If user not signed in show disabled like button (or prompt to login)
        if (user == null) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActionItem(
                label: '$displayedLikes',
                child: widget.showLikeIcon
                    ? ScaleTransition(
                        scale: _scaleAnim,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.favorite_border,
                            color: theme.iconTheme.color,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please sign in to like posts'),
                              ),
                            );
                          },
                          tooltip: 'Sign in to like',
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              _ActionItem(
                label: '$commentsCount',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.mode_comment_outlined),
                  onPressed: () {
                    if (widget.onCommentPressed != null)
                      widget.onCommentPressed!(widget.feedId);
                  },
                ),
              ),
              _ActionItem(
                label: '$sharesCount',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.send_outlined),
                  onPressed: _incrementShareOnServer,
                ),
              ),
            ],
          );
        }

        // If user signed in, listen to their like doc to know authoritative userLiked
        final likeDocStream = _likeRef(user.uid).snapshots();

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: likeDocStream,
          builder: (context, likeSnap) {
            final serverUserLiked = likeSnap.hasData && likeSnap.data!.exists;

            // If optimistic override exists, prefer it for UI immediate feedback, else server value
            final userLikedForUI = _optimisticUserLiked ?? serverUserLiked;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LIKE
                _ActionItem(
                  label: '$displayedLikes',
                  child: widget.showLikeIcon
                      ? ScaleTransition(
                          scale: _scaleAnim,
                          child: IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              userLikedForUI
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: userLikedForUI
                                  ? Colors.redAccent
                                  : theme.iconTheme.color,
                            ),
                            onPressed: () => _onLikePressed(
                              serverUserLiked,
                              serverLikes,
                              user.uid,
                            ),
                            tooltip: userLikedForUI ? 'Unlike' : 'Like',
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // COMMENT
                _ActionItem(
                  label: '$commentsCount',
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.mode_comment_outlined),
                    onPressed: () {
                      // bubble up to parent so it can open comment UI
                      if (widget.onCommentPressed != null)
                        widget.onCommentPressed!(widget.feedId);
                    },
                  ),
                ),

                // SHARE
                _ActionItem(
                  label: '$sharesCount',
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.send_outlined),
                    onPressed: _incrementShareOnServer,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ActionItem extends StatelessWidget {
  final Widget child;
  final String label;

  const _ActionItem({Key? key, required this.child, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        child,
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
