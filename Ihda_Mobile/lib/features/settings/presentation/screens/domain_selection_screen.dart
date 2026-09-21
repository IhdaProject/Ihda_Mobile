import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';
import '../providers/settings_providers.dart';

class DomainSelectionScreen extends ConsumerStatefulWidget {
  const DomainSelectionScreen({super.key});

  @override
  ConsumerState<DomainSelectionScreen> createState() => _DomainSelectionScreenState();
}

class _DomainSelectionScreenState extends ConsumerState<DomainSelectionScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final domain = _controller.text.trim();
    if (domain.isEmpty) {
      setState(() => _error = "Domain bo'sh bo'lmasligi kerak");
      return;
    }
    // Simple URL validation
    if (!domain.startsWith('http')) {
      setState(() => _error = "URL 'http' bilan boshlanishi kerak");
      return;
    }

    ref.read(settingsControllerProvider.notifier).setDomain(domain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.language_rounded, size: 80, color: AppColors.primary),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Domainni tanlang',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  "Relizga chiqquncha foydalanish uchun server manzilingizni kiriting",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'https://api.example.com',
                    errorText: _error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Tasdiqlash'),
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
