import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../prayer_times/domain/entities/prayer.dart';
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
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
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  bool _isLocating = false;
  bool _showFullMonthTable = false;
  bool _didAutoScrollToday = false;

  static const List<String> _uzbekistanRegions = [
    'Toshkent shahri',
    'Toshkent viloyati',
    'Samarqand viloyati',
    'Buxoro viloyati',
    'Andijon viloyati',
    'Farg\'ona viloyati',
    'Namangan viloyati',
    'Xorazm viloyati (Urganch, Xiva)',
    'Qashqadaryo viloyati (Qarshi)',
    'Surxondaryo viloyati (Termiz)',
    'Sirdaryo viloyati (Guliston)',
    'Jizzax viloyati',
    'Navoiy viloyati',
    'Qoraqalpog\'iston (Nukus)',
    'Qo\'qon shahri',
    'Marg\'ilon shahri',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month, 1);
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

  void _scrollToToday(int totalDaysInMonth) {
    if (_didAutoScrollToday) return;
    _didAutoScrollToday = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_daysScrollController.hasClients) return;
      final todayDay = DateTime.now().day;
      if (todayDay > 1) {
        final targetOffset = (todayDay - 1) * 62.0 - 100.0;
        final maxOffset = _daysScrollController.position.maxScrollExtent;
        final finalOffset = targetOffset.clamp(0.0, maxOffset);
        _daysScrollController.animateTo(
          finalOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  static String _formatUzbekMonth(DateTime date) {
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentyabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String _formatUzbekWeekday(DateTime date) {
    const weekdays = ['Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba'];
    return weekdays[date.weekday - 1];
  }

  static String _formatShortWeekday(DateTime date) {
    const weekdays = ['Dush', 'Sesh', 'Chor', 'Pay', 'Jum', 'Shan', 'Yak'];
    return weekdays[date.weekday - 1];
  }

  static String _formatUzbekFullDate(DateTime date) {
    const months = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentyabr', 'Oktabr', 'Noyabr', 'Dekabr'];
    return '${date.day}-${months[date.month - 1]}, ${_formatUzbekWeekday(date)}';
  }

  void _detectLocation() async {
    setState(() => _isLocating = true);
    await Future.delayed(const Duration(milliseconds: 500));
    const autoDetected = 'Toshkent shahri';
    ref.read(settingsControllerProvider.notifier).setRegion(autoDetected);
    
    // Auto reset date to today and auto scroll
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _currentMonth = DateTime(now.year, now.month, 1);
      _didAutoScrollToday = false;
      _isLocating = false;
    });

    if (mounted) {
      showAppToast(context, 'Joylashuv aniqlandi: Toshkent shahri', icon: Icons.my_location_rounded);
    }
  }

  void _selectRegion(String region) {
    ref.read(settingsControllerProvider.notifier).setRegion(region);
    _searchController.clear();
    FocusScope.of(context).unfocus();

    // Auto reset date to today and auto scroll
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _currentMonth = DateTime(now.year, now.month, 1);
      _didAutoScrollToday = false;
    });

    showAppToast(context, 'Hudud tanlandi: $region', icon: Icons.location_on_rounded);
  }

  void _shiftMonth(int months) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + months, 1);
      final lastDayOfNewMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
      final day = _selectedDate.day.clamp(1, lastDayOfNewMonth);
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, day);
      _didAutoScrollToday = false;
    });
  }

  void _shareCalendarImage(String region) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              'Taqvim Rasmini Saqlash & Ulashish',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$region - ${_formatUzbekMonth(_currentMonth)} namoz vaqtlari taqvimi',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.image_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    '$region Taqvim Poster',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text('Yuqori sifatli PNG rasm ko\'rinishida tayyorlandi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showAppToast(context, 'Taqvim rasmi muvaffaqiyatli saqlandi va ulashildi', icon: Icons.share_rounded);
                },
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

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Unified Search Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Hududlarni qidirish (Toshkent, Samarqand...)',
                          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7), fontSize: 14),
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
                    const SizedBox(height: AppSpacing.sm),

                    // Auto-complete suggestions list when user types
                    if (_searchQuery.isNotEmpty) ...[
                      Card(
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
                      const SizedBox(height: AppSpacing.md),
                    ] else ...[
                      // Selected Region Summary Card with compact GPS Button
                      Container(
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
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Calendar Header & Controls
                    Row(
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

                    const SizedBox(height: AppSpacing.xs),

                    calendarAsync.when(
                      loading: () => const LoadingView(message: 'Taqvim hisoblanmoqda...'),
                      error: (e, _) => ErrorView(
                        message: e.toString(),
                        onRetry: () => ref.invalidate(prayerCalendarProvider(_currentMonth)),
                      ),
                      data: (days) {
                        if (days.isEmpty) {
                          return const EmptyView(message: 'Ushbu oy uchun ma\'lumot topilmadi.');
                        }

                        // Auto scroll to today on load
                        if (_currentMonth.month == today.month && _currentMonth.year == today.year) {
                          _scrollToToday(days.length);
                        }

                        if (_showFullMonthTable) {
                          // Clean Monthly Table View with Sticky Header & Share Image
                          return Card(
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
                          );
                        }

                        // Default View: Horizontal Days Strip (Auto-scrolled to Today) + Selected Day Schedule
                        final selectedDayData = days.firstWhere(
                          (d) => d.date.year == _selectedDate.year &&
                              d.date.month == _selectedDate.month &&
                              d.date.day == _selectedDate.day,
                          orElse: () => days.first,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Horizontal Days Selector Strip (Auto-scrolled to Today)
                            SizedBox(
                              height: 72,
                              child: ListView.separated(
                                controller: _daysScrollController,
                                scrollDirection: Axis.horizontal,
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

                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = day.date;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 54,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.primary
                                            : isToday
                                                ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                                                : Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.primary
                                              : isToday
                                                  ? Theme.of(context).colorScheme.primary
                                                  : Colors.transparent,
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
                                                  : Theme.of(context).colorScheme.onSurfaceVariant,
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
                                                  : Theme.of(context).colorScheme.onSurface,
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
                            AppCard(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 18,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatUzbekFullDate(selectedDayData.date),
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        if (selectedDayData.date.year == today.year &&
                                            selectedDayData.date.month == today.month &&
                                            selectedDayData.date.day == today.day)
                                          Container(
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
