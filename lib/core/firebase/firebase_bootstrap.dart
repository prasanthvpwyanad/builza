import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

bool firebaseOptionsAreConfigured(FirebaseOptions options) {
  return options.apiKey.isNotEmpty &&
      !options.apiKey.startsWith('YOUR_') &&
      options.projectId.isNotEmpty &&
      options.projectId != 'YOUR_PROJECT_ID' &&
      options.appId.isNotEmpty &&
      !options.appId.startsWith('YOUR_');
}

Future<bool> bootstrapFirebase() async {
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (!firebaseOptionsAreConfigured(options)) {
      return false;
    }
    await Firebase.initializeApp(options: options);
    return true;
  } catch (error, stack) {
    debugPrint('Firebase bootstrap skipped: $error\n$stack');
    return false;
  }
}
