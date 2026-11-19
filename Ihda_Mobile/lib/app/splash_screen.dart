import 'package:flutter/material.dart';

import '../app/theme/app_spacing.dart';
import '../shared/widgets/app_logo_icon.dart';
import '../shared/widgets/design_background.dart';

/// Entry splash screen displaying the transparent SVG logo with a subtle
/// loading shimmer light sweep and breathing pulse animation.
class SplashScreen extends StatefulWidget {
  final String? statusText;

  const SplashScreen({super.key, this.statusText});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: DesignBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Shimmer + Breathing Scale Logo
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: ShaderMask(
                      blendMode: BlendMode.srcATop,
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment(_shimmerAnimation.value - 1.0, -0.2),
                          end: Alignment(_shimmerAnimation.value, 0.2),
                          colors: [
                            primaryColor,
                            primaryColor.withValues(alpha: 0.5),
                            Colors.white,
                            primaryColor.withValues(alpha: 0.5),
                            primaryColor,
                          ],
                          stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                        ).createShader(bounds);
                      },
                      child: const AppLogoIcon(
                        size: 110,
                        useOriginalColor: false,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'Ihda Mobile',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Namoz vaqtlari va Islomiy eslatmalar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // Status Indicator / Shimmer Dots
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Column(
                  children: [
                    SizedBox(
                      width: 140,
                      child: LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: primaryColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    if (widget.statusText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.statusText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
