import 'dart:math';

const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const joinCodeLength = 8;
const joinInviteDays = 7;

String generateJoinCode([Random? random]) {
  final source = random ?? Random.secure();
  return List.generate(
    joinCodeLength,
    (_) => _alphabet[source.nextInt(_alphabet.length)],
  ).join();
}

String normalizeJoinCode(String input) {
  return input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
}

bool isValidJoinCode(String input) {
  return normalizeJoinCode(input).length == joinCodeLength;
}

String formatJoinCode(String code) {
  final normalized = normalizeJoinCode(code);
  if (normalized.length != joinCodeLength) return normalized;
  return '${normalized.substring(0, 4)}-${normalized.substring(4)}';
}
