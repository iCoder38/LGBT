import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppLifecycleHandler with WidgetsBindingObserver {
  static final AppLifecycleHandler _instance = AppLifecycleHandler._internal();
  factory AppLifecycleHandler() => _instance;

  String? _userId;

  AppLifecycleHandler._internal();

  void start(String userId) {
    _userId = userId;
    WidgetsBinding.instance.addObserver(this);
    _setOnline();
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
    _setOffline();
  }

  void _setOnline() {
    if (_userId == null) return;
    FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/ONLINE_STATUS/STATUS')
        .doc(_userId)
        .set({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  void _setOffline() {
    if (_userId == null) return;
    FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/ONLINE_STATUS/STATUS')
        .doc(_userId)
        .set({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_userId == null) return;

    if (state == AppLifecycleState.resumed) {
      _setOnline();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _setOffline();
    }
  }
}
