import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

// ====================== SERVICE: USER ========================================
// =============================================================================

class UserService {
  final _fs = FirestoreService();

  Future<void> createUser(String uid, Map<String, dynamic> data) async {
    await _fs.set(FirestorePaths.user(uid), data);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _fs.update(FirestorePaths.user(uid), data);
  }

  Future<void> deleteUser(String uid) async {
    await _fs.delete(FirestorePaths.user(uid));
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    return await _fs.get(FirestorePaths.user(uid));
  }

  /// Add new fields to the existing user document without overwriting existing fields.
  Future<void> addUserFields(String uid, Map<String, dynamic> newFields) async {
    await _fs.update(FirestorePaths.user(uid), newFields);
  }
}

// settings

class SettingsService {
  final _fs = FirestoreService();

  // Save or overwrite settings document
  Future<void> setSettings(String uid, Map<String, dynamic> data) async {
    await _fs.set(FirestorePaths.settings(uid), data);
  }

  // Update part of the settings document
  Future<void> updateSettings(String uid, Map<String, dynamic> data) async {
    await _fs.update(FirestorePaths.settings(uid), data);
  }

  // Get full settings document
  Future<Map<String, dynamic>?> getSettings(String uid) async {
    return await _fs.get(FirestorePaths.settings(uid));
  }

  // Delete settings document
  Future<void> deleteSettings(String uid) async {
    await _fs.delete(FirestorePaths.settings(uid));
  }

  // ✅ Generic method to get any settings section
  Future<Map<String, dynamic>?> getSettingsSection(
    String uid,
    String sectionKey,
  ) async {
    final fullSettings = await getSettings(uid);
    final section = fullSettings?[sectionKey];
    if (section is Map<String, dynamic>) {
      return section;
    }
    return null;
  }
}

// Usage example:
// await SettingsService().setSettings(uid, {'language': 'en', 'notificationsEnabled': true});
