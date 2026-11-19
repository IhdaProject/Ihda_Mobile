import '../../domain/entities/mosque.dart';

abstract class MosqueDataSource {
  Future<List<Mosque>> getNearbyMosques();
  Future<Mosque> getMosqueById(String id);
  Future<void> setFavorite(String id, bool isFavorite);
  Future<void> setVisited(String id, bool isVisited, List<DateTime> visitDates);
}
