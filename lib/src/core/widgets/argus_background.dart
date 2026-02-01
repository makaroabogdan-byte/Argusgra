import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Telegram-like grayscale wallpaper + dark overlay.
/// Use enablePattern:false for screens that must be clean (AI chat).
class ArgusBackground extends StatelessWidget {
  final Widget child;
  final bool enablePattern;
  const ArgusBackground({
    super.key,
    required this.child,
    this.enablePattern = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Base grayscale gradient (very subtle)
    final baseA = isDark ? const Color(0xFF0B0C0E) : const Color(0xFFF2F2F2);
    final baseB = isDark ? const Color(0xFF111317) : const Color(0xFFE9E9E9);

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseA, baseB],
            ),
          ),
        ),

        if (enablePattern)
          CustomPaint(
            painter: _WallpaperPainter(
              color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
              opacity: isDark ? 0.12 : 0.07,
            ),
          ),

        // Darken a bit so text never gets lost
        Container(color: isDark ? const Color(0xAA000000) : const Color(0x12000000)),

        // Subtle vignette
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.transparent,
                  isDark ? const Color(0xBB000000) : const Color(0x14000000),
                ],
              ),
            ),
          ),
        ),

        child,
      ],
    );
  }
}

class _WallpaperPainter extends CustomPainter {
  final Color color;
  final double opacity;
  _WallpaperPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withOpacity(opacity);

    // Grid cell size (symmetry + regularity)
    const cell = 64.0;
    final cols = (size.width / cell).ceil() + 1;
    final rows = (size.height / cell).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * cell + cell / 2;
        final cy = r * cell + cell / 2;

        // Deterministic variation (no хаос)
        final seed = _hash2(r, c);
        final kind = seed % 7; // 0..6
        final rot = ((seed % 12) - 6) * (math.pi / 180) * 6; // -36..36 deg
        final scale = 0.78 + ((seed >> 3) % 20) / 100.0; // 0.78..0.98

        canvas.save();
        canvas.translate(cx, cy);
        canvas.rotate(rot);
        canvas.scale(scale, scale);

        // Draw small motif, centered (symmetry)
        switch (kind) {
          case 0:
            _drawTriangle(canvas, paint);
            break;
          case 1:
            _drawCircle(canvas, paint);
            break;
          case 2:
            _drawPaperPlane(canvas, paint);
            break;
          case 3:
            _drawLightning(canvas, paint);
            break;
          case 4:
            _drawSquiggle(canvas, paint);
            break;
          case 5:
            _drawPill(canvas, paint);
            break;
          default:
            _drawDiamond(canvas, paint);
            break;
        }

        canvas.restore();
      }
    }
  }

  int _hash2(int a, int b) {
    // stable integer hash
    int x = a * 73856093 ^ b * 19349663;
    x = (x ^ (x >> 13)) * 1274126177;
    x = x ^ (x >> 16);
    return x.abs();
  }

  void _drawTriangle(Canvas canvas, Paint p) {
    final path = Path()
      ..moveTo(0, -10)
      ..lineTo(10, 10)
      ..lineTo(-10, 10)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawCircle(Canvas canvas, Paint p) {
    canvas.drawCircle(Offset.zero, 10, p);
    canvas.drawCircle(Offset.zero, 4, p);
  }

  void _drawDiamond(Canvas canvas, Paint p) {
    final path = Path()
      ..moveTo(0, -12)
      ..lineTo(12, 0)
      ..lineTo(0, 12)
      ..lineTo(-12, 0)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawPill(Canvas canvas, Paint p) {
    final r = RRect.fromRectAndRadius(const Rect.fromLTWH(-14, -8, 28, 16), const Radius.circular(9));
    canvas.drawRRect(r, p);
    canvas.drawLine(const Offset(-6, -8), const Offset(-6, 8), p);
  }

  void _drawLightning(Canvas canvas, Paint p) {
    final path = Path()
      ..moveTo(-6, -12)
      ..lineTo(2, -2)
      ..lineTo(-2, -2)
      ..lineTo(6, 12)
      ..lineTo(-2, 2)
      ..lineTo(2, 2)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawSquiggle(Canvas canvas, Paint p) {
    final path = Path()
      ..moveTo(-14, 2)
      ..cubicTo(-8, -8, -2, 12, 4, 2)
      ..cubicTo(10, -8, 14, 8, 16, 2);
    canvas.drawPath(path, p);
  }

  void _drawPaperPlane(Canvas canvas, Paint p) {
    final path = Path()
      ..moveTo(-14, -6)
      ..lineTo(16, 0)
      ..lineTo(-14, 6)
      ..lineTo(-6, 0)
      ..close();
    canvas.drawPath(path, p);
    canvas.drawLine(const Offset(-6, 0), const Offset(16, 0), p);
  }

  @override
  bool shouldRepaint(covariant _WallpaperPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}