// Generated for Firebase project "builza".
// Re-run: dart pub global run flutterfire_cli:flutterfire configure --project=builza

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'This platform is not configured. Run flutterfire configure.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBqXCWLYCNCOOCAXIwjMjGicCI8r50_Rk4',
    appId: '1:1092308165588:web:518f373b05e538e63bac41',
    messagingSenderId: '1092308165588',
    projectId: 'builza',
    authDomain: 'builza.firebaseapp.com',
    storageBucket: 'builza.firebasestorage.app',
    measurementId: 'G-GSXWPXFZNB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWvVKrSyR0a5lOFsOheW6yrq8-rHNeFMI',
    appId: '1:1092308165588:android:328177b4ae2752e83bac41',
    messagingSenderId: '1092308165588',
    projectId: 'builza',
    storageBucket: 'builza.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBqXCWLYCNCOOCAXIwjMjGicCI8r50_Rk4',
    appId: '1:1092308165588:web:b0be4036798c75873bac41',
    messagingSenderId: '1092308165588',
    projectId: 'builza',
    authDomain: 'builza.firebaseapp.com',
    storageBucket: 'builza.firebasestorage.app',
    measurementId: 'G-DFT1NRKXD2',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDwjk--j096nCBUis8AJNUfwpSj_QLT1-k',
    appId: '1:1092308165588:ios:798deb75948036c83bac41',
    messagingSenderId: '1092308165588',
    projectId: 'builza',
    storageBucket: 'builza.firebasestorage.app',
    iosBundleId: 'com.example.builza',
  );
}
