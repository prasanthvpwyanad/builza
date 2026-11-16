import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/builza_mark.dart';

class AuthSplit extends StatelessWidget {
  const AuthSplit({super.key, required this.child, this.showMobileBrand = true});

  final Widget child;
  final bool showMobileBrand;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: wide
          ? Row(
              children: [
                const Expanded(flex: 5, child: _BrandPane()),
                Expanded(flex: 6, child: _FormPane(child: child)),
              ],
            )
          : _FormPane(child: child, showMobileBrand: showMobileBrand),
    );
  }
}

class _FormPane extends StatelessWidget {
  const _FormPane({required this.child, this.showMobileBrand = false});

  final Widget child;
  final bool showMobileBrand;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
            children: [
              if (showMobileBrand) ...[
                const BuilzaLogo(height: 48),
                const SizedBox(height: 28),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandPane extends StatelessWidget {
  const _BrandPane();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C8DE6), Color(0xFF123A73), Color(0xFF0B274C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -40,
            child: _Blob(size: 220, color: Colors.white.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: 80,
            right: -30,
            child: _Blob(size: 180, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 56, 48, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const BuilzaLogo(height: 58),
                ),
                const SizedBox(height: 18),
                Text(
                  'BUILD. MANAGE. GROW.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
                const Spacer(),
                const _PhonePreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhonePreview extends StatelessWidget {
  const _PhonePreview();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        width: 230,
        height: 300,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFF),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 72,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.navy, AppColors.blue]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CASH IN HAND', style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 0.8)),
                    SizedBox(height: 4),
                    Text('₹ 1,80,000', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _miniRow('AMRUTHA WAYANAD', '₹ 65,000'),
              _miniRow('PHINO WAYANAD', '₹ 48,500'),
              _miniRow('SANJANA PUNNOL', '₹ 66,500'),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _miniRow(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.ink)),
            ),
            Text(amount, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.green)),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
