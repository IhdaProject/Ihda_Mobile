import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../location/presentation/screens/region_selection_screen.dart';
import '../../domain/entities/quran_course_models.dart';
import '../providers/quran_courses_providers.dart';

class ApplicationStatusView extends ConsumerStatefulWidget {
  const ApplicationStatusView({super.key});

  @override
  ConsumerState<ApplicationStatusView> createState() => _ApplicationStatusViewState();
}

class _ApplicationStatusViewState extends ConsumerState<ApplicationStatusView> {
  int _searchTypeIndex = 0; // 0: Ariza Raqami + PINFL, 1: Pasport + PINFL

  final TextEditingController _numberOrPassportController = TextEditingController();
  final TextEditingController _pinflController = TextEditingController();

  CourseApplication? _foundApplication;
  String? _errorMessage;

  @override
  void dispose() {
    _numberOrPassportController.dispose();
    _pinflController.dispose();
    super.dispose();
  }

  void _checkStatus() {
    final keyInput = _numberOrPassportController.text.trim();
    final pinflInput = _pinflController.text.trim();

    if (keyInput.isEmpty || pinflInput.isEmpty) {
      showAppToast(context, 'Ma\'lumotlarni kiriting', icon: Icons.warning_amber_rounded);
      return;
    }

    setState(() {
      _foundApplication = null;
      _errorMessage = null;
    });

    final notifier = ref.read(applicationsProvider.notifier);

    try {
      CourseApplication? app;
      if (_searchTypeIndex == 0) {
        app = notifier.findByAppNumberAndPinfl(keyInput, pinflInput);
      } else {
        app = notifier.findByPassportAndPinfl(keyInput, pinflInput);
      }

      setState(() {
        _foundApplication = app;
      });
      showAppToast(context, 'Ariza ma\'lumotlari topildi!', icon: Icons.check_circle_rounded);
    } catch (_) {
      setState(() {
        _errorMessage = "Arazingiz topilmadi. Ma'lumotlarni qayta tekshirib kiriting.";
      });
      showAppToast(context, 'Ariza topilmadi', icon: Icons.error_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Form Header Box
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.12) : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.search_outlined, size: 20 * fontScale, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Ariza holatini tekshirish usuli:',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Search Method Choice Chips
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Ariza raqami va PINFL', style: TextStyle(fontSize: 11)),
                      selected: _searchTypeIndex == 0,
                      onSelected: (sel) {
                        if (sel) {
                          setState(() {
                            _searchTypeIndex = 0;
                            _numberOrPassportController.clear();
                            _foundApplication = null;
                            _errorMessage = null;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Pasport va PINFL', style: TextStyle(fontSize: 11)),
                      selected: _searchTypeIndex == 1,
                      onSelected: (sel) {
                        if (sel) {
                          setState(() {
                            _searchTypeIndex = 1;
                            _numberOrPassportController.clear();
                            _foundApplication = null;
                            _errorMessage = null;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Key Input (Ariza Raqami or Passport)
              Text(
                _searchTypeIndex == 0
                    ? 'Ariza raqami (Masalan: QR-2025-100101)'
                    : 'Pasport seriyasi va raqami (Masalan: AA 1234567)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _numberOrPassportController,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(
                  color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
                cursorColor: Theme.of(context).colorScheme.primary,
                decoration: InputDecoration(
                  hintText: _searchTypeIndex == 0 ? 'QR-2025-XXXXXX' : 'AA1234567',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey,
                    fontSize: 13,
                  ),
                  fillColor: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // PINFL Input
              const Text(
                'JSHSHIR / PINFL (14 xonali raqam)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _pinflController,
                keyboardType: TextInputType.number,
                maxLength: 14,
                style: TextStyle(
                  color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
                cursorColor: Theme.of(context).colorScheme.primary,
                decoration: InputDecoration(
                  hintText: '30102030405060',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey,
                    fontSize: 13,
                  ),
                  counterText: "",
                  fillColor: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Holatni Tekshirish', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _checkStatus,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Error Message Result Card
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Successful Application Status Result Card
        if (_foundApplication != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _foundApplication!.applicationNumber,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        _foundApplication!.status,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),

                Text(
                  'Arizachi: ${_foundApplication!.lastName} ${_foundApplication!.firstName} ${_foundApplication!.middleName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pasport: ${_foundApplication!.passportSeries} | PINFL: ${_foundApplication!.pinfl}',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey),
                ),
                const SizedBox(height: 10),

                Text(
                  'O\'quv markaz: ${_foundApplication!.centerName}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  'Kurs: ${_foundApplication!.courseTitle}',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_note_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _foundApplication!.estimatedTime,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
