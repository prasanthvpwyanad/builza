import 'package:flutter/material.dart';

import 'app.dart';
import 'core/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseReady = await bootstrapFirebase();
  runApp(BuilzaApp(firebaseReady: firebaseReady));
}
