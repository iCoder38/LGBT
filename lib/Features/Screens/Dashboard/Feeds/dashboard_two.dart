// File: lib/features/screens/dashboard/feeds/feed_screen.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/Feeds/model.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/Feeds/widget/content_action_bar.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/Feeds/widget/content_image.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/Feeds/widget/content_text.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/Feeds/widget/header.dart';
import 'package:lgbt_togo/Features/Screens/Post/post_two.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  // local feed state
  final List<Feed> _visibleFeeds = [];
  final List<Feed> _pendingFeeds = [];
  DateTime? _lastSeenTopTime;

  // subscription + notifier
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _feedsSub;
  final ValueNotifier<int> _pendingCountNotifier = ValueNotifier<int>(0);

  // user cache
  final Map<String, Map<String, String?>> _userCache = {};

  Future<Map<String, String?>> _getUserProfile(String userId) async {
    if (_userCache.containsKey(userId)) return _userCache[userId]!;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final data = doc.data();
      final result = {
        'displayName': data?['displayName'] as String? ?? 'Unknown',
        'avatarUrl': data?['avatarUrl'] as String?,
      };
      _userCache[userId] = result;
      return result;
    } catch (_) {
      final fallback = {'displayName': 'Unknown', 'avatarUrl': null};
      _userCache[userId] = fallback;
      return fallback;
    }
  }

  List<Feed> _feedsFromSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.map((d) => Feed.fromDoc(d)).toList();
  }

  DateTime? _feedCreatedAt(Feed f) => f.createdAt;

  // Build single feed card
  Widget _buildFeedCard(Feed feed, String displayName, String? avatarUrl) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(
              userId: feed.userId,
              feedType: feed.type,
              time: feed.createdAt,
              onMenuTap: () async {
                // Optimistic remove
                setState(() {
                  _visibleFeeds.removeWhere((f) => f.id == feed.id);
                });

                try {
                  await FirebaseFirestore.instance
                      .collection('LGBT_TOGO_PLUS/FEEDS/LIST')
                      .doc(feed.id)
                      .delete();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Post deleted')));
                } catch (e) {
                  // rollback if failed
                  setState(() {
                    _visibleFeeds.insert(0, feed);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            if (feed.type == "Text") ContentText(text: feed.message ?? ''),
            if (feed.imageUrls != null && feed.imageUrls!.isNotEmpty)
              ContentImage(text: feed.message, images: feed.imageUrls!),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: PostActionsBar(
                feedId: feed.id,
                onLikeResult: (feedData) {
                  print('Feed after like: $feedData');
                  callSendNotificationToToken(
                    context,
                    feedData["userId"].toString(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Start subscription: buffer new posts
  void _startFeedSubscription() {
    final query = FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/FEEDS/LIST')
        .orderBy('createdAt', descending: true);

    _feedsSub?.cancel();

    _feedsSub = query.snapshots().listen((snap) {
      final newestFeeds = _feedsFromSnapshot(snap);

      if (!mounted) return;

      if (_visibleFeeds.isEmpty) {
        setState(() {
          _visibleFeeds.addAll(newestFeeds);
          if (_visibleFeeds.isNotEmpty) {
            _lastSeenTopTime = _feedCreatedAt(_visibleFeeds.first);
          }
        });
        return;
      }

      if (_lastSeenTopTime == null) return;

      final List<Feed> newlyArrived = [];
      for (final f in newestFeeds) {
        final ct = _feedCreatedAt(f);
        if (ct == null) continue;
        if (ct.isAfter(_lastSeenTopTime!)) {
          final exists =
              _visibleFeeds.any((vf) => vf.id == f.id) ||
              _pendingFeeds.any((pf) => pf.id == f.id);
          if (!exists) newlyArrived.add(f);
        } else {
          break;
        }
      }

      if (newlyArrived.isNotEmpty) {
        _pendingFeeds.insertAll(0, newlyArrived);
        _pendingCountNotifier.value = _pendingFeeds.length;
      }
    });
  }

  // Apply new posts
  void _applyPendingAndScroll() {
    if (_pendingFeeds.isEmpty) return;

    setState(() {
      _visibleFeeds.insertAll(0, _pendingFeeds);
      final newest = _feedCreatedAt(_visibleFeeds.first);
      if (newest != null) _lastSeenTopTime = newest;
      _pendingFeeds.clear();
      _pendingCountNotifier.value = 0;
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  Future<void> _initialLoadAndSubscribe() async {
    try {
      final qs = await FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/FEEDS/LIST')
          .orderBy('createdAt', descending: true)
          .get();

      final initialFeeds = qs.docs.map((d) => Feed.fromDoc(d)).toList();

      if (!mounted) return;

      setState(() {
        _visibleFeeds.clear();
        _visibleFeeds.addAll(initialFeeds);
        if (_visibleFeeds.isNotEmpty) {
          _lastSeenTopTime = _feedCreatedAt(_visibleFeeds.first);
        }
      });
    } finally {
      _startFeedSubscription();
    }
  }

  @override
  void initState() {
    super.initState();
    _initialLoadAndSubscribe();
  }

  @override
  void dispose() {
    _feedsSub?.cancel();
    _pendingCountNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final header = ValueListenableBuilder<int>(
      valueListenable: _pendingCountNotifier,
      builder: (context, count, _) {
        if (count <= 0) return const SizedBox.shrink();
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.fiber_new),
                label: Text(
                  count == 1
                      ? '1 New Post — Tap to load'
                      : '$count New Posts — Tap to load',
                ),
                onPressed: _applyPendingAndScroll,
              ),
            ),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            onPressed: () {
              // callSendNotificationToToken(context, FIREBASE_AUTH_NAME());
              NavigationUtils.pushTo(context, MessageImageScreen());
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: _visibleFeeds.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                header,
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _visibleFeeds.length,
                    itemBuilder: (context, index) {
                      final feed = _visibleFeeds[index];
                      return FutureBuilder<Map<String, String?>>(
                        future: _getUserProfile(feed.userId),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 12.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey[300],
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        height: 16,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          final data = snap.data ?? {};
                          final displayName = data['displayName'] ?? 'Unknown';
                          final avatarUrl = data['avatarUrl'];
                          return _buildFeedCard(feed, displayName, avatarUrl);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // ===========================================================================
  // ========================= SEND NOTIFICATION ===============================
  // ===========================================================================
  Future<void> callSendNotificationToToken(context, String userId) async {
    final r = await UserService().getUser(userId);
    print(r);
    await ApiService().postRequestFornotification(
      "/send_notification_lgbt_togo.php",
      {
        "token": r!["device_token"].toString(),
        "title": "Hello",
        "body": "This is a test from postman",
        "data": {"screen": "chat"},
      },
    );
  }
}
