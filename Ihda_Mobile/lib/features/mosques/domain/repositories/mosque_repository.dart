import '../entities/mosque.dart';

abstract class MosqueRepository {
  Future<List<Mosque>> getNearbyMosques();
  Future<Mosque> getMosqueById(String id);
  Future<void> setFavorite(String id, bool isFavorite);
  Future<void> setVisited(String id, bool isVisited, List<DateTime> visitDates);
}
