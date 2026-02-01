import 'package:flutter/material.dart';

class MonoBackground extends StatelessWidget {
  final Widget child;
  final String seed;
  const MonoBackground({super.key, required this.child, required this.seed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ фон темнее (чтобы текст не терялся)
    final colors = isDark
        ? const [Color(0xFF030303), Color(0xFF080808), Color(0xFF0F0F0F)]
        : const [Color(0xFFF0F0F0), Color(0xFFEAEAEA), Color(0xFFE2E2E2)];

    // ✅ паттерн менее контрастный
    final patternStroke = isDark ? const Color(0x18FFFFFF) : const Color(0x12000000);
    final patternFill = isDark ? const Color(0x10FFFFFF) : const Color(0x0C000000);

    // ✅ лёгкий "скрим" поверх, чтобы текст читался
    final scrim = isDark ? const Color(0x66000000) : const Color(0x11FFFFFF);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _TiledPatternPainter(
              stroke: patternStroke,
              fill: patternFill,
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(decoration: BoxDecoration(color: scrim)),
        ),
        child,
      ],
    );
  }
}

/// Симметричная плитка, равномерно по всей площади
class _TiledPatternPainter extends CustomPainter {
  final Color stroke;
  final Color fill;
  _TiledPatternPainter({required this.stroke, required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    final pStroke = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final pFill = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;

    const cell = 72.0;

    for (double y = 0; y < size.height + cell; y += cell) {
      for (double x = 0; x < size.width + cell; x += cell) {
        final ix = (x / cell).floor();
        final iy = (y / cell).floor();
        final flip = ((ix + iy) % 2 == 0);

        canvas.save();
        canvas.translate(x + cell * 0.5, y + cell * 0.5);
        if (flip) canvas.scale(-1, 1);

        _drawTile(canvas, pStroke, pFill);
        canvas.restore();
      }
    }
  }

  void _drawTile(Canvas canvas, Paint stroke, Paint fill) {
    const c = Offset(0, 0);

    // самолётик
    final plane = Path()
      ..moveTo(c.dx - 18, c.dy + 6)
      ..lineTo(c.dx + 20, c.dy)
      ..lineTo(c.dx - 6, c.dy - 18)
      ..lineTo(c.dx - 2, c.dy - 4)
      ..close();
    canvas.drawPath(plane, fill);
    canvas.drawPath(plane, stroke);

    // капсула
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(-18, -18), width: 26, height: 12),
      const Radius.circular(99),
    );
    canvas.drawRRect(r, stroke);

    // кружок
    canvas.drawCircle(const Offset(18, -20), 7.5, stroke);

    // волна
    final wave = Path()
      ..moveTo(-22, 22)
      ..quadraticBezierTo(-10, 10, 2, 22)
      ..quadraticBezierTo(14, 34, 26, 22);
    canvas.drawPath(wave, stroke);

    // треугольник
    final tri = Path()
      ..moveTo(20, 12)
      ..lineTo(8, 30)
      ..lineTo(32, 30)
      ..close();
    canvas.drawPath(tri, stroke);
  }

  @override
  bool shouldRepaint(covariant _TiledPatternPainter oldDelegate) =>
      oldDelegate.stroke != stroke || oldDelegate.fill != fill;
}
