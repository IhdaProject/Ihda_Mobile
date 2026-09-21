import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../feed/presentation/screens/notifications_screen.dart';
import '../../../mosques/presentation/screens/favorites_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../providers/profile_providers.dart';

import '../../../../shared/widgets/design_background.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: profileAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(userProfileProvider),
            ),
            data: (profile) => ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.person_rounded, size: 56, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(value: profile.hadithReadCount, label: 'Hadith Read'),
                    _StatColumn(value: profile.followingCount, label: 'Following'),
                    _StatColumn(value: profile.followersCount, label: 'Followers'),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _ProfileTile(
                  icon: Icons.people_outline_rounded,
                  label: 'Tell Your Friends',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ulashish oynasi ushbu preview\'da mavjud emas')),
                  ),
                ),
                _ProfileTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
                _ProfileTile(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notification',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ),
                ),
                _ProfileTile(
                  icon: Icons.link_rounded,
                  label: 'Change Domain',
                  onTap: () => _showDomainDialog(context, ref, settingsAsync.value?.domain),
                ),
                _ProfileTile(
                  icon: Icons.logout_rounded,
                  label: 'Log Out',
                  color: Theme.of(context).colorScheme.error,
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Chiqishni tasdiqlang'),
                      content: const Text('Hisobingizdan chiqishga ishonchingiz komilmi?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Bekor qilish'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Chiqish', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDomainDialog(BuildContext context, WidgetRef ref, String? currentDomain) {
    final controller = TextEditingController(text: currentDomain);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Domainni o\'zgartirish'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://api.example.com',
            labelText: 'API Domain',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              final domain = controller.text.trim();
              if (domain.isNotEmpty) {
                ref.read(settingsControllerProvider.notifier).setDomain(domain);
                Navigator.pop(context);
              }
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final int value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: Theme.of(context).textTheme.displayMedium),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurface),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color)),
      trailing: Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
