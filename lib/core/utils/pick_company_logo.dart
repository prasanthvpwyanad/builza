import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'auth_errors.dart';

class PickedLogo {
  const PickedLogo({required this.bytes, required this.contentType});

  final Uint8List bytes;
  final String contentType;
}

const int maxCompanyLogoBytes = 700 * 1024;

const _allowedTypes = {'image/png', 'image/jpeg', 'image/jpg', 'image/webp'};

Future<PickedLogo?> pickCompanyLogo() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 80,
  );
  if (file == null) return null;

  final bytes = await file.readAsBytes();
  if (bytes.isEmpty) {
    throw const AuthFailure('Could not read that image.');
  }
  if (bytes.length > maxCompanyLogoBytes) {
    throw const AuthFailure('Logo must be under 700 KB.');
  }

  final contentType = _normalizeContentType(file.mimeType ?? _guessContentType(file.name));
  if (!_allowedTypes.contains(contentType)) {
    throw const AuthFailure('Use a PNG, JPG, or WEBP logo.');
  }
  return PickedLogo(bytes: bytes, contentType: contentType);
}

String _normalizeContentType(String type) {
  final value = type.trim().toLowerCase();
  if (value == 'image/jpg') return 'image/jpeg';
  return value;
}

String _guessContentType(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  return 'application/octet-stream';
}
