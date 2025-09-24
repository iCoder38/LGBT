import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/Feeds/model.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/Feeds/widget/content_action_bar.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/Feeds/widget/content_image.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/Feeds/widget/content_text.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/Feeds/widget/header.dart';
import 'package:lgbt_togo/Features/Screens/Post/post_two.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

String humanReadableTime(DateTime? dt) {
  if (dt == null) return '';
  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${dt.day}/${dt.month}/${dt.year}';
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Future<List<Feed>> _loadFeeds() async {
    final qs = await FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/FEEDS/LIST')
        .orderBy('createdAt', descending: true)
        .get();
    return qs.docs.map((d) => Feed.fromDoc(d)).toList();
  }

  // Simple cache for user profile info to avoid repeated reads
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
        'displayName': data != null && data['displayName'] != null
            ? data['displayName'] as String
            : 'Unknown',
        'avatarUrl': data != null && data['avatarUrl'] != null
            ? data['avatarUrl'] as String
            : null,
      };
      _userCache[userId] = result;
      return result;
    } catch (_) {
      final fallback = {'displayName': 'Unknown', 'avatarUrl': null};
      _userCache[userId] = fallback;
      return fallback;
    }
  }

  // Widget _buildImagePreview(List<String> images) {
  //   final count = images.length;
  //   if (count == 1) {
  //     return AspectRatio(
  //       aspectRatio: 16 / 9,
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(10),
  //         child: Image.network(images[0], fit: BoxFit.cover),
  //       ),
  //     );
  //   }

  //   final showCount = count > 4 ? 4 : count;
  //   return SizedBox(
  //     height: 180,
  //     child: GridView.builder(
  //       physics: const NeverScrollableScrollPhysics(),
  //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 2,
  //         mainAxisSpacing: 6,
  //         crossAxisSpacing: 6,
  //       ),
  //       itemCount: showCount,
  //       itemBuilder: (context, index) => ClipRRect(
  //         borderRadius: BorderRadius.circular(8),
  //         child: Image.network(images[index], fit: BoxFit.cover),
  //       ),
  //     ),
  //   );
  // }

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
              userId: feed.userId.toString(),
              feedType: feed.type,
              time: feed.createdAt, // DateTime hai
            ),
            const SizedBox(height: 8),
            if (feed.type == "Text") ContentText(text: feed.message!),
            if (feed.imageUrls != null && feed.imageUrls!.isNotEmpty)
              ContentImage(text: feed.message, images: feed.imageUrls!),
            SizedBox(height: 8),
            PostActionsBar(
              likesCount: 12,
              commentsCount: 3,
              sharesCount: 1,
              initiallyLiked: false,
              onLike: (newLiked) async {
                // await api.toggleLike(postId, newLiked);
              },
              // onComment: () => openCommentSheet(),
              // onShare: () => sharePost(),
            ),
          ],
        ),
      ),
    );
  }

  // static String _subtitleForType(String type) {
  //   switch (type.toLowerCase()) {
  //     case 'image':
  //       return 'Shared an image';
  //     case 'video':
  //       return 'Shared a video';
  //     default:
  //       return 'Shared a text';
  //   }
  // }

  void _showMenu(Feed feed) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            onPressed: () {
              NavigationUtils.pushTo(context, MessageImageScreen());
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: FutureBuilder<List<Feed>>(
        future: _loadFeeds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final feeds = snapshot.data ?? [];
          if (feeds.isEmpty) return const Center(child: Text('No feeds yet.'));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: feeds.length,
            itemBuilder: (context, index) {
              final feed = feeds[index];
              return FutureBuilder<Map<String, String?>>(
                future: _getUserProfile(feed.userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
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
                            const SizedBox(height: 8),
                            Container(height: 12, color: Colors.grey[200]),
                          ],
                        ),
                      ),
                    );
                  }

                  final data = userSnapshot.data ?? {};
                  final displayName = data['displayName'] ?? 'Unknown';
                  final avatarUrl = data['avatarUrl'];

                  return _buildFeedCard(feed, displayName, avatarUrl);
                },
              );
            },
          );
        },
      ),
    );
  }
}
