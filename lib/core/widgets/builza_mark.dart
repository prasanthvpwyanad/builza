import 'package:flutter/material.dart';

class BuilzaMark extends StatelessWidget {
  const BuilzaMark({super.key, this.size = 34, this.iconSize});

  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/brand/builza_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        semanticLabel: 'BUILZA',
      ),
    );
  }
}

class BuilzaLogo extends StatelessWidget {
  const BuilzaLogo({super.key, this.height = 56});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/builza_logo.png',
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      filterQuality: FilterQuality.high,
      semanticLabel: 'BUILZA',
    );
  }
}
