import 'package:flutter/material.dart';

import '../../core/session/session_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/builza_mark.dart';
import '../shell/main_shell.dart';
import 'auth_flow.dart';
import 'incomplete_account_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.session});

  final SessionController session;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        switch (session.status) {
          case SessionStatus.loading:
            return const _Splash();
          case SessionStatus.unauthenticated:
            return AuthFlow(session: session);
          case SessionStatus.profileMissing:
            return IncompleteAccountScreen(session: session);
          case SessionStatus.error:
            return _SessionError(session: session);
          case SessionStatus.authenticated:
            return const MainShell();
        }
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BuilzaMark(size: 64, iconSize: 36),
            SizedBox(height: 16),
            Text(
              'BUILZA',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: 18),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _SessionError extends StatelessWidget {
  const _SessionError({required this.session});

  final SessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BuilzaMark(size: 48, iconSize: 28),
              const SizedBox(height: 20),
              const Text(
                'Could not load your company',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.navy),
              ),
              const SizedBox(height: 10),
              Text(
                session.errorMessage ?? 'Check your connection and Firestore rules, then try again.',
                style: const TextStyle(color: AppColors.muted, height: 1.4, fontSize: 15),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: session.retry,
                  child: const Text('Try again'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: session.signOut,
                  child: const Text('Sign out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
