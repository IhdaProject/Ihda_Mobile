import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';
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
                    final controller = ref.read(settingsControllerProvider.notifier);
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
                        _SwitchRow(
                          icon: Icons.dark_mode_outlined,
                          label: 'Tungi rejim (Dark Mode)',
                          value: settings.darkMode,
                          onChanged: controller.setDarkMode,
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
      ('Plus Jakarta Sans', 'Plus Jakarta Sans (Zamonaviy)'),
      ('Poppins', 'Poppins (Yumshoq / Dumaloq)'),
      ('Inter', 'Inter (Aniq va Bop)'),
      ('Nunito', 'Nunito (Nafis)'),
      ('Roboto', 'Roboto (Standart)'),
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Zamonaviy shrift turini tanlang', style: Theme.of(context).textTheme.titleLarge),
            ),
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
            const SizedBox(height: AppSpacing.sm),
          ],
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

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      secondary: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 22 * fontScale,
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      value: value,
      onChanged: onChanged,
    );
  }
}
