import 'package:flutter/material.dart';

/// File: lib/widgets/content_likeCommentShare.dart
/// Professional widget: PostActionsBar
/// - Shows Like / Comment / Share buttons with counts
/// - Exposes callbacks: onLike, onComment, onShare
/// - Manages local like state with simple animation
/// - Designed to be easily reusable in feed cards

class PostActionsBar extends StatefulWidget {
  /// Number of likes (initial)
  final int likesCount;

  /// Number of comments (initial)
  final int commentsCount;

  /// Number of shares (initial)
  final int sharesCount;

  /// Whether the current user already liked this post
  final bool initiallyLiked;

  /// Callbacks
  final Future<void> Function(bool newLikedState)?
  onLike; // provides new like state
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostActionsBar({
    Key? key,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.initiallyLiked = false,
    this.onLike,
    this.onComment,
    this.onShare,
  }) : super(key: key);

  @override
  State<PostActionsBar> createState() => _PostActionsBarState();
}

class _PostActionsBarState extends State<PostActionsBar>
    with SingleTickerProviderStateMixin {
  late int _likes;
  late int _comments;
  late int _shares;
  late bool _isLiked;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _likes = widget.likesCount;
    _comments = widget.commentsCount;
    _shares = widget.sharesCount;
    _isLiked = widget.initiallyLiked;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLikeTap() async {
    final newState = !_isLiked;

    // optimistic UI update
    setState(() {
      _isLiked = newState;
      _likes += newState ? 1 : -1;
    });

    // simple animation when liking
    if (newState) {
      _animController.forward().then((_) => _animController.reverse());
    }

    // call remote handler if provided
    if (widget.onLike != null) {
      try {
        await widget.onLike!(newState);
      } catch (e) {
        // rollback on error
        setState(() {
          _isLiked = !newState;
          _likes += newState ? -1 : 1;
        });
      }
    }
  }

  void _handleCommentTap() {
    widget.onComment?.call();
  }

  void _handleShareTap() {
    widget.onShare?.call();
    // optimistic increment, you might prefer to increment after callback
    setState(() => _shares += 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Like button + count
        _ActionItem(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.redAccent : theme.iconTheme.color,
              ),
              onPressed: _handleLikeTap,
              tooltip: _isLiked ? 'Unlike' : 'Like',
            ),
          ),
          label: '$_likes',
        ),

        // Comment button + count
        _ActionItem(
          child: IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.mode_comment_outlined),
            onPressed: _handleCommentTap,
            tooltip: 'Comment',
          ),
          label: '$_comments',
        ),

        // Share button + count
        _ActionItem(
          child: IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.send_outlined),
            onPressed: _handleShareTap,
            tooltip: 'Share',
          ),
          label: '$_shares',
        ),
      ],
    );
  }
}

/// Small helper that displays an action icon above a label
class _ActionItem extends StatelessWidget {
  final Widget child; // typically IconButton
  final String label;

  const _ActionItem({Key? key, required this.child, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [child, const SizedBox(width: 4), Text(label)]);
  }
}

/// Example usage:
/// PostActionsBar(
///   likesCount: 12,
///   commentsCount: 3,
///   sharesCount: 1,
///   initiallyLiked: false,
///   onLike: (newLiked) async { await api.toggleLike(postId, newLiked); },
///   onComment: () => openCommentSheet(),
///   onShare: () => sharePost(),
/// )
