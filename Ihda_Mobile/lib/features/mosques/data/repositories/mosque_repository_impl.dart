import '../../domain/entities/mosque.dart';
import '../../domain/repositories/mosque_repository.dart';
import '../datasources/mosque_data_source.dart';

class MosqueRepositoryImpl implements MosqueRepository {
  final MosqueDataSource _dataSource;

  MosqueRepositoryImpl(this._dataSource);

  @override
  Future<List<Mosque>> getNearbyMosques() => _dataSource.getNearbyMosques();

  @override
  Future<Mosque> getMosqueById(String id) => _dataSource.getMosqueById(id);

  @override
  Future<void> setFavorite(String id, bool isFavorite) =>
      _dataSource.setFavorite(id, isFavorite);
}
