import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/models/meta_query_model.dart';
import '../../domain/entities/country.dart';

final countriesProvider = FutureProvider<List<Country>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  
  final response = await apiService.get<List<Country>>(
    '/api/Country',
    query: MetaQueryModel(skip: 0, take: 100),
    fromJsonT: (json) {
      if (json is List) {
        return json.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    },
  );

  if (response.isSuccess) {
    return response.content ?? [];
  } else {
    throw Exception(response.error ?? 'Failed to load countries');
  }
});
