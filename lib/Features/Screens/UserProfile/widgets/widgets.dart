// widgets/profile_actions.dart
// import 'package:flutter/material.dart';
import 'package:lgbt_togo/Features/Screens/Chat/chat.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

/// Small badge that shows "Friends"
class FriendStatusButton extends StatelessWidget {
  final EdgeInsets padding;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final String title;
  final Color textColor;

  const FriendStatusButton({
    super.key,
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = 4,
    this.borderColor,
    this.backgroundColor,
    required this.title,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor ?? AppColor().kBlack),
        ),
        child: Center(
          child: customText(
            title,
            12,
            context,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class AddFriendBadge extends StatelessWidget {
  final EdgeInsets padding;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final String text;

  const AddFriendBadge({
    super.key,
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = 4,
    this.borderColor,
    this.backgroundColor,
    this.text = "Add Friends",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        // width: 120,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColor().PURPLE,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor ?? AppColor().kBlack),
        ),
        child: Center(
          child: customText(
            text,
            12,
            context,
            color: AppColor().kWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Reusable Thumbs Up Floating Action Button widget.
class ThumbsUpFab extends StatefulWidget {
  final bool initialIsLikedByMe;
  final bool isLikedByOther;
  final Map<String, dynamic>? friendData;
  final Map<String, dynamic>? userData;
  final Future<void> Function(BuildContext) onApiCall;
  final VoidCallback onStartMessage;

  const ThumbsUpFab({
    super.key,
    required this.initialIsLikedByMe,
    required this.isLikedByOther,
    required this.friendData,
    required this.userData,
    required this.onApiCall,
    required this.onStartMessage,
  });

  @override
  State<ThumbsUpFab> createState() => _ThumbsUpFabState();
}

class _ThumbsUpFabState extends State<ThumbsUpFab> {
  late bool isLikedByMe;

  @override
  void initState() {
    super.initState();
    isLikedByMe = widget.initialIsLikedByMe;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      child: Icon(
        Icons.thumb_up_alt_rounded,
        color: isLikedByMe ? AppColor().RED : AppColor().GRAY,
      ),
      onPressed: () {
        GlobalUtils().customLog("👍 Thumbs up tapped");

        // 🔴 turant UI toggle
        if (!isLikedByMe) {
          setState(() => isLikedByMe = true);
        }

        // 👥 Agar dusra banda already like kar chuka hai → popup
        if (widget.isLikedByOther) {
          AlertsUtils().showMatchPopup(
            context: context,
            user1Name: "You",
            user2Name: widget.friendData?["firstName"]?.toString() ?? '',
            user1Image: widget.userData?["image"]?.toString() ?? '',
            user2Image: widget.friendData?["image"]?.toString() ?? '',
            onStartMessage: widget.onStartMessage,
          );
        }

        // 🔥 API background mein
        widget.onApiCall(context);
      },
    );
  }
}
