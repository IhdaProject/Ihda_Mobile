import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/feed/domain/entities/feed_item.dart';
import '../../features/feed/presentation/screens/community_screen.dart';
import '../../features/feed/presentation/screens/hadith_duas_screen.dart';
import '../../features/finance/presentation/screens/finance_screen.dart';
import '../../features/important_dates/presentation/screens/important_dates_screen.dart';
import '../../features/location/presentation/screens/region_selection_screen.dart';
import '../../features/qazo/presentation/screens/qazo_screen.dart';
import '../../features/qibla/presentation/screens/qibla_screen.dart';
import '../../features/quiz/presentation/screens/quiz_question_screen.dart';
import '../../features/quran_courses/presentation/screens/quran_courses_screen.dart';
import '../../features/tasbih/presentation/screens/tasbih_screen.dart';
import '../../shared/widgets/not_ready_screen.dart';
import '../localization/localization_provider.dart';

class ServiceItem {
  final String id;
  final String labelKey;
  final String Function(WidgetRef ref)? dynamicLabel;
  final IconData icon;
  final Widget? targetScreen;
  final Future<void> Function(BuildContext context)? customAction;

  const ServiceItem({
    required this.id,
    required this.labelKey,
    this.dynamicLabel,
    required this.icon,
    this.targetScreen,
    this.customAction,
  });

  String getLabel(WidgetRef ref) {
    if (dynamicLabel != null) {
      return dynamicLabel!(ref);
    }
    return labelKey;
  }

  void onTap(BuildContext context, WidgetRef ref) {
    if (customAction != null) {
      customAction!(context);
    } else if (targetScreen != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => targetScreen!));
    }
  }
}

List<ServiceItem> getAppServices() => const [
      ServiceItem(
        id: 'quran',
        labelKey: "Qur'on",
        icon: Icons.menu_book_rounded,
        targetScreen: NotReadyScreen(title: "Qur'oni Karim", icon: Icons.menu_book_rounded),
      ),
      ServiceItem(
        id: 'courses',
        labelKey: "Kurslar",
        icon: Icons.school_rounded,
        targetScreen: QuranCoursesScreen(),
      ),
      ServiceItem(
        id: 'quiz',
        labelKey: "Viktorina",
        icon: Icons.quiz_rounded,
        targetScreen: QuizQuestionScreen(),
      ),
      ServiceItem(
        id: 'dates',
        labelKey: "Sanalar",
        icon: Icons.event_available_rounded,
        targetScreen: ImportantDatesScreen(),
      ),
      ServiceItem(
        id: 'hadith',
        labelKey: 'hadith',
        dynamicLabel: _getHadithLabel,
        icon: Icons.auto_stories_rounded,
        targetScreen: HadithDuasScreen(initialCategory: FeedCategory.hadith),
      ),
      ServiceItem(
        id: 'dua',
        labelKey: 'dua',
        dynamicLabel: _getDuaLabel,
        icon: Icons.volunteer_activism_rounded,
        targetScreen: HadithDuasScreen(initialCategory: FeedCategory.dua),
      ),
      ServiceItem(
        id: 'verse',
        labelKey: 'verse',
        dynamicLabel: _getVerseLabel,
        icon: Icons.format_quote_rounded,
        targetScreen: HadithDuasScreen(initialCategory: FeedCategory.verse),
      ),
      ServiceItem(
        id: 'tasbih',
        labelKey: 'tasbih',
        dynamicLabel: _getTasbihLabel,
        icon: Icons.touch_app_rounded,
        targetScreen: TasbihScreen(),
      ),
      ServiceItem(
        id: 'qibla',
        labelKey: 'qibla',
        dynamicLabel: _getQiblaLabel,
        icon: Icons.explore_rounded,
        targetScreen: QiblaScreen(),
      ),
      ServiceItem(
        id: 'finance',
        labelKey: 'Moliya',
        icon: Icons.account_balance_wallet_rounded,
        targetScreen: FinanceScreen(),
      ),
      ServiceItem(
        id: 'calendar',
        labelKey: 'Taqvim',
        icon: Icons.calendar_month_rounded,
        targetScreen: RegionSelectionScreen(),
      ),
      ServiceItem(
        id: 'qazo',
        labelKey: 'qazo',
        dynamicLabel: _getQazoLabel,
        icon: Icons.event_repeat_rounded,
        targetScreen: QazoScreen(),
      ),
      ServiceItem(
        id: 'community',
        labelKey: 'community',
        dynamicLabel: _getCommunityLabel,
        icon: Icons.groups_rounded,
        targetScreen: CommunityScreen(),
      ),
      ServiceItem(
        id: 'islom_uz',
        labelKey: 'Islom.uz',
        icon: Icons.public_rounded,
        customAction: _openIslomUz,
      ),
      ServiceItem(
        id: 'radio',
        labelKey: 'Radio',
        icon: Icons.radio_rounded,
        targetScreen: NotReadyScreen(title: 'Islomiy Radio', icon: Icons.radio_rounded),
      ),
    ];

String _getHadithLabel(WidgetRef ref) => 'hadith'.tr(ref);
String _getDuaLabel(WidgetRef ref) => 'dua'.tr(ref);
String _getVerseLabel(WidgetRef ref) => 'verse'.tr(ref);
String _getTasbihLabel(WidgetRef ref) => 'tasbih'.tr(ref);
String _getQiblaLabel(WidgetRef ref) => 'qibla'.tr(ref);
String _getQazoLabel(WidgetRef ref) => 'qazo'.tr(ref);
String _getCommunityLabel(WidgetRef ref) => 'community'.tr(ref);

Future<void> _openIslomUz(BuildContext context) async {
  final uri = Uri.parse('https://islom.uz');
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}
