import '../entities/mosque.dart';

abstract class MosqueRepository {
  Future<List<Mosque>> getNearbyMosques();
  Future<Mosque> getMosqueById(String id);
  Future<void> setFavorite(String id, bool isFavorite);
}
