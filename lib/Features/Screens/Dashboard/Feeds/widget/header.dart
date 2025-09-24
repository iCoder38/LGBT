import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class ProfileHeader extends StatelessWidget {
  final String userId;
  final String feedType; // Text / Image / Video
  final DateTime? time; // feed.createdAt as DateTime
  final VoidCallback? onMenuTap;

  const ProfileHeader({
    Key? key,
    required this.userId,
    required this.feedType,
    this.time,
    this.onMenuTap,
  }) : super(key: key);

  String _getActionText() {
    switch (feedType.toLowerCase()) {
      case "image":
        return "shared an image";
      case "video":
        return "shared a video";
      default:
        return "shared a text";
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return "";
    final diff = DateTime.now().difference(dt);

    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays == 1) return "Yesterday";
    if (diff.inDays < 7) return "${diff.inDays}d ago";

    // fallback exact date
    return "${dt.day} ${_monthName(dt.month)} ${dt.year}";
  }

  String _monthName(int m) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("LGBT_TOGO_PLUS")
          .doc("USERS")
          .collection(userId)
          .doc("PROFILE")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox(height: 40);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final displayName = data['name'] ?? 'Unknown';
        final avatarUrl = data['image'] ?? '';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl.isEmpty
                  ? Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                    )
                  : null,
            ),

            const SizedBox(width: 10),

            // Name + action + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        displayName,
                        // style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        //   fontWeight: FontWeight.w600,
                        // ),
                      ),
                      const SizedBox(width: 4),
                      customText(
                        _getActionText(),
                        11,
                        context,
                        color: AppColor().GRAY,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(time),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Menu
            GestureDetector(
              onTap: onMenuTap,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: Icon(Icons.more_horiz, size: 20),
              ),
            ),
          ],
        );
      },
    );
  }
}
