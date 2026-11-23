import 'package:flutter/material.dart';

/// Keeps action groups on one line when they fit and wraps on narrow screens.
class ResponsiveActionRow extends StatelessWidget {
  const ResponsiveActionRow({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: children,
      );
}
