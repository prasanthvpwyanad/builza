import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CompanyLogo extends StatelessWidget {
  const CompanyLogo({
    super.key,
    this.url,
    this.bytes,
    this.name = '',
    this.size = 40,
    this.width,
    this.fit = BoxFit.contain,
  });

  final String? url;
  final Uint8List? bytes;
  final String name;
  final double size;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final logoWidth = width ?? size;
    final radius = BorderRadius.circular(size * 0.22);
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      heightFactor: 1,
      child: ClipRRect(
        borderRadius: radius,
        child: ColoredBox(
          color: Colors.white,
          child: SizedBox(
            width: logoWidth,
            height: size,
            child: _image() ?? _placeholder(),
          ),
        ),
      ),
    );
  }

  Widget? _image() {
    if (bytes != null && bytes!.isNotEmpty) {
      return Image.memory(bytes!, fit: fit, alignment: Alignment.center, filterQuality: FilterQuality.high);
    }
    final logoUrl = url?.trim() ?? '';
    if (logoUrl.isEmpty) return null;
    return Image.network(
      logoUrl,
      fit: fit,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: const Color(0xFFE7F2FF),
      child: Center(
        child: Text(
          companyInitials(name),
          style: TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.32,
          ),
        ),
      ),
    );
  }
}

class CompanyIdentityCard extends StatelessWidget {
  const CompanyIdentityCard({
    super.key,
    required this.name,
    this.bytes,
    this.url,
  });

  final String name;
  final Uint8List? bytes;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
        child: Row(
          children: [
            Container(
              width: 188,
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8EEF5)),
              ),
              child: CompanyLogo(
                name: name,
                bytes: bytes,
                url: url,
                size: 60,
                width: 172,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyLogoField extends StatelessWidget {
  const CompanyLogoField({
    super.key,
    required this.name,
    this.url,
    this.bytes,
    this.enabled = true,
    required this.onPick,
    this.size = 48,
    this.helper = 'Optional. PNG, JPG, or WEBP, up to 700 KB.',
  });

  final String name;
  final String? url;
  final Uint8List? bytes;
  final bool enabled;
  final VoidCallback onPick;
  final double size;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final hasLogo = (bytes != null && bytes!.isNotEmpty) || (url != null && url!.trim().isNotEmpty);
    return InkWell(
      onTap: enabled ? onPick : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Company logo',
          helperText: helper,
          suffixIcon: Icon(
            hasLogo ? Icons.edit_outlined : Icons.upload_file_outlined,
            color: enabled ? AppColors.blue : AppColors.muted,
          ),
        ),
        child: Row(
          children: [
            CompanyLogo(
              name: name,
              url: url,
              bytes: bytes,
              size: size,
              width: size * 2.8,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasLogo ? 'Logo selected — tap to change' : 'Tap to choose an image',
                style: TextStyle(
                  color: hasLogo ? AppColors.ink : AppColors.muted,
                  fontWeight: hasLogo ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String companyInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return 'CO';
  if (parts.length == 1) {
    final word = parts.first;
    return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
  }
  return (parts[0][0] + parts[1][0]).toUpperCase();
}
