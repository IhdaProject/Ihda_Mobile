import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../../features/settings/presentation/providers/settings_providers.dart';
import 'api_client.dart';
import 'models/meta_query_model.dart';
import 'models/response_model.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final settings = ref.watch(settingsControllerProvider).valueOrNull;
  final baseUrl = settings?.domain ?? AppConstants.apiBaseUrl;
  return ApiClient(baseUrl: baseUrl);
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ApiService(client);
});

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  Future<ResponseModel<T>> get<T>(
    String path, {
    MetaQueryModel? query,
    required T Function(Object? json) fromJsonT,
  }) async {
    final response = await _client.get(path, query: query?.toJson());
    return ResponseModel<T>.fromJson(response.data as Map<String, dynamic>, fromJsonT);
  }

  Future<ResponseModel<T>> post<T>(
    String path, {
    Object? data,
    required T Function(Object? json) fromJsonT,
  }) async {
    final response = await _client.post(path, data: data);
    return ResponseModel<T>.fromJson(response.data as Map<String, dynamic>, fromJsonT);
  }

  Future<ResponseModel<T>> put<T>(
    String path, {
    Object? data,
    required T Function(Object? json) fromJsonT,
  }) async {
    final response = await _client.put(path, data: data);
    return ResponseModel<T>.fromJson(response.data as Map<String, dynamic>, fromJsonT);
  }

  Future<ResponseModel<T>> delete<T>(
    String path, {
    Object? data,
    required T Function(Object? json) fromJsonT,
  }) async {
    final response = await _client.delete(path, data: data);
    return ResponseModel<T>.fromJson(response.data as Map<String, dynamic>, fromJsonT);
  }
}
