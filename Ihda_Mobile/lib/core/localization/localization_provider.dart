import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/presentation/providers/settings_providers.dart';
import '../network/api_client.dart';

final apiClientProvider = Provider((ref) => ApiClient());

const Map<String, Map<String, String>> _fallbackTranslations = {
  'uz': {
    'home': 'Asosiy',
    'settings': 'Sozlamalar',
    'account': 'Hisob',
    'edit_profile': 'Profilni tahrirlash',
    'change_password': 'Parolni o\'zgartirish',
    'privacy': 'Maxfiylik',
    'notification': 'Bildirishnoma',
    'updates': 'Yangiliklar',
    'prayer_calculation': 'Namoz vaqtini hisoblash',
    'other': 'Boshqa',
    'dark_mode': 'Tungi rejim',
    'language': 'Ilova tili',
    'region': 'Mintaqa / Hudud',
    'hadith': 'Hadis',
    'dua': 'Duo',
    'verse': 'Kun oyati',
    'tasbih': 'Tasbih',
    'qazo': 'Qazo',
    'qibla': 'Qibla',
    'community': 'Hamjamiyat',
    'more': 'Boshqalar',
    'search': 'Qidirish',
    'mosques': 'Masjidlar',
    'favorites': 'Tanlanganlar',
    'profile': 'Profil',
    'location': 'Joylashuv',
    'courses': 'Kurslar',
    'select_navigation': 'Navigatsiyani tanlash',
    'recommended': 'Tavsiya etiladi',
    'external_map': 'Tashqi xarita',
    'reset': 'Tozalash',
    'round': 'Doira',
    'tap_to_exit': 'Chiqish uchun bosing',
  },
  'ru': {
    'home': 'Главная',
    'settings': 'Настройки',
    'account': 'Аккаунт',
    'edit_profile': 'Редактировать профиль',
    'change_password': 'Изменить пароль',
    'privacy': 'Конфиденциальность',
    'notification': 'Уведомления',
    'updates': 'Обновления',
    'prayer_calculation': 'Расчет времени намаза',
    'other': 'Другое',
    'dark_mode': 'Темный режим',
    'language': 'Язык приложения',
    'region': 'Регион',
    'hadith': 'Хадисы',
    'dua': 'Дуа',
    'verse': 'Аят дня',
    'tasbih': 'Тасбих',
    'qazo': 'Казо',
    'qibla': 'Кибла',
    'community': 'Сообщество',
    'more': 'Ещё',
    'search': 'Поиск',
    'mosques': 'Мечети',
    'favorites': 'Избранное',
    'profile': 'Профиль',
    'location': 'Местоположение',
    'courses': 'Курсы',
    'select_navigation': 'Выбрать навигацию',
    'recommended': 'Рекомендуется',
    'external_map': 'Внешняя карта',
    'reset': 'Сброс',
    'round': 'Круг',
    'tap_to_exit': 'Нажмите для выхода',
  },
  'uz_cyrl': {
    'home': 'Асосий',
    'settings': 'Созламалар',
    'account': 'Ҳисоб',
    'edit_profile': 'Профилни таҳрирлаш',
    'change_password': 'Паролни ўзгартириш',
    'privacy': 'Махфийлик',
    'notification': 'Билдиришнома',
    'updates': 'Янгликлар',
    'prayer_calculation': 'Намоз вақтини ҳисоблаш',
    'other': 'Бошқа',
    'dark_mode': 'Тунги режим',
    'language': 'Илова тили',
    'region': 'Минтақа / Ҳудуд',
    'hadith': 'Ҳадис',
    'dua': 'Дуо',
    'verse': 'Кун ояти',
    'tasbih': 'Тасбиҳ',
    'qazo': 'Қазо',
    'qibla': 'Қибла',
    'community': 'Ҳамжамият',
    'more': 'Бошқалар',
    'search': 'Қидириш',
    'mosques': 'Масжидлар',
    'favorites': 'Танланганлар',
    'profile': 'Профил',
    'location': 'Жойлашув',
    'courses': 'Курслар',
    'select_navigation': 'Навигацияни танлаш',
    'recommended': 'Тавсия этилади',
    'external_map': 'Ташқи харита',
    'reset': 'Тозалаш',
    'round': 'Доира',
    'tap_to_exit': 'Чиқиш учун босинг',
  },
  'en': {
    'home': 'Home',
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
    'profile': 'Profile',
    'location': 'Location',
    'courses': 'Courses',
    'select_navigation': 'Select Navigation',
    'recommended': 'Recommended',
    'external_map': 'External Map',
    'reset': 'Reset',
    'round': 'Round',
    'tap_to_exit': 'Tap to exit',
  },
};

class LocalizationNotifier extends StateNotifier<Map<String, String>> {
  final Ref ref;

  LocalizationNotifier(this.ref) : super(_fallbackTranslations['uz']!) {
    _init();
  }

  Future<void> _init() async {
    try {
      final settings = ref.read(settingsControllerProvider).valueOrNull;
      final langCode = settings?.languageCode ?? 'uz';
      await fetchLanguage(langCode);
    } catch (_) {}
  }

  Future<void> fetchLanguage(String langCode) async {
    final fallback = _fallbackTranslations[langCode] ?? _fallbackTranslations['uz']!;
    state = fallback;

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get<Map<String, dynamic>>('/api/v1/translations/$langCode');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final translationsMap = data['translations'] as Map<String, dynamic>?;
        if (translationsMap != null) {
          final parsed = translationsMap.map((k, v) => MapEntry(k, v.toString()));
          state = parsed;
          try {
            final prefs = await SharedPreferences.getInstance();
            for (final entry in parsed.entries) {
              await prefs.setString('loc_${langCode}_${entry.key}', entry.value);
            }
          } catch (_) {}
          return;
        }
      }
    } catch (_) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final keys = fallback.keys;
        final cached = <String, String>{};
        bool hasCache = false;
        for (final key in keys) {
          final val = prefs.getString('loc_${langCode}_$key');
          if (val != null) {
            cached[key] = val;
            hasCache = true;
          }
        }
        if (hasCache) {
          state = {...fallback, ...cached};
        }
      } catch (_) {}
    }
  }
}

final localizationNotifierProvider =
    StateNotifierProvider<LocalizationNotifier, Map<String, String>>((ref) {
  return LocalizationNotifier(ref);
});

extension LocalizationExtension on String {
  String tr(WidgetRef ref) {
    try {
      final map = ref.watch(localizationNotifierProvider);
      return map[this] ?? _fallbackTranslations['uz']?[this] ?? this;
    } catch (_) {
      return this;
    }
  }
}
