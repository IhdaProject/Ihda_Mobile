import '../../domain/entities/mosque.dart';

abstract class MosqueDataSource {
  Future<List<Mosque>> getNearbyMosques();
  Future<Mosque> getMosqueById(String id);
  Future<void> setFavorite(String id, bool isFavorite);
}
