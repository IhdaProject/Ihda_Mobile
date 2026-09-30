import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../../shared/widgets/blurred_bottom_sheet.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../location/presentation/screens/region_selection_screen.dart';
import '../../../prayer_times/domain/entities/prayer.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

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
                        'Sozlamalar',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: settingsAsync.when(
                  loading: () => const LoadingView(),
                  error: (e, _) => ErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(settingsControllerProvider),
                  ),
                  data: (settings) {
                    return ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        _SectionHeader('Namoz va taqvim sozlamalari'),
                        _SettingRow(
                          icon: Icons.location_on_outlined,
                          label: 'Mintaqa / Hudud',
                          trailingText: settings.region,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegionSelectionScreen()),
                          ),
                        ),
                        _SettingRow(
                          icon: Icons.calculate_outlined,
                          label: 'Vaqtlarni hisoblash uslubi',
                          trailingText: settings.calculationMethod.label,
                          onTap: () => _showMethodPicker(context, ref, settings),
                        ),
                        _SettingRow(
                          icon: Icons.balance_rounded,
                          label: 'Asr namozi mazhabi',
                          trailingText: settings.asrCalculation.label,
                          onTap: () => _showAsrPicker(context, ref, settings),
                        ),

                        const SizedBox(height: AppSpacing.lg),
                        _SectionHeader('Ilova va shrift sozlamalari'),
                        _SettingRow(
                          icon: Icons.brightness_auto_rounded,
                          label: 'Ilova rejimi (Theme Mode)',
                          trailingText: settings.themeMode.label,
                          onTap: () => _showThemeModePicker(context, ref, settings),
                        ),
                        _SettingRow(
                          icon: Icons.format_size_rounded,
                          label: 'Matn kattaligi (Font Size)',
                          trailingText: settings.fontSize.label,
                          onTap: () => _showFontSizePicker(context, ref, settings),
                        ),
                        _SettingRow(
                          icon: Icons.font_download_rounded,
                          label: 'Matn shrift turi (Font Family)',
                          trailingText: settings.fontFamily,
                          onTap: () => _showFontFamilyPicker(context, ref, settings),
                        ),
                        _SettingRow(
                          icon: Icons.language_rounded,
                          label: 'Ilova tili',
                          trailingText: _languageLabel(settings.languageCode),
                          onTap: () => _showLanguagePicker(context, ref, settings),
                        ),
                        _SettingRow(
                          icon: Icons.dns_rounded,
                          label: 'Domainni o\'zgartirish',
                          trailingText: settings.domain,
                          onTap: () => _showDomainDialog(context, ref, settings.domain),
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _languageLabel(String code) {
    switch (code) {
      case 'uz':
        return "O'zbekcha";
      case 'ru':
        return 'Русский';
      default:
        return 'English';
    }
  }

  static void _showThemeModePicker(BuildContext context, WidgetRef ref, AppSettings settings) {
    showBlurredBottomSheet(
      context: context,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Ilova rejimini tanlang', style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final mode in AppThemeMode.values)
              RadioListTile<AppThemeMode>(
                value: mode,
                groupValue: settings.themeMode,
                activeColor: Theme.of(context).colorScheme.primary,
                title: Text(mode.label),
                onChanged: (v) {
                  if (v != null) {
                    ref.read(settingsControllerProvider.notifier).setThemeMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  static void _showFontSizePicker(BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Matn kattaligi', style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final size in AppFontSize.values)
              RadioListTile<AppFontSize>(
                value: size,
                groupValue: settings.fontSize,
                activeColor: Theme.of(context).colorScheme.primary,
                title: Text(size.label),
                onChanged: (v) {
                  if (v != null) {
                    ref.read(settingsControllerProvider.notifier).setFontSize(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  static void _showFontFamilyPicker(BuildContext context, WidgetRef ref, AppSettings settings) {
    final fonts = [
      ('Plus Jakarta Sans', 'Plus Jakarta Sans (Zamonaviy geometrik)'),
      ('Poppins', 'Poppins (Yumshoq va ommabop)'),
      ('Inter', 'Inter (Minimalist va professional)'),
      ('Montserrat', 'Montserrat (Elegant va urban)'),
      ('Outfit', 'Outfit (Yangi avlod dizayn)'),
      ('Nunito', 'Nunito (Nafis va do\'stona)'),
      ('Quicksand', 'Quicksand (Dumaloq va yengil)'),
      ('Lexend', 'Lexend (O\'qish uchun maxsus)'),
      ('DM Sans', 'DM Sans (Geometrik va toza)'),
      ('Roboto', 'Roboto (Standart)'),
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text('Zamonaviy va turlicha shriftlarni tanlang', style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    for (final (fontKey, fontLabel) in fonts)
                      RadioListTile<String>(
                        value: fontKey,
                        groupValue: settings.fontFamily,
                        activeColor: Theme.of(context).colorScheme.primary,
                        title: Text(
                          fontLabel,
                          style: GoogleFonts.getFont(
                            fontKey,
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        onChanged: (v) {
                          if (v != null) {
                            ref.read(settingsControllerProvider.notifier).setFontFamily(v);
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  static void _showLanguagePicker(BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Ilova tili', style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final (value, label) in const [('uz', "O'zbekcha"), ('ru', 'Русский'), ('en', 'English')])
              RadioListTile<String>(
                value: value,
                groupValue: settings.languageCode,
                activeColor: Theme.of(context).colorScheme.primary,
                title: Text(label),
                onChanged: (v) {
                  if (v != null) {
                    ref.read(settingsControllerProvider.notifier).setLanguage(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  static void _showMethodPicker(BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Hisoblash uslubi', style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final method in CalculationMethod.values)
              RadioListTile<CalculationMethod>(
                value: method,
                groupValue: settings.calculationMethod,
                activeColor: Theme.of(context).colorScheme.primary,
                title: Text(method.label),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsControllerProvider.notifier).setCalculationMethod(value);
                  }
                  Navigator.of(context).pop();
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  static void _showAsrPicker(BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Asr namozi mazhab hisobi', style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final asr in AsrCalculation.values)
              RadioListTile<AsrCalculation>(
                value: asr,
                groupValue: settings.asrCalculation,
                activeColor: Theme.of(context).colorScheme.primary,
                title: Text(asr.label),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsControllerProvider.notifier).setAsrCalculation(value);
                  }
                  Navigator.of(context).pop();
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  static void _showDomainDialog(BuildContext context, WidgetRef ref, String currentDomain) {
    final controller = TextEditingController(text: currentDomain);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Domainni o\'zgartirish'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'ihda.uz',
            labelText: 'API Domain',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              final domain = controller.text.trim();
              if (domain.isNotEmpty) {
                ref.read(settingsControllerProvider.notifier).setDomain(domain);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Domain saqlandi: $domain')),
                );
              }
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 22 * fontScale,
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 140 * fontScale),
                child: Text(
                  trailingText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20 * fontScale,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
