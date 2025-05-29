class UserSettingsPayload {
  static Map<String, dynamic> initialGrouped({
    String privacyValue = 'friends',
    bool trueValue = true,
  }) {
    return {
      'privacy': {
        'profile': privacyValue,
        'post': privacyValue,
        'friends': privacyValue,
        'profile_picture': privacyValue,
      },
      'notifications': {
        'new_friend_request': trueValue,
        'accept_reject_request': trueValue,
        'chat_message': trueValue,
        'like_profile': trueValue,
      },
      'email': {
        'new_friend_request': trueValue,
        'accept_reject_request': trueValue,
        'two_step_auth_for_deletion': trueValue,
      },
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
