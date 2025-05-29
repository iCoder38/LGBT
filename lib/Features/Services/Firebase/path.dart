class FirestorePaths {
  static String user(String uid) => "LGBT_TOGO_PLUS/USERS/$uid/PROFILE";
  static String settings(String uid) => "LGBT_TOGO_PLUS/USERS/$uid/SETTINGS";
  // 'users/$uid';
  static String chatMessages(String chatId) => 'chats/$chatId/messages';
}
