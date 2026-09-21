import 'package:flutter_riverpod/flutter_riverpod.dart';

final localizationProvider = StateProvider<Map<String, String>>((ref) => {
  'settings': 'Settings',
  'account': 'Account',
  'edit_profile': 'Edit Profile',
  'change_password': 'Change Password',
  'privacy': 'Privacy',
  'notification': 'Notification',
  'updates': 'Updates',
  'prayer_calculation': 'Prayer calculation',
  'other': 'Other',
  'dark_mode': 'Dark Mode',
  'language': 'Language',
  'region': 'Region',
  'hadith': 'Hadith',
  'dua': 'Dua',
  'verse': 'Verse',
  'tasbih': 'Tasbih',
  'qazo': 'Qazo',
  'qibla': 'Qibla',
  'community': 'Community',
  'more': 'More',
  'search': 'Search',
  'mosques': 'Mosques',
  'favorites': 'Favorites',
  'home': 'Home',
  'location': 'Location',
  'profile': 'Profile',
  'select_navigation': 'Select Navigation',
  'recommended': 'Recommended',
  'external_map': 'External Map',
  'reset': 'Reset',
  'round': 'Round',
  'tap_to_exit': 'Tap to exit',
});

extension LocalizationExtension on String {
  String tr(WidgetRef ref) {
    return ref.watch(localizationProvider)[this] ?? this;
  }
}
