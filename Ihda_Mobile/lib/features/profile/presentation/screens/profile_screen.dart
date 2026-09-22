import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../notifications/presentation/screens/notification_settings_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/profile_providers.dart';
import 'account_settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  'Profil',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (auth.isLoggedIn) ...[
                // Logged-in Profile Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          backgroundImage: auth.photoUrl != null && auth.photoUrl!.isNotEmpty
                              ? NetworkImage(auth.photoUrl!)
                              : null,
                          child: auth.photoUrl == null || auth.photoUrl!.isEmpty
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 52,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        auth.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Account settings tile
                _ProfileItemRow(
                  icon: Icons.manage_accounts_outlined,
                  label: 'Account sozlamalari',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
                  ),
                ),
              ] else ...[
                // Logged-out Profile Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Hisobga kirilmagan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Shaxsiy ma\'lumotlaringiz va sozlamalarni saqlash uchun hisobingizga kiring',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showLoginDialog(context, ref),
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('Accauntiga kirish'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Notifications moved directly to Profile
              _ProfileItemRow(
                icon: Icons.notifications_none_rounded,
                label: 'Bildirishnomalar va Azon eslatmalari',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                ),
              ),

              // General Settings
              _ProfileItemRow(
                icon: Icons.settings_outlined,
                label: 'Sozlamalar',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),

              if (auth.isLoggedIn) ...[
                _ProfileItemRow(
                  icon: Icons.logout_rounded,
                  label: 'Chiqish',
                  color: Theme.of(context).colorScheme.error,
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hisobdan chiqish'),
                      content: const Text('Hisobingizdan chiqib ketishga ishonchingiz komilmi?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Bekor qilish'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(authProvider.notifier).logout();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Hisobdan chiqildi')),
                            );
                          },
                          child: Text(
                            'Chiqish',
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static void _showLoginDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: 'Ali Valiyev');
    final emailController = TextEditingController(text: 'ali.valiyev@ihda.uz');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
          top: AppSpacing.md,
          left: AppSpacing.md,
          right: AppSpacing.md,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hisobga kirish',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Ism va familiya',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email manzil',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  if (name.isNotEmpty && email.isNotEmpty) {
                    ref.read(authProvider.notifier).login(name: name, email: email);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hisobga muvaffaqiyatli kirildi')),
                    );
                  }
                },
                child: const Text('Kirish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileItemRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileItemRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
