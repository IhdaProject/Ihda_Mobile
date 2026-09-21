import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class DesignBackground extends StatelessWidget {
  final Widget child;
  final bool showSecondaryWave;
  final bool isWarning;

  const DesignBackground({
    super.key,
    required this.child,
    this.showSecondaryWave = true,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isWarning ? Colors.red : AppColors.primary;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: isWarning ? Colors.red.withOpacity(0.05) : Theme.of(context).scaffoldBackgroundColor),
        ),
        Positioned(
          top: -100,
          right: -100,
          child: _CircleWave(
            size: 400,
            color: primaryColor.withOpacity(0.05),
          ),
        ),
        if (showSecondaryWave)
          Positioned(
            top: 200,
            left: -150,
            child: _CircleWave(
              size: 500,
              color: primaryColor.withOpacity(0.03),
            ),
          ),
        Positioned.fill(
          child: CustomPaint(
            painter: _WavePainter(
              color: primaryColor.withOpacity(0.1),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _CircleWave extends StatelessWidget {
  final double size;
  final Color color;

  const _CircleWave({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.45,
      size.width,
      size.height * 0.35,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeroBackground extends StatelessWidget {
  final Widget child;

  const HeroBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 320,
          decoration: const BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
          ),
        ),
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _HeroWavePainter(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _HeroWavePainter extends CustomPainter {
  final Color color;

  _HeroWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 180);
    path.quadraticBezierTo(size.width * 0.3, 140, size.width * 0.6, 220);
    path.quadraticBezierTo(size.width * 0.85, 280, size.width, 240);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
