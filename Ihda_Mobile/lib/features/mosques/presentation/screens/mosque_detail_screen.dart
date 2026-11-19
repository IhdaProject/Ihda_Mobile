import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart' as yandex;

import '../../../../app/providers/navigation_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../map/presentation/screens/map_screen.dart';
import '../../domain/entities/mosque.dart';
import '../providers/mosque_providers.dart';

class MosqueDetailScreen extends ConsumerWidget {
  final String mosqueId;

  const MosqueDetailScreen({super.key, required this.mosqueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mosquesAsync = ref.watch(mosqueControllerProvider);

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: mosquesAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(mosqueControllerProvider),
            ),
            data: (list) {
              final mosque = list.firstWhere(
                (m) => m.id == mosqueId,
                orElse: () => Mosque(
                  id: mosqueId,
                  name: 'Masjid',
                  address: '',
                  phone: '',
                  distanceLabel: '',
                  latitude: 0,
                  longitude: 0,
                ),
              );
              return _MosqueDetailBody(mosque: mosque);
            },
          ),
        ),
      ),
    );
  }
}

class _MosqueDetailBody extends ConsumerWidget {
  final Mosque mosque;

  const _MosqueDetailBody({required this.mosque});

  Future<void> _pickAndAddVisitDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Sanasini tanlang',
      cancelText: 'Bekor',
      confirmText: 'Tanlash',
    );

    if (pickedDate != null && context.mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: 'Vaqtini tanlang',
        cancelText: 'Bekor',
        confirmText: 'Saqlash',
      );

      final visitDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? 12,
        pickedTime?.minute ?? 0,
      );

      await ref
          .read(mosqueControllerProvider.notifier)
          .addVisitRecord(mosque.id, visitDateTime);

      if (context.mounted) {
        showAppToast(
          context,
          'Tashrif sanasi saqlandi ✅',
          icon: Icons.check_circle_rounded,
        );
      }
    }
  }

  String _formatCompactDateTime(DateTime dt) {
    try {
      return DateFormat('d-MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return '${dt.day}.${dt.month}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(mosqueControllerProvider.notifier);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // 1. Header Navigation
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                'Masjid',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // 2. Mosque Banner Image
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Center(
            child: Icon(Icons.mosque_rounded, size: 72, color: Colors.white70),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 3. Primary Mosque Information (Name, Address, Phone)
        Text(
          mosque.name,
          style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.place_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                mosque.address,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              Icons.call_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              mosque.phone,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // 4. Prayer Schedule Table
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              const _ScheduleHeaderRow(),
              const Divider(height: 1),
              for (final row in mosque.schedule) ...[
                _ScheduleRow(row: row),
                if (row != mosque.schedule.last) const Divider(height: 1),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 5. Direction Button ("Yo'nalish")
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            onPressed: () {
              ref.read(selectedMapTargetProvider.notifier).state = SelectedMapTarget(
                point: yandex.Point(latitude: mosque.latitude, longitude: mosque.longitude),
                name: mosque.name,
                mosqueId: mosque.id,
              );
              ref.read(navigationIndexProvider.notifier).state = 2; // Map tab
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.directions_rounded),
            label: const Text("Yo'nalish", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // 6. AT THE VERY BOTTOM: Compact & Refined Status & History Section
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact Chips Row for "Sevimli" and "Borganman"
              Row(
                children: [
                  // Favorite Chip
                  InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    onTap: () => controller.toggleFavorite(mosque.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: mosque.isFavorite
                            ? theme.colorScheme.secondary.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: mosque.isFavorite
                              ? theme.colorScheme.secondary
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            mosque.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 18,
                            color: mosque.isFavorite
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            mosque.isFavorite ? 'Sevimli' : 'Sevimlilarga',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: mosque.isFavorite
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Visited Chip
                  InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    onTap: () => controller.toggleVisited(mosque.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: mosque.isVisited
                            ? Colors.green.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: mosque.isVisited ? Colors.green : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: mosque.isVisited ? Colors.green : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            mosque.isVisited
                                ? 'Borganman (${mosque.visitCount})'
                                : 'Borganman',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: mosque.isVisited ? Colors.green : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Compact + Add Visit button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                    tooltip: 'Tashrif sanasi qo\'shish',
                    color: theme.colorScheme.primary,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _pickAndAddVisitDate(context, ref),
                  ),
                ],
              ),

              // Visit History Entries (if any)
              if (mosque.visitDates.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 6),
                for (int i = 0; i < mosque.visitDates.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.event_note_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          _formatCompactDateTime(mosque.visitDates[i]),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => controller.removeVisitRecord(mosque.id, i),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(Icons.close_rounded, size: 15, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _ScheduleHeaderRow extends StatelessWidget {
  const _ScheduleHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Namoz',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Expanded(
            child: Text(
              'Azon',
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Iqama',
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final PrayerScheduleRow row;

  const _ScheduleRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              row.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              row.azon,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              row.iqama,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
