import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class PremiumPoints {
  static int postPoints = 50;
  static int friendRequestPoints = 0;
  static int photoUploadPoints = 0;
}

Future<bool> svalidateBeforePost(context) async {
  /// Get user details
  final r = await UserService().getUser(FIREBASE_AUTH_UID());
  GlobalUtils().customLog(r);

  /// Check for null safety
  if (r == null || r["level_points"] == null) {
    return false;
  }

  final userLevel = r["level_points"]["level"].toString();
  final userPoints = r["level_points"]["points"] ?? 0;
  final postCounter = r["counters"]["post"] ?? 0;

  if (userLevel == "1") {
    GlobalUtils().customLog("Yes, You are in Level 1");

    if (userPoints < 10000 && postCounter < 200) {
      // if (userPoints < 800 && postCounter < 1) {
      GlobalUtils().customLog(
        "I am in Level 1 and my points are less than 10000 and my post counter is also less than 200",
      );
      return true; // ✅ allowed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Your post limit is 200 only because you are in level 1. "
            "To post more you have to move to upper level",
          ),
          backgroundColor: AppColor().GREEN,
        ),
      );
      return false; // ❌ not allowed
    }
  } else {
    return true;
  }
}

Future<bool> svalidateBeforeFriendRequest(context) async {
  /// Get user details
  final r = await UserService().getUser(FIREBASE_AUTH_UID());
  GlobalUtils().customLog(r);

  /// Check for null safety
  if (r == null || r["level_points"] == null) {
    return false;
  }

  final userLevel = r["level_points"]["level"].toString();
  final userPoints = r["level_points"]["points"] ?? 0;
  final postCounter = r["counters"]["friend_request"] ?? 0;

  if (userLevel == "1") {
    GlobalUtils().customLog("Yes, You are in Level 1");

    if (userPoints < 10000 && postCounter < 50) {
      // if (userPoints < 800 && postCounter < 1) {
      GlobalUtils().customLog(
        "I am in Level 1 and my points are less than 10000 and my post counter is also less than 200",
      );
      return true; // ✅ allowed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Your post limit is 200 only because you are in level 1. "
            "To post more you have to move to upper level",
          ),
          backgroundColor: AppColor().GREEN,
        ),
      );
      return false; // ❌ not allowed
    }
  } else {
    return true;
  }
}
