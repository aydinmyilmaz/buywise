import 'package:flutter/material.dart';

class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  const DashedBorder({
    super.key,
    required this.child,
    required this.color,
    this.radius = 18,
    this.strokeWidth = 1.5,
    this.dashWidth = 6,
    this.dashGap = 6,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: radius,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashGap: dashGap,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().first;
    double distance = 0;
    while (distance < metrics.length) {
      final next = distance + dashWidth;
      canvas.drawPath(metrics.extractPath(distance, next), paint);
      distance = next + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}
