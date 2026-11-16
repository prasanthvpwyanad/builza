import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/builza_mark.dart';

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  static const _commands = '''
dart pub global activate flutterfire_cli
firebase login
firebase init
flutterfire configure
firebase deploy --only firestore:rules,storage
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
              children: [
                const BuilzaMark(size: 56, iconSize: 32),
                const SizedBox(height: 16),
                const Text(
                  'Connect Firebase',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.navy),
                ),
                const SizedBox(height: 8),
                const Text(
                  'BUILZA is ready for multi-tenant authentication, but this app is not linked to a Firebase project yet.',
                  style: TextStyle(color: AppColors.muted, height: 1.4, fontSize: 15),
                ),
                const SizedBox(height: 22),
                const _Step(number: '1', title: 'Create a Firebase project', body: 'In the Firebase console, create a project, then enable Authentication (Email/Password), Cloud Firestore, and Storage.'),
                const _Step(number: '2', title: 'Configure this Flutter app', body: 'From the project root, run flutterfire configure. That replaces lib/firebase_options.dart and adds google-services files.'),
                const _Step(number: '3', title: 'Deploy tenant security rules', body: 'The rules in firebase/firestore.rules keep each company’s records isolated. Deploy them before creating real companies.'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Commands', style: TextStyle(fontWeight: FontWeight.w800)),
                            ),
                            IconButton(
                              tooltip: 'Copy commands',
                              onPressed: () async {
                                await Clipboard.setData(const ClipboardData(text: _commands));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Commands copied')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.copy_rounded, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const SelectableText(
                          _commands,
                          style: TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'After configuration, restart the app. Register a company as Admin 1, then invite Admin 2 from Company settings.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.body});

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.navy,
            child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: AppColors.muted, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
