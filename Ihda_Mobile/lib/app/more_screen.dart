import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_services.dart';
import '../core/localization/localization_provider.dart';
import '../shared/widgets/design_background.dart';
import 'providers/services_provider.dart';
import 'theme/app_spacing.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesControllerProvider);
    final servicesNotifier = ref.read(servicesControllerProvider.notifier);
    final orderedServices = servicesNotifier.getOrderedServices();

    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
    final crossAxisCount = servicesState.columnCount; // 3 or 4
    final gridRatio = crossAxisCount == 3
        ? (fontScale > 1.1 ? 0.95 : 1.05)
        : (fontScale > 1.1 ? 0.75 : 0.85);

    return Scaffold(
      body: DesignBackground(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_isEditMode) {
              setState(() => _isEditMode = false);
            }
          },
          child: SafeArea(
            child: Column(
              children: [
                // Header & Column Selector (No edit button as requested)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
                  key: const ValueKey('more_header'),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'more'.tr(ref),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      // Column selector (3 or 4)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _ColumnCountButton(
                              count: 3,
                              isSelected: crossAxisCount == 3,
                              onTap: () => servicesNotifier.setColumnCount(3),
                            ),
                            _ColumnCountButton(
                              count: 4,
                              isSelected: crossAxisCount == 4,
                              onTap: () => servicesNotifier.setColumnCount(4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isEditMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.touch_app_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Tahrir rejimi: Ilovani bosib turib suring. Saqlash uchun bo\'sh joyga bosing.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Grid Content Area with Drag and Drop Support
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: gridRatio,
                    ),
                    itemCount: orderedServices.length,
                    itemBuilder: (context, index) {
                      final item = orderedServices[index];
                      final tile = _ServiceTile(
                        item: item,
                        isEditMode: _isEditMode,
                      );

                      if (!_isEditMode) {
                        return GestureDetector(
                          key: ValueKey(item.id),
                          onTap: () => item.onTap(context, ref),
                          onLongPress: () => setState(() => _isEditMode = true),
                          child: tile,
                        );
                      }

                      // In Edit Mode: Draggable & DragTarget for Samsung/iPhone style arrangement
                      return LongPressDraggable<String>(
                        data: item.id,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Opacity(
                            opacity: 0.85,
                            child: SizedBox(
                              width: 90,
                              height: 90,
                              child: tile,
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: tile,
                        ),
                        child: DragTarget<String>(
                          onWillAccept: (incomingId) => incomingId != item.id,
                          onAccept: (incomingId) {
                            final oldIndex = orderedServices.indexWhere((s) => s.id == incomingId);
                            final newIndex = index;
                            if (oldIndex != -1) {
                              servicesNotifier.reorder(oldIndex, newIndex);
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            return GestureDetector(
                              onTap: () {}, // Prevent background tap when tapping tile in edit mode
                              onLongPress: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: candidateData.isNotEmpty
                                      ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                                      : null,
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned.fill(child: tile),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.open_with_rounded, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColumnCountButton extends StatelessWidget {
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColumnCountButton({required this.count, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends ConsumerWidget {
  final ServiceItem item;
  final bool isEditMode;

  const _ServiceTile({required this.item, required this.isEditMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
    final boxSize = max(58.0, 58.0 * fontScale);
    final iconSize = 28.0 * fontScale;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(isEditMode ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(16),
                border: isEditMode
                    ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.6), width: 1.5)
                    : null,
              ),
              child: Icon(
                item.icon,
                color: Theme.of(context).colorScheme.primary,
                size: iconSize,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          item.getLabel(ref),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
