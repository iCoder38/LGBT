import 'package:flutter/material.dart';

class PremiumDialog {
  /// Show reusable "Get Premium" dialog
  /// Returns:
  /// - true => User tapped "Get Premium"
  /// - false => User tapped "OK"
  /// - null => Dialog dismissed by system
  static Future<bool?> show({
    required BuildContext context,
    required String message,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // outside/back press disable
      builder: (context) {
        return AlertDialog(
          title: const Text("Get Premium"),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("OK"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Get Premium"),
            ),
          ],
        );
      },
    );
  }
}
