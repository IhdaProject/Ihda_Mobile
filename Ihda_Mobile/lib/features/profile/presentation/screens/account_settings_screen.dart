import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../location/presentation/screens/region_selection_screen.dart';
import '../providers/profile_providers.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  static const List<String> _sampleAvatars = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=300&q=80',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

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
                        'Account sozlamalari',
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
                    const SizedBox(height: AppSpacing.md),
                    // Profile Photo Edit
                    Center(
                      child: Stack(
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
                              radius: 50,
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                              backgroundImage: auth.photoUrl != null && auth.photoUrl!.isNotEmpty
                                  ? NetworkImage(auth.photoUrl!)
                                  : null,
                              child: auth.photoUrl == null || auth.photoUrl!.isEmpty
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: 56,
                                      color: Theme.of(context).colorScheme.primary,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _showPhotoPicker(context, ref),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: TextButton(
                        onPressed: () => _showPhotoPicker(context, ref),
                        child: const Text('Rasmni o\'zgartirish'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Setting Items List
                    _AccountTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Ismni o\'zgartirish',
                      subtitle: auth.name,
                      onTap: () => _showChangeNameDialog(context, ref, auth.name),
                    ),
                    _AccountTile(
                      icon: Icons.email_outlined,
                      title: 'Emailni o\'zgartirish',
                      subtitle: auth.email,
                      onTap: () => _showChangeEmailDialog(context, ref, auth.email),
                    ),
                    _AccountTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Parolni o\'zgartirish',
                      subtitle: '• • • • • • • •',
                      onTap: () => _showChangePasswordDialog(context),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Danger Zone
                    _AccountTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Hisobni o\'chirish',
                      subtitle: 'Hisobingiz va ma\'lumotlaringiz butunlay o\'chiriladi',
                      color: Theme.of(context).colorScheme.error,
                      onTap: () => _showDeleteAccountDialog(context, ref),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showPhotoPicker(BuildContext context, WidgetRef ref) {
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
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Profil rasmini tanlang',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: Theme.of(context).colorScheme.primary),
                title: const Text('Galereyadan tanlash'),
                onTap: () {
                  ref.read(authProvider.notifier).updatePhoto(_sampleAvatars[0]);
                  Navigator.pop(context);
                  showAppToast(context, 'Profil rasmi galereyadan yangilandi', icon: Icons.photo_camera_rounded);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: Theme.of(context).colorScheme.primary),
                title: const Text('Kameradan rasmga olish'),
                onTap: () {
                  ref.read(authProvider.notifier).updatePhoto(_sampleAvatars[1]);
                  Navigator.pop(context);
                  showAppToast(context, 'Kameradan yangi profil rasmi olindi', icon: Icons.camera_alt_rounded);
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle_rounded, color: Theme.of(context).colorScheme.primary),
                title: const Text('Boshlang\'ich avatar rasmga o\'tkazish'),
                onTap: () {
                  ref.read(authProvider.notifier).updatePhoto('');
                  Navigator.pop(context);
                  showAppToast(context, 'Profil rasmi standart holatga keltirildi', icon: Icons.person_rounded);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showChangeNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ismni o\'zgartirish'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Yangi ism va familiya'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final auth = ref.read(authProvider);
                ref.read(authProvider.notifier).updateProfile(name: newName, email: auth.email);
                Navigator.pop(context);
                showAppToast(context, 'Ismingiz saqlandi: $newName', icon: Icons.check_circle_rounded);
              }
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  static void _showChangeEmailDialog(BuildContext context, WidgetRef ref, String currentEmail) {
    final controller = TextEditingController(text: currentEmail);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emailni o\'zgartirish'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Yangi email manzil'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              final newEmail = controller.text.trim();
              if (newEmail.isNotEmpty) {
                final auth = ref.read(authProvider);
                ref.read(authProvider.notifier).updateProfile(name: auth.name, email: newEmail);
                Navigator.pop(context);
                showAppToast(context, 'Emailingiz saqlandi: $newEmail', icon: Icons.email_rounded);
              }
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  static void _showChangePasswordDialog(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Parolni o\'zgartirish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Hozirgi parol'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Yangi parol'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              if (currentPassController.text.isNotEmpty && newPassController.text.isNotEmpty) {
                Navigator.pop(context);
                showAppToast(context, 'Parol muvaffaqiyatli o\'zgartirildi', icon: Icons.lock_reset_rounded);
              }
            },
            child: const Text('Yangilash'),
          ),
        ],
      ),
    );
  }

  static void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hisobni o\'chirish'),
        content: const Text('Hisobingizni o\'chirib tashlashga ishonchingiz komilmi? Bu amalni ortga qaytarib bo\'lmaydi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close Account Settings page
              showAppToast(context, 'Hisobingiz o\'chirildi', icon: Icons.delete_forever_rounded);
            },
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: color?.withOpacity(0.8) ?? Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 13,
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
