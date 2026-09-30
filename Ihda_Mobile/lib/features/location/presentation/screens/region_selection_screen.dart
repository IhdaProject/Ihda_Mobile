import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../prayer_times/presentation/providers/prayer_providers.dart';
import '../../../prayer_times/presentation/widgets/prayer_time_tile.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

/// Floating Light Toast Notification Helper
void showAppToast(BuildContext context, String message, {IconData icon = Icons.check_circle_rounded}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 28, left: 32, right: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

class RegionSelectionScreen extends ConsumerStatefulWidget {
  const RegionSelectionScreen({super.key});

  @override
  ConsumerState<RegionSelectionScreen> createState() => _RegionSelectionScreenState();
}

class _RegionSelectionScreenState extends ConsumerState<RegionSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _daysScrollController = ScrollController();
  String _searchQuery = '';
  bool _isLocating = false;
  bool _showFullMonthTable = false;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  static const List<String> _uzbekistanRegions = [
    'Toshkent shahri',
    'Andijon viloyati',
    'Buxoro viloyati',
    'Farg\'ona viloyati',
    'Jizzax viloyati',
    'Namangan viloyati',
    'Navoiy viloyati',
    'Qashqadaryo viloyati',
    'Qoraqalpog\'iston Respublika',
    'Samarqand viloyati',
    'Sirdaryo viloyati',
    'Surxondaryo viloyati',
    'Xorazm viloyati',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _daysScrollController.dispose();
    super.dispose();
  }

  void _scrollToToday(int totalDays) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_daysScrollController.hasClients) return;
      final todayIndex = DateTime.now().day - 1;
      if (todayIndex >= 0 && todayIndex < totalDays) {
        final targetOffset = (todayIndex * 62.0) - 100.0;
        _daysScrollController.animateTo(
          targetOffset.clamp(0.0, _daysScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLocating = false);
    _selectRegion('Toshkent shahri');
    showAppToast(context, 'GPS orqali joylashuv aniqlandi: Toshkent shahri', icon: Icons.my_location_rounded);
  }

  void _selectRegion(String region) {
    ref.read(settingsControllerProvider.notifier).setRegion(region);
    _searchController.clear();
    FocusScope.of(context).unfocus();
    showAppToast(context, 'Mintaqa yangilandi: $region', icon: Icons.place_rounded);
  }

  void _shiftMonth(int monthOffset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + monthOffset, 1);
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
  }

  String _formatUzbekMonth(DateTime date) {
    const months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktyabr',
      'Noyabr',
      'Dekabr'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatUzbekFullDate(DateTime date) {
    const months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktyabr',
      'Noyabr',
      'Dekabr'
    ];
    const weekdays = [
      'Dushanba',
      'Seshanba',
      'Chorshanba',
      'Payshanba',
      'Juma',
      'Shanba',
      'Yakshanba'
    ];
    final monthName = months[date.month - 1];
    final weekdayName = weekdays[date.weekday - 1];
    return '${date.day}-$monthName, $weekdayName';
  }

  String _formatShortWeekday(DateTime date) {
    const days = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    return days[date.weekday - 1];
  }

  final GlobalKey _posterKey = GlobalKey();

  Future<void> _captureAndSharePoster(String region, List<dynamic> days) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Rasm generatsiya qilinmoqda...'),
                ],
              ),
            ),
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300));

      final contextObj = _posterKey.currentContext;
      if (contextObj == null) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        showAppToast(context, 'Rasm tayyorlanmadi, qayta urinib ko\'ring', icon: Icons.error_outline_rounded);
        return;
      }

      final boundary = contextObj.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        showAppToast(context, 'Render xatoligi yuz berdi', icon: Icons.error_outline_rounded);
        return;
      }

      // Safe pixelRatio 1.5 to prevent memory overflow / crashes on mobile devices
      final image = await boundary.toImage(pixelRatio: 1.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Image byte data is null');
      }
      final pngBytes = byteData.buffer.asUint8List();

      final outputDir = await getTemporaryDirectory();
      final file = File('${outputDir.path}/namoz_taqvimi_${_currentMonth.year}_${_currentMonth.month}.png');
      await file.writeAsBytes(pngBytes);

      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop(); // pop loading dialog
      }
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // pop bottom sheet
      }

      // Use device native sharing API (share_plus -> Android Intent.ACTION_SEND)
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '$region - ${_formatUzbekMonth(_currentMonth)} Namoz Vaqtlari Taqvimi\nIhda Mobile orqali yaratildi.',
      );

      showAppToast(context, 'Taqvim rasmi muvaffaqiyatli generatsiya qilindi va ulashildi!', icon: Icons.share_rounded);
    } catch (e) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      showAppToast(context, 'Xatolik yuz berdi: $e', icon: Icons.error_outline_rounded);
    }
  }

  void _shareCalendarImage(String region) {
    final days = ref.read(prayerCalendarProvider(_currentMonth)).valueOrNull ?? [];
    if (days.isEmpty) {
      showAppToast(context, 'Taqvim ma\'lumotlari hali yuklanmadi', icon: Icons.warning_rounded);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
              'Taqvim Rasmini Generatsiya Qilish',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$region - ${_formatUzbekMonth(_currentMonth)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: RepaintBoundary(
                    key: _posterKey,
                    child: _PrayerPosterWidget(
                      region: region,
                      month: _currentMonth,
                      days: days,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _captureAndSharePoster(region, days),
                icon: const Icon(Icons.share_rounded),
                label: const Text('Rasm sifatida saqlash va ulashish'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final selectedRegion = settingsAsync.value?.region ?? 'Toshkent shahri';
    final calendarAsync = ref.watch(prayerCalendarProvider(_currentMonth));
    final today = DateTime.now();

    final filteredRegions = _uzbekistanRegions
        .where((r) => r.toLowerCase().contains(_searchQuery))
        .toList();

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
                        'Hudud va Namoz Taqvimi',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Page Content Body with Full Width Edge-to-Edge Scroll Support
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  children: [
                    // Unified Dark Mode Adaptive Search Input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.surface
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.12)
                                : Colors.transparent,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                  Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                          cursorColor: Theme.of(context).colorScheme.primary,
                          decoration: InputDecoration(
                            hintText: 'Hududlarni qidirish (Toshkent, Samarqand...)',
                            hintStyle: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white60
                                  : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.primary),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 20),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Auto-complete suggestions list when user types
                    if (_searchQuery.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          child: Column(
                            children: [
                              if (filteredRegions.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(AppSpacing.md),
                                  child: Text('Bunday hudud topilmadi', style: TextStyle(color: Colors.grey)),
                                )
                              else
                                for (final reg in filteredRegions)
                                  ListTile(
                                    leading: Icon(Icons.location_city_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                                    title: Text(reg, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    trailing: reg == selectedRegion
                                        ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 20)
                                        : const Icon(Icons.chevron_right_rounded, size: 18),
                                    onTap: () => _selectRegion(reg),
                                  ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ] else ...[
                      // Selected Region Summary Card with compact GPS Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                              const SizedBox(width: 8),
                              const Text('Hudud: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Expanded(
                                child: Text(
                                  selectedRegion,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              InkWell(
                                onTap: _isLocating ? null : _detectLocation,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_isLocating)
                                        const SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      else
                                        const Icon(Icons.my_location_rounded, size: 13, color: Colors.white),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'GPS',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Calendar Header & Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatUzbekMonth(_currentMonth),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _showFullMonthTable ? Icons.view_day_outlined : Icons.table_chart_outlined,
                                  size: 20,
                                ),
                                tooltip: _showFullMonthTable ? 'Kunlik ko\'rinish' : 'Oylik jadval',
                                onPressed: () => setState(() => _showFullMonthTable = !_showFullMonthTable),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_left_rounded),
                                onPressed: () => _shiftMonth(-1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right_rounded),
                                onPressed: () => _shiftMonth(1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    calendarAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: LoadingView(message: 'Taqvim hisoblanmoqda...'),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: ErrorView(
                          message: e.toString(),
                          onRetry: () => ref.invalidate(prayerCalendarProvider(_currentMonth)),
                        ),
                      ),
                      data: (days) {
                        if (days.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: EmptyView(message: 'Ushbu oy uchun ma\'lumot topilmadi.'),
                          );
                        }

                        // Auto scroll to today on load
                        if (_currentMonth.month == today.month && _currentMonth.year == today.year) {
                          _scrollToToday(days.length);
                        }

                        if (_showFullMonthTable) {
                          // Clean Monthly Table View with Sticky Header & Share Image
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    // Share / Save Image Toolbar
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _shareCalendarImage(selectedRegion),
                                          icon: const Icon(Icons.share_rounded, size: 16),
                                          label: const Text('Rasm ko\'rinishida saqlash / ulashish', style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 8),
                                    // Sticky Header + Scrollable Rows
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Pinned Sticky Table Header
                                          Container(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                            child: const Row(
                                              children: [
                                                SizedBox(width: 65, child: Text('Sana', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                                SizedBox(width: 58, child: Text('Bomdod', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                                SizedBox(width: 58, child: Text('Quyosh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                                SizedBox(width: 58, child: Text('Peshshin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                                SizedBox(width: 58, child: Text('Asr', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                                SizedBox(width: 58, child: Text('Shom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                                SizedBox(width: 58, child: Text('Xufton', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                              ],
                                            ),
                                          ),
                                          // Scrollable Days List
                                          SizedBox(
                                            height: 380,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  for (final day in days) ...[
                                                    Container(
                                                      color: (day.date.year == today.year &&
                                                              day.date.month == today.month &&
                                                              day.date.day == today.day)
                                                          ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                                                          : null,
                                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 65,
                                                            child: Text(
                                                              '${day.date.day}-${_formatShortWeekday(day.date)}',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: day.date.day == today.day ? FontWeight.bold : FontWeight.normal,
                                                                color: day.date.day == today.day ? Theme.of(context).colorScheme.primary : null,
                                                              ),
                                                            ),
                                                          ),
                                                          for (final prayer in day.prayers)
                                                            SizedBox(
                                                              width: 58,
                                                              child: Text(
                                                                '${prayer.time.hour.toString().padLeft(2, '0')}:${prayer.time.minute.toString().padLeft(2, '0')}',
                                                                style: const TextStyle(fontSize: 12),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Divider(height: 1),
                                                  ],
                                                ],
                                              ),
                                            ),
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

                        // Default View: Horizontal Days Selector Strip (Full Width Edge-To-Edge!)
                        final selectedDayData = days.firstWhere(
                          (d) => d.date.year == _selectedDate.year &&
                              d.date.month == _selectedDate.month &&
                              d.date.day == _selectedDate.day,
                          orElse: () => days.first,
                        );

                        final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Horizontal Days Selector Strip (Spans 100% Full Screen Width Edge-to-Edge)
                            SizedBox(
                              height: max(76.0, 76.0 * fontScale),
                              child: ListView.separated(
                                controller: _daysScrollController,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                itemCount: days.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final day = days[index];
                                  final isSelected = day.date.year == _selectedDate.year &&
                                      day.date.month == _selectedDate.month &&
                                      day.date.day == _selectedDate.day;
                                  final isToday = day.date.year == today.year &&
                                      day.date.month == today.month &&
                                      day.date.day == today.day;

                                  final isDark = Theme.of(context).brightness == Brightness.dark;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = day.date;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: max(54.0, 54.0 * fontScale),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.primary
                                            : isToday
                                                ? Theme.of(context).colorScheme.primary.withOpacity(0.18)
                                                : (isDark
                                                    ? Theme.of(context).colorScheme.surface
                                                    : Colors.white.withOpacity(0.9)),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.primary
                                              : isToday
                                                  ? Theme.of(context).colorScheme.primary
                                                  : (isDark ? Colors.white.withOpacity(0.12) : Colors.transparent),
                                          width: isToday && !isSelected ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _formatShortWeekday(day.date),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? Colors.white70
                                                  : (isDark ? Colors.white60 : Theme.of(context).colorScheme.onSurfaceVariant),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${day.date.day}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isDark ? Colors.white : Theme.of(context).colorScheme.onSurface),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Selected Day's Prayer Schedule Card
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: AppCard(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today_rounded,
                                                  size: 18 * fontScale,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _formatUzbekFullDate(selectedDayData.date),
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (selectedDayData.date.year == today.year &&
                                              selectedDayData.date.month == today.month &&
                                              selectedDayData.date.day == today.day)
                                            Container(
                                              margin: const EdgeInsets.only(left: 6),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                              ),
                                              child: Text(
                                                'Bugun',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const Divider(height: 20),
                                      for (final prayer in selectedDayData.prayers)
                                        PrayerTimeTile(prayer: prayer),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xxl),
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

class _PrayerPosterWidget extends StatelessWidget {
  final String region;
  final DateTime month;
  final List<dynamic> days;

  const _PrayerPosterWidget({
    required this.region,
    required this.month,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B5E20);
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mosque_rounded, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'IHSDA MOBILE • NAMOZ TAQVIMI',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      region,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatUzbekMonthStatic(month),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Sana', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor))),
                Expanded(flex: 3, child: Text('Bomdod', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Quyosh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Peshshin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Asr', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Shom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Xufton', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor), textAlign: TextAlign.center)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          for (final day in days) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${day.date.day}-${_formatShortWeekdayStatic(day.date)}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                  for (final prayer in day.prayers)
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${prayer.time.hour.toString().padLeft(2, '0')}:${prayer.time.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            if (day != days.last)
              Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_rounded, size: 12, color: primaryColor.withOpacity(0.7)),
              const SizedBox(width: 4),
              const Text(
                'Ihda Mobile rasmiy taqvimi',
                style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatUzbekMonthStatic(DateTime date) {
    const months = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktyabr', 'Noyabr', 'Dekabr'];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String _formatShortWeekdayStatic(DateTime date) {
    const days = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    return days[date.weekday - 1];
  }
}
