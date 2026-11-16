import 'package:flutter/material.dart';

import 'core/session/session_controller.dart';
import 'core/session/session_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_flow.dart';
import 'features/auth/auth_gate.dart';
import 'features/shell/main_shell.dart';

class BuilzaApp extends StatefulWidget {
  const BuilzaApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  State<BuilzaApp> createState() => _BuilzaAppState();
}

class _BuilzaAppState extends State<BuilzaApp> {
  SessionController? _session;

  @override
  void initState() {
    super.initState();
    if (widget.firebaseReady) {
      _session = SessionController()..start();
    }
  }

  @override
  void dispose() {
    _session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return MaterialApp(
      title: 'BUILZA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        if (session == null) return child ?? const SizedBox.shrink();
        return SessionScope(controller: session, child: child ?? const SizedBox.shrink());
      },
      home: session == null ? const _PreviewAuth() : AuthGate(session: session),
    );
  }
}

class _PreviewAuth extends StatefulWidget {
  const _PreviewAuth();

  @override
  State<_PreviewAuth> createState() => _PreviewAuthState();
}

class _PreviewAuthState extends State<_PreviewAuth> {
  bool _inWorkspace = false;

  @override
  Widget build(BuildContext context) {
    if (_inWorkspace) return const MainShell();
    return AuthFlow(onPreviewSignedIn: () => setState(() => _inWorkspace = true));
  }
}
