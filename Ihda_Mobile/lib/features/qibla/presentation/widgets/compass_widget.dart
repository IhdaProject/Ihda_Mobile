import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class CompassWidget extends StatelessWidget {
  final double relativeDirectionDegrees;
  final double size;

  const CompassWidget({
    super.key,
    required this.relativeDirectionDegrees,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          ..._buildTicks(context),
          _CardinalLabel(label: 'N', alignment: const Alignment(0, -0.85), color: Theme.of(context).colorScheme.primary),
          const _CardinalLabel(label: 'E', alignment: Alignment(0.85, 0)),
          const _CardinalLabel(label: 'S', alignment: Alignment(0, 0.85)),
          const _CardinalLabel(label: 'W', alignment: Alignment(-0.85, 0)),
          AnimatedRotation(
            turns: relativeDirectionDegrees / 360,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mosque_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                Container(width: 4, height: size * 0.32, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTicks(BuildContext context) {
    return List.generate(24, (i) {
      final angle = i * (360 / 24) * math.pi / 180;
      final isMajor = i % 6 == 0;
      return Transform.rotate(
        angle: angle,
        child: Align(
          alignment: const Alignment(0, -0.95),
          child: Container(
            width: isMajor ? 3 : 1.5,
            height: isMajor ? 14 : 8,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(isMajor ? 0.6 : 0.3),
          ),
        ),
      );
    });
  }
}

class _CardinalLabel extends StatelessWidget {
  final String label;
  final Alignment alignment;
  final Color? color;

  const _CardinalLabel({required this.label, required this.alignment, this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
