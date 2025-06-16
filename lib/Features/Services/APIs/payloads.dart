import 'dart:io';

class ApiPayloads {
  static Map<String, dynamic> CommonPayloadWithUserId(String userId) {
    return {'userId': userId};
  }

  // ========================= OUR MISISON ======================================
  static Map<String, dynamic> PayloadOurMission({required String action}) {
    return {'action': action};
  }

  // ========================= FRIENDS LIST ======================================
  static Map<String, dynamic> PayloadFriends({
    required String action,
    required String userId,
  }) {
    return {'action': action, 'userId': userId};
  }

  // ========================= CHECK USER ======================================
  static Map<String, dynamic> CheckUserPayload({
    required String action,
    required String userId,
  }) {
    return {'action': action, 'userId': userId};
  }

  // ========================= CHECK OTHER USER ======================================
  static Map<String, dynamic> PayloadOtherUserCheck({
    required String action,
    required String userId,
    required String other_profile_Id,
  }) {
    return {
      'action': action,
      'userId': userId,
      'other_profile_Id': other_profile_Id,
    };
  }

  // ========================= PROFILE LIKE ====================================
  static Map<String, dynamic> PayloadProfileLike({
    required String action,
    required String userId,
    required String profileId,
    required String status,
  }) {
    return {
      'action': action,
      'userId': userId,
      'profileId': profileId,
      'status': status,
    };
  }

  // ========================= SEND REQUEST ====================================
  static Map<String, dynamic> PayloadSendRequest({
    required String action,
    required String senderId,
    required String receiverId,
    required String status,
  }) {
    return {
      'action': action,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
    };
  }

  /*
action: login
email:
password:
*/
  // ========================= LOGIN ======================================
  static Map<String, dynamic> PayloadLogin({
    required String action,
    required String email,
    required String password,
  }) {
    return {'action': action, 'email': email, 'password': password};
  }

  // ========================= FORGOT PASSWORD =================================
  static Map<String, dynamic> PayloadForgotPassword({
    required String action,
    required String email,
  }) {
    return {'action': action, 'email': email};
  }

  // ========================= DSAHBOARD ======================================
  static Map<String, dynamic> PayloadFeeds({
    required String action,
    required String userId,
    required String type,
    required int pageNo,
  }) {
    return {'action': action, 'userId': userId, 'type': type, "pageNo": pageNo};
  }

  // ========================= FRIENDS FEEDS ======================================
  static Map<String, dynamic> PayloadFriendsFeeds({
    required String action,
    required String userId,
    required String friend_user_id,
    required int pageNo,
  }) {
    return {
      'action': action,
      'userId': userId,
      'friend_user_id': friend_user_id,
      "pageNo": pageNo,
    };
  }

  // ========================= COMMENT ======================================
  static Map<String, dynamic> PayloadCommentList({
    required String action,
    required String userId,
    required String postId,
  }) {
    return {'action': action, 'userId': userId, 'postId': postId};
  }

  static Map<String, dynamic> PayloadCommentPosts({
    required String action,
    required String userId,
    required String postId,
    required String comment,
  }) {
    return {
      'action': action,
      'userId': userId,
      'postId': postId,
      'comment': comment,
    };
  }

  static Map<String, dynamic> PayloadCommentDelete({
    required String action,
    required String userId,
    required String commentId,
  }) {
    return {'action': action, 'userId': userId, 'commentId': commentId};
  }

  // ========================= LIKE UNLIKE ======================================
  static Map<String, dynamic> PayloadLikeUnlike({
    required String action,
    required String userId,
    required String postId,
    required String status,
  }) {
    return {
      'action': action,
      'userId': userId,
      'postId': postId,
      'status': status,
    };
  }

  // ========================= DELETE ======================================
  static Map<String, dynamic> PayloadDeletePost({
    required String action,
    required String userId,
    required String postId,
  }) {
    return {'action': action, 'userId': userId, 'postId': postId};
  }

  /*action: postlike
userId:
postId:
status: 0/1/2  1=Like, 2=dislike*/

  /*
action:registration
//email:abx@mailinator.com
//firstName:kumar
//contactNumber:1986543218
//password:1234568
//dob:2000-12-26
//bio:HWY i am using
//gender:Male
//interests:Male
//story:YES
//why_are_u_here:noting
//thought_of_day:Good
//cityname:NOIDA
 */
  // ========================= REGISTRATION ====================================
  static Map<String, dynamic> PayloadRegistration({
    required String action,
    required String email,
    required String firstName,
    required String contactNumber,
    required String password,
  }) {
    return {
      'action': action,
      'email': email,
      'firstName': firstName,
      'contactNumber': contactNumber,
      'password': password,
    };
  }

  /*
action:registration
//email:abx@mailinator.com
//firstName:kumar
//contactNumber:1986543218
//password:1234568
//dob:2000-12-26
//bio:HWY i am using
//gender:Male
//interests:Male
//story:YES
//why_are_u_here:noting
//thought_of_day:Good
//cityname:NOIDA
// */
  // ========================= COMPLETE PROFILE ====================================
  static Map<String, dynamic> PayloadCompleteprofile({
    required String action,
    required String userId,
    required String story,
    required String why_are_u_here,
    required String thought_of_day,
    required String bio,
    required String cityname,
    required String gender,
    required String dob,
    required String interest,
  }) {
    return {
      'action': action,
      'userId': userId,
      'story': story,
      'why_are_u_here': why_are_u_here,
      'thought_of_day': thought_of_day,
      'bio': bio,
      'cityname': cityname,
      'gender': gender,
      'dob': dob,
      'interests': interest,
      'device': Platform.isIOS ? 'ios' : 'android',
    };
  }
}
