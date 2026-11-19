import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../domain/entities/notification_settings.dart';
import '../providers/notification_providers.dart';
import '../providers/notification_scheduler.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _hasPermission = false;
  bool _checkingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final ds = ref.read(notificationDataSourceProvider);
    final granted = await ds.hasPermissions();
    if (mounted) {
      setState(() {
        _hasPermission = granted;
        _checkingPermission = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final ds = ref.read(notificationDataSourceProvider);
    final granted = await ds.requestPermissions();
    if (mounted) {
      setState(() {
        _hasPermission = granted;
      });
      if (granted) {
        showAppToast(
          context,
          'Bildirishnomalarga ruxsat berildi! ✅',
          icon: Icons.check_circle_rounded,
        );
      } else {
        showAppToast(
          context,
          'Sozlamalar bo\'limidan bildirishnomalarga ruxsat bering',
          icon: Icons.warning_amber_rounded,
        );
      }
    }
  }

  Future<void> _pickCustomAudioFile(PrayerNotificationConfig prayer, bool isMainPrayer) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;

        final notifier = ref.read(detailedNotificationSettingsProvider.notifier);
        if (isMainPrayer) {
          notifier.setMainPrayerSound(
            prayer.id,
            NotificationSoundType.customDevice,
            customAudioName: filePath,
          );
        } else {
          notifier.setNaflPrayerSound(
            prayer.id,
            NotificationSoundType.customDevice,
            customAudioName: filePath,
          );
        }

        if (mounted) {
          showAppToast(
            context,
            'Audio fayl tanlandi: $fileName',
            icon: Icons.audiotrack_rounded,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showAppToast(
          context,
          'Fayl tanlashda xatolik yuz berdi',
          icon: Icons.error_outline_rounded,
        );
      }
    }
  }

  Future<void> _testSound(PrayerNotificationConfig prayer) async {
    final ds = ref.read(notificationDataSourceProvider);
    final title = prayer.formatTitle(prayer.name, '12:30');
    final body = prayer.formatBody(prayer.name, '12:30');

    await ds.showImmediateTestNotification(
      title: '$title (Sinov)',
      body: body,
      soundType: prayer.sound,
      customAudioPath: prayer.customAudioName,
      targetRoute: prayer.targetRoute,
      payload: '{"prayerId":"${prayer.id}","test":true}',
    );

    if (mounted) {
      showAppToast(
        context,
        'Sinov bildirishnomasi yuborildi! 🔔',
        icon: Icons.notifications_active_rounded,
      );
    }
  }

  Future<void> _test10SecNotification(PrayerNotificationConfig prayer) async {
    final ds = ref.read(notificationDataSourceProvider);
    final title = prayer.formatTitle(prayer.name, '12:30');
    final body = prayer.formatBody(prayer.name, '12:30');

    await ds.schedule10SecondTestNotification(
      title: '⏱️ 10-Soniyali Sinov: $title',
      body: '$body (10 soniyadan so\'ng kelgan eslatma)',
      soundType: prayer.sound,
      customAudioPath: prayer.customAudioName,
      targetRoute: prayer.targetRoute,
      payload: '{"prayerId":"${prayer.id}","test10s":true}',
    );

    if (mounted) {
      showAppToast(
        context,
        '10 soniyadan so\'ng sinov eslatmasi keladi ⏳',
        icon: Icons.timer_rounded,
      );
    }
  }

  Future<void> _rescheduleAll() async {
    await rescheduleAllReminders(ref);
    if (mounted) {
      showAppToast(
        context,
        'Barcha namoz eslatmalari qayta rejalashtirildi! 🔄',
        icon: Icons.sync_rounded,
      );
    }
  }

  void _showEditTemplatesDialog(PrayerNotificationConfig prayer, bool isMainPrayer) {
    final titleController = TextEditingController(text: prayer.titleTemplate ?? '');
    final bodyController = TextEditingController(text: prayer.bodyTemplate ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${prayer.name} Matn Sozlamalari'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mavjud o\'zgaruvchilar: {prayerName}, {time}',
                style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Sarlavha (Title)',
                  hintText: '{prayerName} kirishi (Namoz vaqti)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Matn (Body)',
                  hintText: 'Hozir {prayerName} vaqti kirdi. Soat {time}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              final notifier = ref.read(detailedNotificationSettingsProvider.notifier);
              if (isMainPrayer) {
                notifier.setMainPrayerTemplates(
                  prayer.id,
                  titleTemplate: titleController.text.trim(),
                  bodyTemplate: bodyController.text.trim(),
                );
              } else {
                notifier.setNaflPrayerTemplates(
                  prayer.id,
                  titleTemplate: titleController.text.trim(),
                  bodyTemplate: bodyController.text.trim(),
                );
              }
              Navigator.of(ctx).pop();
              showAppToast(context, 'Matn sozlamalari saqlandi ✅');
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(detailedNotificationSettingsProvider);
    final notifier = ref.read(detailedNotificationSettingsProvider.notifier);

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                    IconButton(
                      icon: const Icon(Icons.sync_rounded),
                      tooltip: 'Qayta rejalashtirish',
                      onPressed: _rescheduleAll,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // System Permission Status Card
                    Card(
                      elevation: 0,
                      color: _hasPermission
                          ? Colors.green.withOpacity(0.08)
                          : Colors.orange.withOpacity(0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        side: BorderSide(
                          color: _hasPermission
                              ? Colors.green.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.4),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(
                              _hasPermission
                                  ? Icons.verified_user_rounded
                                  : Icons.notification_important_rounded,
                              color: _hasPermission ? Colors.green : Colors.orange,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _hasPermission
                                        ? 'Tizim bildirishnomalariga ruxsat berilgan'
                                        : 'Bildirishnomalarga ruxsat berilmagan',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _hasPermission
                                        ? 'Namoz vaqtida avtomatik ovozli eslatmalar chiqadi'
                                        : 'Azon va eslatmalar chiqishi uchun ruxsat bering',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            if (!_hasPermission && !_checkingPermission)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _requestPermission,
                                child: const Text('Ruxsat berish', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Reschedule & Quick Test Card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.sync_rounded, size: 18),
                                label: const Text('Barcha Eslatmalarni Yangilash', style: TextStyle(fontSize: 12)),
                                onPressed: _rescheduleAll,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.timer_rounded, size: 18),
                                label: const Text('10s Sinov', style: TextStyle(fontSize: 12)),
                                onPressed: () {
                                  final firstMain = settings.mainPrayers.firstWhere((p) => p.enabled, orElse: () => settings.mainPrayers.first);
                                  _test10SecNotification(firstMain);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

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
                      const _SectionTitle('Farz namoz vaqtlari (6 vaqt)'),
                      const SizedBox(height: AppSpacing.xs),
                      for (final prayer in settings.mainPrayers)
                        _PrayerNotificationCard(
                          prayer: prayer,
                          isMainPrayer: true,
                          onToggle: (v) => notifier.toggleMainPrayer(prayer.id, v),
                          onSoundTypePicked: (sound) {
                            if (sound == NotificationSoundType.customDevice) {
                              _pickCustomAudioFile(prayer, true);
                            } else {
                              notifier.setMainPrayerSound(prayer.id, sound);
                            }
                          },
                          onCustomAudioTap: () => _pickCustomAudioFile(prayer, true),
                          onOffsetSecsChanged: (secs) => notifier.setMainPrayerOffsetSeconds(prayer.id, secs),
                          onTestSound: () => _testSound(prayer),
                          onTest10s: () => _test10SecNotification(prayer),
                          onEditTemplates: () => _showEditTemplatesDialog(prayer, true),
                        ),

                      const SizedBox(height: AppSpacing.lg),

                      // Nafl Prayers Section
                      const _SectionTitle('Nafil namoz va eslatmalar (Ishroq, Zuho, Tahajjud)'),
                      const SizedBox(height: AppSpacing.xs),
                      for (final prayer in settings.naflPrayers)
                        _PrayerNotificationCard(
                          prayer: prayer,
                          isMainPrayer: false,
                          onToggle: (v) => notifier.toggleNaflPrayer(prayer.id, v),
                          onSoundTypePicked: (sound) {
                            if (sound == NotificationSoundType.customDevice) {
                              _pickCustomAudioFile(prayer, false);
                            } else {
                              notifier.setNaflPrayerSound(prayer.id, sound);
                            }
                          },
                          onCustomAudioTap: () => _pickCustomAudioFile(prayer, false),
                          onOffsetSecsChanged: (secs) => notifier.setNaflPrayerOffsetSeconds(prayer.id, secs),
                          onTestSound: () => _testSound(prayer),
                          onTest10s: () => _test10SecNotification(prayer),
                          onEditTemplates: () => _showEditTemplatesDialog(prayer, false),
                        ),

                      const SizedBox(height: AppSpacing.lg),

                      // Non-Prayer Notifications Section
                      const _SectionTitle('Ilova va Hamjamiyat xabarlari'),
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
  final ValueChanged<int> onOffsetSecsChanged;
  final VoidCallback onTestSound;
  final VoidCallback onTest10s;
  final VoidCallback onEditTemplates;

  const _PrayerNotificationCard({
    required this.prayer,
    required this.isMainPrayer,
    required this.onToggle,
    required this.onSoundTypePicked,
    required this.onCustomAudioTap,
    required this.onOffsetSecsChanged,
    required this.onTestSound,
    required this.onTest10s,
    required this.onEditTemplates,
  });

  String _getFileName(String? path) {
    if (path == null || path.isEmpty) return 'Fayl tanlanmagan';
    final parts = path.split('/');
    return parts.last;
  }

  @override
  Widget build(BuildContext context) {
    final offsetSecs = prayer.offsetSeconds;
    final String offsetText;
    if (offsetSecs == 0) {
      offsetText = '0s (Vaqtida)';
    } else if (offsetSecs > 0) {
      offsetText = '+$offsetSecs soniya';
    } else {
      offsetText = '$offsetSecs soniya';
    }

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
                if (prayer.enabled) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, size: 22),
                    tooltip: 'Matnni tahrirlash',
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: onEditTemplates,
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    tooltip: 'Hozir sinash',
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: onTestSound,
                  ),
                ],
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
                            label: const Text('Standart', style: TextStyle(fontSize: 11)),
                            selected: prayer.sound == NotificationSoundType.defaultSound,
                            onSelected: (_) => onSoundTypePicked(NotificationSoundType.defaultSound),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          const SizedBox(width: 4),
                          ChoiceChip(
                            label: const Text('Azon', style: TextStyle(fontSize: 11)),
                            selected: prayer.sound == NotificationSoundType.azaan,
                            onSelected: (_) => onSoundTypePicked(NotificationSoundType.azaan),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          const SizedBox(width: 4),
                          ChoiceChip(
                            label: const Text('Qisqa', style: TextStyle(fontSize: 11)),
                            selected: prayer.sound == NotificationSoundType.shortChime,
                            onSelected: (_) => onSoundTypePicked(NotificationSoundType.shortChime),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          const SizedBox(width: 4),
                          ChoiceChip(
                            label: const Text('Ovozsiz', style: TextStyle(fontSize: 11)),
                            selected: prayer.sound == NotificationSoundType.silent,
                            onSelected: (_) => onSoundTypePicked(NotificationSoundType.silent),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          const SizedBox(width: 4),
                          ChoiceChip(
                            avatar: const Icon(Icons.folder_open_rounded, size: 14),
                            label: Text(
                              prayer.sound == NotificationSoundType.customDevice &&
                                      prayer.customAudioName != null &&
                                      prayer.customAudioName!.isNotEmpty
                                  ? _getFileName(prayer.customAudioName)
                                  : 'Fayldan',
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
              // Time offset adjuster (-+ soniyalarda)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vaqtni sozlash (sekund):',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 22),
                        color: Theme.of(context).colorScheme.primary,
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          if (prayer.offsetSeconds > -1800) {
                            onOffsetSecsChanged(prayer.offsetSeconds - 30);
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
                          if (prayer.offsetSeconds < 1800) {
                            onOffsetSecsChanged(prayer.offsetSeconds + 30);
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
