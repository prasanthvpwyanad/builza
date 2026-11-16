import 'package:flutter/material.dart';

import '../../core/session/session_controller.dart';
import 'join_company_screen.dart';
import 'login_screen.dart';
import 'register_company_screen.dart';

enum AuthPage { signIn, register, join }

class AuthFlow extends StatefulWidget {
  const AuthFlow({
    super.key,
    this.session,
    this.onPreviewSignedIn,
  });

  final SessionController? session;
  final VoidCallback? onPreviewSignedIn;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  AuthPage _page = AuthPage.signIn;

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      AuthPage.signIn => LoginScreen(
          session: widget.session,
          onPreviewSignedIn: widget.onPreviewSignedIn,
          onRegister: () => setState(() => _page = AuthPage.register),
          onJoin: () => setState(() => _page = AuthPage.join),
        ),
      AuthPage.register => RegisterCompanyScreen(
          session: widget.session,
          onBackToLogin: () => setState(() => _page = AuthPage.signIn),
        ),
      AuthPage.join => JoinCompanyScreen(
          session: widget.session,
          onBackToLogin: () => setState(() => _page = AuthPage.signIn),
        ),
    };
  }
}
