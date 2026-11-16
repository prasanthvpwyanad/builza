String? validateCompanyName(String? value) {
  final text = value?.trim() ?? '';
  if (text.length < 2) return 'Enter the company name.';
  if (text.length > 80) return 'Company name must be 80 characters or fewer.';
  return null;
}

String? validatePersonName(String? value) {
  final text = value?.trim() ?? '';
  if (text.length < 2) return 'Enter the administrator name.';
  if (text.length > 80) return 'Name must be 80 characters or fewer.';
  return null;
}

String? validateEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Enter an email address.';
  final email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!email.hasMatch(text)) return 'Enter a valid email address.';
  return null;
}

String? validateOptionalEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  return validateEmail(text);
}

String? validatePassword(String? value) {
  final text = value ?? '';
  if (text.length < 8) return 'Password must be at least 8 characters.';
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value != password) return 'Passwords do not match.';
  return null;
}

String? validateInviteCode(String? value) {
  final text = (value ?? '').toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  if (text.length != 8) return 'Enter the 8-character invite code.';
  return null;
}
