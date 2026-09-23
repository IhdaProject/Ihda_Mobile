import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../data/datasources/mock_quran_courses_data_source.dart';
import '../../domain/entities/quran_course_models.dart';
import '../providers/quran_courses_providers.dart';
import 'application_status_screen.dart';
import 'quran_center_detail_screen.dart';

class QuranCoursesScreen extends ConsumerStatefulWidget {
  const QuranCoursesScreen({super.key});

  @override
  ConsumerState<QuranCoursesScreen> createState() => _QuranCoursesScreenState();
}

class _QuranCoursesScreenState extends ConsumerState<QuranCoursesScreen> {
  int _selectedTabIndex = 0; // 0: Markazlar, 1: Ariza Holati
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedCountry = ref.watch(selectedCountryProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);
    final selectedDistrict = ref.watch(selectedDistrictProvider);
    final centers = ref.watch(filteredQuranCentersProvider);

    final availableRegions =
        MockQuranCoursesDataSource.regionsByCountry[selectedCountry] ??
            ["Barcha viloyatlar"];
    final availableDistricts =
        MockQuranCoursesDataSource.districtsByRegion[selectedRegion] ??
            ["Barcha tumanlar"];

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
                        'Qur\'on va Fonetika Kurslari',
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

              // Sleek Modern Pill Segmented Control (0: Markazlar / 1: Ariza Holati)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.12)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Tab 0: O'quv Markazlari
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (_selectedTabIndex != 0) {
                              setState(() => _selectedTabIndex = 0);
                            }
                          },
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              "O'quv Markazlari",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _selectedTabIndex == 0
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white70
                                        : Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Tab 1: Ariza Holati
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (_selectedTabIndex != 1) {
                              setState(() => _selectedTabIndex = 1);
                            }
                          },
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              "Ariza Holati",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _selectedTabIndex == 1
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white70
                                        : Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Tab Views
              Expanded(
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    // View 0: Markazlar va Qidiruv
                    ListView(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      children: [
                        // Dark Mode Adaptive Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Theme.of(context).colorScheme.surface
                                  : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.12)
                                    : Colors.transparent,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(
                                color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                fontSize: 13,
                              ),
                              cursorColor: Theme.of(context).colorScheme.primary,
                              onChanged: (val) {
                                ref.read(courseSearchQueryProvider.notifier).state = val;
                              },
                              decoration: InputDecoration(
                                hintText: 'Markaz yoki kurs nomini qidirish...',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.white60
                                      : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          ref.read(courseSearchQueryProvider.notifier).state = "";
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Location Selectors Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_alt_rounded,
                                size: 18 * fontScale,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Hudud bo\'yicha saralash:',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Filter Dropdowns Row (Davlat, Viloyat, Tuman)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Row(
                            children: [
                              // Country Dropdown
                              _FilterChipDropdown(
                                label: selectedCountry,
                                icon: Icons.public_rounded,
                                items: MockQuranCoursesDataSource.countries,
                                onSelected: (val) {
                                  ref.read(selectedCountryProvider.notifier).state = val;
                                  ref.read(selectedRegionProvider.notifier).state = "Barcha viloyatlar";
                                  ref.read(selectedDistrictProvider.notifier).state = "Barcha tumanlar";
                                },
                              ),
                              const SizedBox(width: 8),

                              // Region Dropdown
                              _FilterChipDropdown(
                                label: selectedRegion,
                                icon: Icons.map_rounded,
                                items: availableRegions,
                                onSelected: (val) {
                                  ref.read(selectedRegionProvider.notifier).state = val;
                                  ref.read(selectedDistrictProvider.notifier).state = "Barcha tumanlar";
                                },
                              ),
                              const SizedBox(width: 8),

                              // District Dropdown
                              _FilterChipDropdown(
                                label: selectedDistrict,
                                icon: Icons.location_city_rounded,
                                items: availableDistricts,
                                onSelected: (val) {
                                  ref.read(selectedDistrictProvider.notifier).state = val;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Centers Count Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text(
                            'Mavjud o\'quv maskanlari (${centers.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Centers List
                        if (centers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Center(
                              child: Text(
                                'Tanlangan hudud bo\'yicha o\'quv markazlari topilmadi',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          for (final center in centers) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                              child: _CenterCard(center: center),
                            ),
                          ],

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),

                    // View 1: Ariza Holatini Tekshirish Form
                    const ApplicationStatusView(),
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

class _FilterChipDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String> onSelected;

  const _FilterChipDropdown({
    required this.label,
    required this.icon,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<String>(
      onSelected: onSelected,
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                fontWeight: item == label ? FontWeight.bold : FontWeight.normal,
                color: item == label
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.2)
                : Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _CenterCard extends StatelessWidget {
  final QuranCenter center;

  const _CenterCard({required this.center});

  @override
  Widget build(BuildContext context) {
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => QuranCenterDetailScreen(center: center),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48 * fontScale,
                    height: 48 * fontScale,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24 * fontScale,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          center.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            center.type,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 14 * fontScale, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${center.region}, ${center.district} (${center.address})',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 14 * fontScale, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        '${center.courses.length} ta o\'quv kursi mavjud',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuranCenterDetailScreen(center: center),
                        ),
                      );
                    },
                    child: const Text('Kurslarni ko\'rish',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
