import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../prayer_times/domain/entities/prayer.dart';
import '../../domain/entities/app_settings.dart';
import '../../../../core/localization/localization_provider.dart';
import '../providers/country_providers.dart';
import '../providers/settings_providers.dart';

import '../../../../shared/widgets/design_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Text(
                          'settings'.tr(ref),
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionLabel('account'.tr(ref)),
                  _NavRow(
                    label: 'edit_profile'.tr(ref),
                    onTap: () => _stub(context),
                  ),
                  _NavRow(
                    label: 'change_password'.tr(ref),
                    onTap: () => _stub(context),
                  ),
                  _NavRow(
                    label: 'privacy'.tr(ref),
                    onTap: () => _stub(context),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionLabel('notification'.tr(ref)),
                  _SwitchRow(
                    label: 'notification'.tr(ref),
                    value: settings.notificationsEnabled,
                    onChanged: controller.setNotificationsEnabled,
                  ),
                  _SwitchRow(
                    label: 'updates'.tr(ref),
                    value: settings.updatesEnabled,
                    onChanged: controller.setUpdatesEnabled,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionLabel('prayer_calculation'.tr(ref)),
                  _NavRow(
                    label: settings.calculationMethod.label,
                    trailingIcon: Icons.chevron_right_rounded,
                    onTap: () => _showMethodPicker(context, ref, settings),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionLabel('other'.tr(ref)),
                  _SwitchRow(
                    label: 'dark_mode'.tr(ref),
                    value: settings.darkMode,
                    onChanged: controller.setDarkMode,
                  ),
                  _NavRow(
                    label: 'language'.tr(ref),
                    trailingText: _languageLabel(settings.languageCode),
                    onTap: () => _showLanguagePicker(context, ref, settings),
                  ),
                  _NavRow(
                    label: 'region'.tr(ref),
                    trailingText: settings.region,
                    onTap: () => _showRegionPicker(context, ref, settings),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static void _stub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ushbu bo'lim preview'da mavjud emas")),
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

  static void _showLanguagePicker(BuildContext context, WidgetRef ref, AppSettings settings) {
    _showPicker(
      context,
      title: 'Language',
      options: const [('en', 'English'), ('uz', "O'zbekcha"), ('ru', 'Русский')],
      current: settings.languageCode,
      onSelected: (value) => ref.read(settingsControllerProvider.notifier).setLanguage(value),
    );
  }

  static void _showRegionPicker(BuildContext context, WidgetRef ref, AppSettings settings) {
    final countriesAsync = ref.read(countriesProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Region', style: Theme.of(context).textTheme.titleLarge),
            ),
            Expanded(
              child: countriesAsync.when(
                data: (countries) => ListView.builder(
                  shrinkWrap: true,
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final country = countries[index];
                    return RadioListTile<String>(
                      value: country.name,
                      groupValue: settings.region,
                      activeColor: Theme.of(context).colorScheme.primary,
                      title: Text(country.name),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(settingsControllerProvider.notifier).setRegion(value);
                        }
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
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
              child: Text('Calculation method', style: Theme.of(context).textTheme.titleLarge),
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

  static void _showPicker(
    BuildContext context, {
    required String title,
    required List<(String, String)> options,
    required String current,
    required void Function(String value) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final (value, label) in options)
              RadioListTile<String>(
                value: value,
                groupValue: current,
                activeColor: Theme.of(context).colorScheme.primary,
                title: Text(label),
                onChanged: (v) {
                  if (v != null) onSelected(v);
                  Navigator.of(context).pop();
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final String? trailingText;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const _NavRow({
    required this.label,
    this.trailingText,
    this.trailingIcon = Icons.chevron_right_rounded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(trailingText!, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 4),
          ],
          Icon(trailingIcon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
