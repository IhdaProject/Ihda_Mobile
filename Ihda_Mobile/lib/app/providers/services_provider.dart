import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_services.dart';
import '../../features/tasbih/presentation/providers/tasbih_providers.dart';

class ServicesState {
  final List<String> serviceIds;
  final int columnCount; // 3 or 4

  const ServicesState({
    required this.serviceIds,
    required this.columnCount,
  });

  ServicesState copyWith({
    List<String>? serviceIds,
    int? columnCount,
  }) {
    return ServicesState(
      serviceIds: serviceIds ?? this.serviceIds,
      columnCount: columnCount ?? this.columnCount,
    );
  }
}

class ServicesController extends StateNotifier<ServicesState> {
  final SharedPreferences _prefs;

  ServicesController(this._prefs) : super(const ServicesState(serviceIds: [], columnCount: 4)) {
    _load();
  }

  static const String _keyOrder = 'services_custom_order';
  static const String _keyColumns = 'services_column_count';

  void _load() {
    final defaultIds = getAppServices().map((s) => s.id).toList();
    final savedOrder = _prefs.getStringList(_keyOrder);
    final savedColumns = _prefs.getInt(_keyColumns) ?? 4;

    List<String> order = defaultIds;
    if (savedOrder != null && savedOrder.isNotEmpty) {
      final validIds = savedOrder.where((id) => defaultIds.contains(id)).toList();
      for (final id in defaultIds) {
        if (!validIds.contains(id)) {
          validIds.add(id);
        }
      }
      order = validIds;
    }

    state = ServicesState(serviceIds: order, columnCount: savedColumns);
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final list = List<String>.from(state.serviceIds);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(serviceIds: list);
    _prefs.setStringList(_keyOrder, list);
  }

  void setColumnCount(int count) {
    state = state.copyWith(columnCount: count);
    _prefs.setInt(_keyColumns, count);
  }

  List<ServiceItem> getOrderedServices() {
    final allServices = getAppServices();
    final map = {for (var s in allServices) s.id: s};
    return state.serviceIds.where((id) => map.containsKey(id)).map((id) => map[id]!).toList();
  }
}

final servicesControllerProvider = StateNotifierProvider<ServicesController, ServicesState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ServicesController(prefs);
});
