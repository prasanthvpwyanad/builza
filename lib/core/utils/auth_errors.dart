import 'package:firebase_auth/firebase_auth.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

String describeFirebaseError(Object error) {
  if (error is AuthFailure) return error.message;
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-login-credentials':
        return 'Invalid email or password.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a few minutes.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'user-disabled':
        return 'This administrator account has been disabled.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase Authentication.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'Permission denied. Deploy the BUILZA Firestore rules to your Firebase project.';
      case 'unavailable':
        return 'Firebase is temporarily unavailable. Try again.';
      case 'not-found':
        return 'That invite code or company could not be found.';
      default:
        return 'Could not complete the request. Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}
