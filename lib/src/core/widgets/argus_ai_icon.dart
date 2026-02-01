import 'package:flutter/material.dart';

class ArgusAiIcon extends StatelessWidget {
  final double size;
  const ArgusAiIcon({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Image.asset(
      isDark ? 'assets/icons/argus_white.png' : 'assets/icons/argus_black.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.high,
    );
  }
}
