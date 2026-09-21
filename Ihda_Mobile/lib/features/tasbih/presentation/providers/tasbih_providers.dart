import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

class TasbihController extends Notifier<int> {
  static const _key = 'tasbih_count';

  @override
  int build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getInt(_key) ?? 0;
  }

  void increment() {
    final newCount = state + 1;
    state = newCount;
    ref.read(sharedPreferencesProvider).setInt(_key, newCount);
  }

  void reset() {
    state = 0;
    ref.read(sharedPreferencesProvider).setInt(_key, 0);
  }
}

final tasbihCountProvider = NotifierProvider<TasbihController, int>(TasbihController.new);
final vibrationEnabledProvider = StateProvider<bool>((ref) => true);
final soundEnabledProvider = StateProvider<bool>((ref) => true);
final tasbihLimitProvider = StateProvider<int>((ref) => 33);
final isTasbihDarkModeProvider = StateProvider<bool>((ref) => false);
