import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../location/presentation/screens/region_selection_screen.dart';
import '../../domain/entities/quran_course_models.dart';
import '../providers/quran_courses_providers.dart';

class QuranCourseApplicationScreen extends ConsumerStatefulWidget {
  final QuranCenter center;
  final QuranCourse course;

  const QuranCourseApplicationScreen({
    super.key,
    required this.center,
    required this.course,
  });

  @override
  ConsumerState<QuranCourseApplicationScreen> createState() =>
      _QuranCourseApplicationScreenState();
}

class _QuranCourseApplicationScreenState
    extends ConsumerState<QuranCourseApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();
  final TextEditingController _pinflController = TextEditingController();

  String _selectedGender = "Erkak";
  String? _passportImagePath;
  String? _photo3x4Path;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _birthYearController.dispose();
    _passportController.dispose();
    _pinflController.dispose();
    super.dispose();
  }

  void _pickPassportImage() {
    setState(() {
      _passportImagePath = "pasport_rasmi_${DateTime.now().millisecondsSinceEpoch}.jpg";
    });
    showAppToast(context, 'Pasport rasmi biriktirildi', icon: Icons.image_rounded);
  }

  void _pick3x4Photo() {
    setState(() {
      _photo3x4Path = "photo_3x4_${DateTime.now().millisecondsSinceEpoch}.jpg";
    });
    showAppToast(context, '3x4 rasm biriktirildi', icon: Icons.portrait_rounded);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      showAppToast(context, 'Barcha majburiy maydonlarni to\'ldiring', icon: Icons.warning_amber_rounded);
      return;
    }

    if (_passportImagePath == null || _photo3x4Path == null) {
      showAppToast(context, 'Pasport va 3x4 rasmlarni biriktiring', icon: Icons.add_a_photo_rounded);
      return;
    }

    final appNumber = ref.read(applicationsProvider.notifier).submitApplication(
          center: widget.center,
          course: widget.course,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          middleName: _middleNameController.text.trim(),
          birthYear: _birthYearController.text.trim(),
          gender: _selectedGender,
          passportSeries: _passportController.text.trim(),
          pinfl: _pinflController.text.trim(),
          passportImagePath: _passportImagePath!,
          photo3x4Path: _photo3x4Path!,
        );

    _showSuccessDialog(appNumber);
  }

  void _showSuccessDialog(String appNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ariza Muvaffaqiyatli Topshirildi!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sizning arizangiz qabul qilindi. Ariza raqamini saqlab qo\'ying:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appNumber,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: appNumber));
                      showAppToast(context, 'Ariza raqami nusxalandi');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'O\'quv markaz: ${widget.center.name}\nKurs: ${widget.course.title}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to center details
              },
              child: const Text('Tushundim, Saqlash'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        'O\'quv Kursiga Ariza Topshirish',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      // Selected Course Summary Box
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanlangan kurs:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.course.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              'Markaz: ${widget.center.name}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Section 1: Personal Info
                      _FormSectionHeader(
                        title: '1. Shaxsiy Ma\'lumotlar',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      _CustomTextField(
                        controller: _lastNameController,
                        label: 'Familiya',
                        hint: 'Masalan: Aliyev',
                        validator: (v) => v == null || v.trim().isEmpty ? 'Familiyani kiriting' : null,
                      ),
                      const SizedBox(height: 10),

                      _CustomTextField(
                        controller: _firstNameController,
                        label: 'Ism',
                        hint: 'Masalan: Ahmad',
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ismni kiriting' : null,
                      ),
                      const SizedBox(height: 10),

                      _CustomTextField(
                        controller: _middleNameController,
                        label: 'Otasining ismi (Sharif)',
                        hint: 'Masalan: Valiyevich',
                        validator: (v) => v == null || v.trim().isEmpty ? 'Otasining ismini kiriting' : null,
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _CustomTextField(
                              controller: _birthYearController,
                              label: 'Tug\'ilgan yil',
                              hint: 'Masalan: 1998',
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Yilni kiriting' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jins',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedGender,
                                      isExpanded: true,
                                      dropdownColor: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                                      items: const [
                                        DropdownMenuItem(value: "Erkak", child: Text("Erkak")),
                                        DropdownMenuItem(value: "Ayol", child: Text("Ayol")),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) setState(() => _selectedGender = v);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Section 2: Document Info
                      _FormSectionHeader(
                        title: '2. Pasport va PINFL Ma\'lumotlari',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      _CustomTextField(
                        controller: _passportController,
                        label: 'Pasport Seriyasi va Raqami',
                        hint: 'Masalan: AA 1234567',
                        textCapitalization: TextCapitalization.characters,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Pasport seriyasini kiriting' : null,
                      ),
                      const SizedBox(height: 10),

                      _CustomTextField(
                        controller: _pinflController,
                        label: 'JSHSHIR / PINFL (14 xonali raqam)',
                        hint: '30102030405060',
                        keyboardType: TextInputType.number,
                        maxLength: 14,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'PINFLni kiriting';
                          if (v.trim().length != 14) return 'PINFL 14 ta raqam bo\'lishi kerak';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Section 3: Document Uploads
                      _FormSectionHeader(
                        title: '3. Hujjat va Rasm Yuklash',
                        icon: Icons.add_a_photo_outlined,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Passport Image Attachment Tile
                      InkWell(
                        onTap: _pickPassportImage,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _passportImagePath != null
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _passportImagePath != null
                                    ? Icons.check_circle_rounded
                                    : Icons.image_search_rounded,
                                color: _passportImagePath != null
                                    ? Theme.of(context).colorScheme.primary
                                    : (isDark ? Colors.white60 : Colors.grey),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pasport rasmini biriktirish',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      _passportImagePath ?? 'Rasmni tanlash uchun bosing',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _passportImagePath != null
                                            ? Theme.of(context).colorScheme.primary
                                            : (isDark ? Colors.white60 : Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.upload_file_rounded, color: Theme.of(context).colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3x4 Photo Attachment Tile
                      InkWell(
                        onTap: _pick3x4Photo,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _photo3x4Path != null
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _photo3x4Path != null
                                    ? Icons.check_circle_rounded
                                    : Icons.portrait_rounded,
                                color: _photo3x4Path != null
                                    ? Theme.of(context).colorScheme.primary
                                    : (isDark ? Colors.white60 : Colors.grey),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '3x4 rasm biriktirish',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      _photo3x4Path ?? 'Rasmni tanlash uchun bosing',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _photo3x4Path != null
                                            ? Theme.of(context).colorScheme.primary
                                            : (isDark ? Colors.white60 : Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.upload_file_rounded, color: Theme.of(context).colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                          ),
                          icon: const Icon(Icons.send_rounded),
                          label: const Text(
                            'Arizani Topshirish',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: _submit,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _FormSectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final FormFieldValidator<String>? validator;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          validator: validator,
          style: TextStyle(
            color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
          cursorColor: Theme.of(context).colorScheme.primary,
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }
}
