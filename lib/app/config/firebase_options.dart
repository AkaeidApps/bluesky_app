import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps in `bluesky-75`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBluesky75WebKey1234567890abcdef',
    appId: '1:730227609164:web:bluesky75web',
    messagingSenderId: '730227609164',
    projectId: 'bluesky-75',
    authDomain: 'bluesky-75.firebaseapp.com',
    storageBucket: 'bluesky-75.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBluesky75AndroidKey1234567890ab',
    appId: '1:730227609164:android:bluesky75android',
    messagingSenderId: '730227609164',
    projectId: 'bluesky-75',
    storageBucket: 'bluesky-75.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBluesky75IosKey1234567890abcdef',
    appId: '1:730227609164:ios:bluesky75ios',
    messagingSenderId: '730227609164',
    projectId: 'bluesky-75',
    storageBucket: 'bluesky-75.appspot.com',
    iosBundleId: 'com.example.blueskyApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBluesky75IosKey1234567890abcdef',
    appId: '1:730227609164:ios:bluesky75ios',
    messagingSenderId: '730227609164',
    projectId: 'bluesky-75',
    storageBucket: 'bluesky-75.appspot.com',
    iosBundleId: 'com.example.blueskyApp',
  );
}
