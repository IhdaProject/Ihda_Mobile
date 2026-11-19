import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_environment.dart';
import '../../data/datasources/mock_mosque_data_source.dart';
import '../../data/datasources/mosque_data_source.dart';
import '../../data/repositories/mosque_repository_impl.dart';
import '../../domain/entities/mosque.dart';
import '../../domain/repositories/mosque_repository.dart';

final mosqueDataSourceProvider = Provider<MosqueDataSource>((ref) {
  switch (AppEnvironment.dataSourceMode) {
    case DataSourceMode.mock:
      return MockMosqueDataSource();
    case DataSourceMode.api:
      return MockMosqueDataSource();
  }
});

final mosqueRepositoryProvider = Provider<MosqueRepository>((ref) {
  return MosqueRepositoryImpl(ref.watch(mosqueDataSourceProvider));
});

class MosqueController extends AsyncNotifier<List<Mosque>> {
  @override
  Future<List<Mosque>> build() {
    return ref.read(mosqueRepositoryProvider).getNearbyMosques();
  }

  Future<void> toggleFavorite(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final target = current.firstWhere((m) => m.id == id);
    final updated = !target.isFavorite;

    state = AsyncData([
      for (final m in current)
        if (m.id == id) m.copyWith(isFavorite: updated) else m,
    ]);
    await ref.read(mosqueRepositoryProvider).setFavorite(id, updated);
  }

  Future<void> toggleVisited(String id, {DateTime? visitDate}) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final target = current.firstWhere((m) => m.id == id);

    final bool newVisited = !target.isVisited;
    final List<DateTime> newDates = List<DateTime>.from(target.visitDates);

    if (newVisited) {
      final dateToAdd = visitDate ?? DateTime.now();
      if (!newDates.contains(dateToAdd)) {
        newDates.add(dateToAdd);
        newDates.sort();
      }
    }

    state = AsyncData([
      for (final m in current)
        if (m.id == id)
          m.copyWith(isVisited: newVisited, visitDates: newDates)
        else
          m,
    ]);

    await ref.read(mosqueRepositoryProvider).setVisited(id, newVisited, newDates);
  }

  Future<void> addVisitRecord(String id, DateTime visitDate) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final target = current.firstWhere((m) => m.id == id);

    final List<DateTime> newDates = List<DateTime>.from(target.visitDates);
    newDates.add(visitDate);
    newDates.sort();

    state = AsyncData([
      for (final m in current)
        if (m.id == id)
          m.copyWith(isVisited: true, visitDates: newDates)
        else
          m,
    ]);

    await ref.read(mosqueRepositoryProvider).setVisited(id, true, newDates);
  }

  Future<void> removeVisitRecord(String id, int index) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final target = current.firstWhere((m) => m.id == id);

    final List<DateTime> newDates = List<DateTime>.from(target.visitDates);
    if (index >= 0 && index < newDates.length) {
      newDates.removeAt(index);
    }
    final bool stillVisited = newDates.isNotEmpty;

    state = AsyncData([
      for (final m in current)
        if (m.id == id)
          m.copyWith(isVisited: stillVisited, visitDates: newDates)
        else
          m,
    ]);

    await ref.read(mosqueRepositoryProvider).setVisited(id, stillVisited, newDates);
  }
}

final mosqueControllerProvider =
    AsyncNotifierProvider<MosqueController, List<Mosque>>(MosqueController.new);

final favoriteMosquesProvider = Provider.autoDispose<AsyncValue<List<Mosque>>>((ref) {
  final mosques = ref.watch(mosqueControllerProvider);
  return mosques.whenData((list) => list.where((m) => m.isFavorite).toList());
});

final visitedMosquesProvider = Provider.autoDispose<AsyncValue<List<Mosque>>>((ref) {
  final mosques = ref.watch(mosqueControllerProvider);
  return mosques.whenData((list) => list.where((m) => m.isVisited).toList());
});

final mosqueByIdProvider = FutureProvider.autoDispose.family<Mosque, String>((ref, id) {
  return ref.watch(mosqueRepositoryProvider).getMosqueById(id);
});
