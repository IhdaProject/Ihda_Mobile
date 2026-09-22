import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../location/presentation/screens/region_selection_screen.dart';
import '../../domain/entities/notification_settings.dart';
import '../providers/notification_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  static const List<String> _sampleDeviceAudios = [
    'Azon_Makkah.mp3',
    'Azon_Madina.mp3',
    'Subh_Melody.wav',
    'Mening_Audio_Faylim.mp3',
    'Gentle_Alarm.mp3',
    'Custom_Ringtone_1.mp3',
  ];

  static void _showAudioPickerSheet(
    BuildContext context,
    WidgetRef ref,
    PrayerNotificationConfig prayer,
    bool isMainPrayer,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${prayer.name} uchun audio/tovush tanlang',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Telefon xotirasidagi mavjud audio fayllar ro\'yxati:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: AppSpacing.md),
              for (final audio in _sampleDeviceAudios)
                ListTile(
                  leading: Icon(Icons.audiotrack_rounded, color: Theme.of(context).colorScheme.primary),
                  title: Text(audio, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  trailing: prayer.customAudioName == audio
                      ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    final notifier = ref.read(detailedNotificationSettingsProvider.notifier);
                    if (isMainPrayer) {
                      notifier.setMainPrayerSound(
                        prayer.id,
                        NotificationSoundType.customDevice,
                        customAudioName: audio,
                      );
                    } else {
                      notifier.setNaflPrayerSound(
                        prayer.id,
                        NotificationSoundType.customDevice,
                        customAudioName: audio,
                      );
                    }
                    Navigator.pop(context);
                    showAppToast(
                      context,
                      '${prayer.name} uchun audio tanlandi: $audio',
                      icon: Icons.audiotrack_rounded,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(detailedNotificationSettingsProvider);
    final notifier = ref.read(detailedNotificationSettingsProvider.notifier);

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        'Bildirishnomalar va Azon',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Global Switch Card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: SwitchListTile(
                        title: const Text(
                          'Barcha bildirishnomalar',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: const Text('Ovozli va matnli eslatmalarni boshqarish'),
                        value: settings.globalEnabled,
                        onChanged: notifier.toggleGlobal,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    if (settings.globalEnabled) ...[
                      // Main Prayer Times Section
                      _SectionTitle('Farz namoz vaqtlari (6 vaqt)'),
                      const SizedBox(height: AppSpacing.xs),
                      for (final prayer in settings.mainPrayers)
                        _PrayerNotificationCard(
                          prayer: prayer,
                          isMainPrayer: true,
                          onToggle: (v) => notifier.toggleMainPrayer(prayer.id, v),
                          onSoundTypePicked: (sound) {
                            if (sound == NotificationSoundType.customDevice) {
                              _showAudioPickerSheet(context, ref, prayer, true);
                            } else {
                              notifier.setMainPrayerSound(prayer.id, sound);
                            }
                          },
                          onCustomAudioTap: () => _showAudioPickerSheet(context, ref, prayer, true),
                          onOffsetChanged: (offset) => notifier.setMainPrayerOffset(prayer.id, offset),
                        ),

                      const SizedBox(height: AppSpacing.lg),

                      // Nafl Prayers Section
                      _SectionTitle('Nafil namoz va eslatmalar (Ishroq, Zuho, Tahajjud)'),
                      const SizedBox(height: AppSpacing.xs),
                      for (final prayer in settings.naflPrayers)
                        _PrayerNotificationCard(
                          prayer: prayer,
                          isMainPrayer: false,
                          onToggle: (v) => notifier.toggleNaflPrayer(prayer.id, v),
                          onSoundTypePicked: (sound) {
                            if (sound == NotificationSoundType.customDevice) {
                              _showAudioPickerSheet(context, ref, prayer, false);
                            } else {
                              notifier.setNaflPrayerSound(prayer.id, sound);
                            }
                          },
                          onCustomAudioTap: () => _showAudioPickerSheet(context, ref, prayer, false),
                          onOffsetChanged: (offset) => notifier.setNaflPrayerOffset(prayer.id, offset),
                        ),

                      const SizedBox(height: AppSpacing.lg),

                      // Non-Prayer Notifications Section
                      _SectionTitle('Ilova va Hamjamiyat xabarlari'),
                      const SizedBox(height: AppSpacing.xs),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Ilova yangiliklari', style: TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: const Text('Ilovaga oid muhim yangilik va yangilanishlar'),
                              secondary: Icon(Icons.newspaper_rounded, color: Theme.of(context).colorScheme.primary),
                              value: settings.appNewsEnabled,
                              onChanged: notifier.toggleAppNews,
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              title: const Text('Community (Hamjamiyat) yangi postlari', style: TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: const Text('Jamiyatdagi yangi maqola va munozara eslatmalari'),
                              secondary: Icon(Icons.groups_rounded, color: Theme.of(context).colorScheme.primary),
                              value: settings.communityPostsEnabled,
                              onChanged: notifier.toggleCommunityPosts,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _PrayerNotificationCard extends StatelessWidget {
  final PrayerNotificationConfig prayer;
  final bool isMainPrayer;
  final ValueChanged<bool> onToggle;
  final ValueChanged<NotificationSoundType> onSoundTypePicked;
  final VoidCallback onCustomAudioTap;
  final ValueChanged<int> onOffsetChanged;

  const _PrayerNotificationCard({
    required this.prayer,
    required this.isMainPrayer,
    required this.onToggle,
    required this.onSoundTypePicked,
    required this.onCustomAudioTap,
    required this.onOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final offsetText = prayer.offsetMinutes == 0
        ? 'Vaqtida (0 daq)'
        : prayer.offsetMinutes > 0
            ? '+${prayer.offsetMinutes} daqiqa kechroq'
            : '${prayer.offsetMinutes} daqiqa oldinroq';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  prayer.enabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                  color: prayer.enabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    prayer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Switch(
                  value: prayer.enabled,
                  onChanged: onToggle,
                ),
              ],
            ),
            if (prayer.enabled) ...[
              const Divider(height: 12),
              // Sound selector
              Row(
                children: [
                  const Text('Ovoz:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: Text(NotificationSoundType.defaultSound.label, style: const TextStyle(fontSize: 11)),
                            selected: prayer.sound == NotificationSoundType.defaultSound,
                            onSelected: (_) => onSoundTypePicked(NotificationSoundType.defaultSound),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          const SizedBox(width: 4),
                          ChoiceChip(
                            label: Text(NotificationSoundType.azaan.label, style: const TextStyle(fontSize: 11)),
                            selected: prayer.sound == NotificationSoundType.azaan,
                            onSelected: (_) => onSoundTypePicked(NotificationSoundType.azaan),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          const SizedBox(width: 4),
                          ChoiceChip(
                            label: Text(
                              prayer.sound == NotificationSoundType.customDevice &&
                                      prayer.customAudioName != null &&
                                      prayer.customAudioName!.isNotEmpty
                                  ? prayer.customAudioName!
                                  : NotificationSoundType.customDevice.label,
                              style: const TextStyle(fontSize: 11),
                            ),
                            selected: prayer.sound == NotificationSoundType.customDevice,
                            onSelected: (_) => onCustomAudioTap(),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Time offset adjuster (-+ minutlarda)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Vaqtni sozlash:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 22),
                        color: Theme.of(context).colorScheme.primary,
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          if (prayer.offsetMinutes > -30) {
                            onOffsetChanged(prayer.offsetMinutes - 1);
                          }
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          offsetText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 22),
                        color: Theme.of(context).colorScheme.primary,
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          if (prayer.offsetMinutes < 30) {
                            onOffsetChanged(prayer.offsetMinutes + 1);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
