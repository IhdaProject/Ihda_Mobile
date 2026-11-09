import 'package:flutter/material.dart';

InputDecoration buildModernInputDecoration({
  required BuildContext context,
  required String labelText,
  String? hintText,
  IconData? prefixIcon,
  String? suffixText,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final primaryColor = Theme.of(context).colorScheme.primary;

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    suffixText: suffixText,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: primaryColor) : null,
    filled: true,
    fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
    labelStyle: TextStyle(
      fontSize: 13,
      color: isDark ? Colors.white70 : Colors.black54,
    ),
  );
}
