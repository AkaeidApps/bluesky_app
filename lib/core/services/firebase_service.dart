import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:bluesky_app/app/config/firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _isInitialized = true;
      if (kDebugMode) {
        print('[FirebaseService] Successfully connected to Firebase.');
      }
    } catch (e) {
      _isInitialized = false;
      if (kDebugMode) {
        print(
          '[FirebaseService] Firebase initialization notice (running in offline/demo fallback mode): $e',
        );
      }
    }
  }
}
