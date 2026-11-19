import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable SVG Logo widget for Ihda Mobile.
///
/// Renders the app's transparent SVG icon cleanly without any background
/// box or container. Automatically adapts to light and dark theme colors
/// or accepts an explicit [color] override.
class AppLogoIcon extends StatelessWidget {
  final double? size;
  final double? width;
  final double? height;
  final Color? color;
  final bool useOriginalColor;
  final BoxFit fit;

  const AppLogoIcon({
    super.key,
    this.size,
    this.width,
    this.height,
    this.color,
    this.useOriginalColor = false,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;

    final ColorFilter? colorFilter;
    if (useOriginalColor) {
      colorFilter = null;
    } else if (color != null) {
      colorFilter = ColorFilter.mode(color!, BlendMode.srcIn);
    } else {
      final themePrimary = Theme.of(context).colorScheme.primary;
      colorFilter = ColorFilter.mode(themePrimary, BlendMode.srcIn);
    }

    return SvgPicture.asset(
      'assets/app_icon.svg',
      width: effectiveWidth,
      height: effectiveHeight,
      fit: fit,
      colorFilter: colorFilter,
    );
  }
}
