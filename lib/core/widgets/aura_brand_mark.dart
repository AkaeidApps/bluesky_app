import 'package:flutter/material.dart';

/// Original butterfly-inspired brand mark for Aura Social.
/// Features a modern, geometric butterfly silhouette with gradient wings.
class AuraBrandMark extends StatelessWidget {
  final double size;
  final bool animated;
  final List<Color>? gradientColors;

  const AuraBrandMark({
    super.key,
    this.size = 36.0,
    this.animated = false,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: AuraButterflyPainter(
          gradientColors:
              gradientColors ??
              const [Color(0xFF00C2FF), Color(0xFF0085FF), Color(0xFF5856D6)],
        ),
      ),
    );
  }
}

class AuraButterflyPainter extends CustomPainter {
  final List<Color> gradientColors;

  AuraButterflyPainter({required this.gradientColors});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Center butterfly body
    final bodyPath = Path();
    bodyPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.5),
          width: w * 0.08,
          height: h * 0.45,
        ),
        Radius.circular(w * 0.04),
      ),
    );
    canvas.drawPath(bodyPath, paint);

    // Left Upper Wing (Smooth aerodynamic curved polygon)
    final leftUpperWing = Path();
    leftUpperWing.moveTo(w * 0.46, h * 0.35);
    leftUpperWing.cubicTo(
      w * 0.32,
      h * 0.10,
      w * 0.12,
      h * 0.08,
      w * 0.06,
      h * 0.22,
    );
    leftUpperWing.cubicTo(
      w * 0.02,
      h * 0.35,
      w * 0.18,
      h * 0.52,
      w * 0.46,
      h * 0.48,
    );
    leftUpperWing.close();
    canvas.drawPath(leftUpperWing, paint);

    // Right Upper Wing (Symmetric)
    final rightUpperWing = Path();
    rightUpperWing.moveTo(w * 0.54, h * 0.35);
    rightUpperWing.cubicTo(
      w * 0.68,
      h * 0.10,
      w * 0.88,
      h * 0.08,
      w * 0.94,
      h * 0.22,
    );
    rightUpperWing.cubicTo(
      w * 0.98,
      h * 0.35,
      w * 0.82,
      h * 0.52,
      w * 0.54,
      h * 0.48,
    );
    rightUpperWing.close();
    canvas.drawPath(rightUpperWing, paint);

    // Left Lower Wing (Smaller, sleek)
    final leftLowerWing = Path();
    leftLowerWing.moveTo(w * 0.46, h * 0.52);
    leftLowerWing.cubicTo(
      w * 0.20,
      h * 0.56,
      w * 0.10,
      h * 0.72,
      w * 0.22,
      h * 0.86,
    );
    leftLowerWing.cubicTo(
      w * 0.32,
      h * 0.94,
      w * 0.44,
      h * 0.78,
      w * 0.47,
      h * 0.65,
    );
    leftLowerWing.close();
    canvas.drawPath(leftLowerWing, paint);

    // Right Lower Wing (Symmetric)
    final rightLowerWing = Path();
    rightLowerWing.moveTo(w * 0.54, h * 0.52);
    rightLowerWing.cubicTo(
      w * 0.80,
      h * 0.56,
      w * 0.90,
      h * 0.72,
      w * 0.78,
      h * 0.86,
    );
    rightLowerWing.cubicTo(
      w * 0.68,
      h * 0.94,
      w * 0.56,
      h * 0.78,
      w * 0.53,
      h * 0.65,
    );
    rightLowerWing.close();
    canvas.drawPath(rightLowerWing, paint);
  }

  @override
  bool shouldRepaint(covariant AuraButterflyPainter oldDelegate) {
    return oldDelegate.gradientColors != gradientColors;
  }
}
