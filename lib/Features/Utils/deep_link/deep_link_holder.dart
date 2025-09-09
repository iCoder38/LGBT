/// Simple holder to coordinate a pending deep-link across startup code.
/// This file is safe to import from both main.dart and splash.dart.
class DeepLinkHolder {
  /// The pending post id parsed from a deep link (or null).
  static String? pendingPostId;
}
