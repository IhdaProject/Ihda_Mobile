import 'dart:math';
import 'package:flutter/material.dart';

enum PrayerUrgencyLevel {
  normal,   // Normal waiting time
  warning,  // 25-15 min before Fajr/Sunrise/Maghrib or 25-15 min before others
  critical, // Last 15 min before Fajr/Sunrise/Maghrib or < 15 min before others
}

class HourglassTimerWidget extends StatefulWidget {
  final double progress; // 0.0 to 1.0 elapsed
  final PrayerUrgencyLevel urgency;
  final IconData prayerIcon;
  final double size;

  const HourglassTimerWidget({
    super.key,
    required this.progress,
    required this.urgency,
    required this.prayerIcon,
    this.size = 68.0,
  });

  @override
  State<HourglassTimerWidget> createState() => _HourglassTimerWidgetState();
}

class _HourglassTimerWidgetState extends State<HourglassTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.urgency == PrayerUrgencyLevel.critical) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant HourglassTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.urgency == PrayerUrgencyLevel.critical && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.urgency != PrayerUrgencyLevel.critical && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _ringColor {
    switch (widget.urgency) {
      case PrayerUrgencyLevel.critical:
        return const Color(0xFFF43F5E); // Rich Rose Red
      case PrayerUrgencyLevel.warning:
        return const Color(0xFFF59E0B); // Vibrant Amber Gold
      case PrayerUrgencyLevel.normal:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular Ring Custom Painter (Visual Time Sand Level)
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _TimerRingPainter(
                progress: widget.progress.clamp(0.0, 1.0),
                ringColor: _ringColor,
                urgency: widget.urgency,
              ),
            ),
            // Center Hourglass / Prayer Icon with subtle glow
            Container(
              width: widget.size * 0.72,
              height: widget.size * 0.72,
              decoration: BoxDecoration(
                color: _ringColor.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.urgency == PrayerUrgencyLevel.critical
                        ? Icons.hourglass_bottom_rounded
                        : (widget.urgency == PrayerUrgencyLevel.warning
                            ? Icons.hourglass_top_rounded
                            : widget.prayerIcon),
                    color: Colors.white,
                    size: widget.size * 0.38,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final PrayerUrgencyLevel urgency;

  _TimerRingPainter({
    required this.progress,
    required this.ringColor,
    required this.urgency,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    const strokeWidth = 5.0;

    // Track Background
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Active Remaining Arc
    final sweepAngle = 2 * pi * (1.0 - progress);
    final arcPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.urgency != urgency;
  }
}
