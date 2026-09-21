import 'package:flutter/material.dart';

/// Lightweight placeholder "map" - a few curved roads on a tinted
/// background - so the Map screen has something to look at without
/// pulling in a real maps SDK/API key. Swap for google_maps_flutter or
/// flutter_map once you have tiles/an API key.
class MapBackgroundPainter extends CustomPainter {
  final Color roadColor;
  final Color backgroundColor;

  MapBackgroundPainter({required this.roadColor, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final roadPaint = Paint()
      ..color = roadColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.25)
        ..quadraticBezierTo(w * 0.4, h * 0.1, w, h * 0.35),
      roadPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.6)
        ..quadraticBezierTo(w * 0.5, h * 0.75, w, h * 0.5),
      roadPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.2, 0)
        ..quadraticBezierTo(w * 0.35, h * 0.5, w * 0.15, h),
      roadPaint..strokeWidth = 6,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.75, 0)
        ..quadraticBezierTo(w * 0.6, h * 0.4, w * 0.8, h),
      roadPaint..strokeWidth = 6,
    );
  }

  @override
  bool shouldRepaint(covariant MapBackgroundPainter oldDelegate) =>
      oldDelegate.roadColor != roadColor || oldDelegate.backgroundColor != backgroundColor;
}
