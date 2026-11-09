import 'package:flutter/material.dart';
import '../../../../app/theme/app_radius.dart';

class RegionSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final VoidCallback onClear;

  const RegionSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.12) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
        ),
        cursorColor: primaryColor,
        decoration: InputDecoration(
          hintText: 'Hududlarni qidirish (Toshkent, Samarqand...)',
          hintStyle: TextStyle(
            color: isDark
                ? Colors.white60
                : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
