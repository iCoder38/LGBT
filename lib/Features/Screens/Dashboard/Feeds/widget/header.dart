// File: lib/widgets/content_profile_header.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class ProfileHeader extends StatelessWidget {
  final String userId;
  final String? feedType; // optional: Text / Image / Video or null
  final DateTime? time; // feed.createdAt as DateTime
  final VoidCallback? onMenuTap;

  /// If provided, this widget is used as the menu icon. If null, a default icon is used.
  final Widget? menuIcon;

  /// If false, the menu area is hidden entirely.
  final bool showMenu;

  /// If true and onMenuTap is null, tapping the menu will call Navigator.pop(context).
  final bool menuDoesPop;

  const ProfileHeader({
    Key? key,
    required this.userId,
    this.feedType,
    this.time,
    this.onMenuTap,
    this.menuIcon,
    this.showMenu = true,
    this.menuDoesPop = false,
  }) : super(key: key);

  /// Returns empty string when feedType is null/empty so caller can hide it.
  String _getActionText() {
    if (feedType == null) return "";
    final t = feedType!.trim().toLowerCase();
    if (t.isEmpty) return "";
    switch (t) {
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
    final actionText = _getActionText();

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
        final displayName = (data['name'] ?? 'Unknown') as String;
        final avatarUrl = (data['image'] ?? '') as String;

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
                      Flexible(
                        child: Text(
                          displayName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // only show actionText when non-empty
                      if (actionText.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        customText(
                          actionText,
                          11,
                          context,
                          color: AppColor().GRAY,
                        ),
                      ],
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

            // Menu area (hidden if showMenu == false)
            if (showMenu)
              GestureDetector(
                onTap: () {
                  if (onMenuTap != null) {
                    onMenuTap!();
                  } else if (menuDoesPop) {
                    // default fallback behavior if caller wants menu to act as a back/close
                    if (Navigator.canPop(context)) Navigator.of(context).pop();
                  } else {
                    // no-op (menu is visible but no action specified)
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: menuIcon ?? const Icon(Icons.more_horiz, size: 20),
                ),
              ),
          ],
        );
      },
    );
  }
}
