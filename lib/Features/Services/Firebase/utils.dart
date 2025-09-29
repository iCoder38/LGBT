import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class PremiumPoints {
  static int postPoints = 50;
  static int friendRequestPoints = 0;
  static int photoUploadPoints = 0;
  static int directMessage = 0;
}

Future<bool> svalidateBeforePost(BuildContext context, [int type = 1]) async {
  // type: 1 = post, 2 = friend request, 3 = direct message (DM)
  final r = await UserService().getUser(FIREBASE_AUTH_UID());
  GlobalUtils().customLog(r);

  if (r == null) return false;

  // Read the levels map from possible keys (robust against previous shapes)
  final Map<String, dynamic> levelsMap =
      (r['levels'] ?? r['level_points'] ?? r['level'] ?? r['level_info'] ?? {})
          as Map<String, dynamic>;

  int parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  final String userLevel = (levelsMap['level'] ?? levelsMap['lvl'] ?? 0)
      .toString();
  final int points = parseInt(levelsMap['points'] ?? levelsMap['point'] ?? 0);
  final int postCounter = parseInt(levelsMap['post'] ?? levelsMap['posts']);
  final int friendReqCounter = parseInt(
    levelsMap['friend_request'] ??
        levelsMap['friend_requests'] ??
        levelsMap['friend_request_sent'],
  );
  final int dmCounter = parseInt(
    levelsMap['direct_message'] ??
        levelsMap['dm'] ??
        levelsMap['messages_sent'],
  );

  void showLimitMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColor().GREEN),
    );
  }

  // If user is not level 1, allow all actions by default
  if (userLevel != "1") {
    GlobalUtils().customLog(
      "User not Level 1 (level=$userLevel) — allowing action type $type",
    );
    return true;
  }

  // If user is Level 1, check points first:
  // Only apply the per-action counters if points < 10000.
  if (points >= 10000) {
    // When points already reached 10,000, user must upgrade to move to Level 2.
    final actionName = (type == 1)
        ? "posting"
        : (type == 2)
        ? "sending friend requests"
        : (type == 3)
        ? "sending messages"
        : "this action";
    final message =
        "Your points have reached 10,000. To continue $actionName and move to Level 2 you must upgrade.";
    GlobalUtils().customLog("Level 1 but points >= 10000: blocking — $message");
    showLimitMessage(message);
    return false;
  }

  // Points < 10000 — apply Level 1 per-action counters
  switch (type) {
    case 1: // posting
      if (postCounter < 200) {
        GlobalUtils().customLog("Level 1 post allowed ($postCounter/200)");
        return true;
      } else {
        showLimitMessage(
          "Your post limit is 200 because you are in Level 1. To post more, move to an upper level.",
        );
        return false;
      }

    case 2: // friend requests
      if (friendReqCounter < 50) {
        GlobalUtils().customLog(
          "Level 1 friend request allowed ($friendReqCounter/50)",
        );
        return true;
      } else {
        showLimitMessage(
          "Your friend request limit is 50 in Level 1. Upgrade to send more requests.",
        );
        return false;
      }

    case 3: // direct messages
      if (dmCounter < 10) {
        GlobalUtils().customLog("Level 1 DM allowed ($dmCounter/10)");
        return true;
      } else {
        showLimitMessage(
          "Your DM limit is 10 in Level 1. Upgrade your level to send more messages.",
        );
        return false;
      }

    default:
      GlobalUtils().customLog(
        "Unknown validation type: $type — allowing by default.",
      );
      return true;
  }
}
