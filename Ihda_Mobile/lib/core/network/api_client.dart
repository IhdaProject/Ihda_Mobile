import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import 'api_exception.dart';

/// Thin wrapper around Dio. Every `ApiXxxDataSource` in the app talks to
/// the backend only through this class, so swapping HTTP libraries or
/// adding auth headers later happens in exactly one place.
class ApiClient {
  final Dio _dio;

  ApiClient({String? baseUrl, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
                connectTimeout: AppConstants.apiTimeout,
                receiveTimeout: AppConstants.apiTimeout,
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) => handler.next(error),
      ),
    );
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) =>
      _guard(() => _dio.get<T>(path, queryParameters: query));

  Future<Response<T>> post<T>(String path, {Object? data}) =>
      _guard(() => _dio.post<T>(path, data: data));

  Future<Response<T>> put<T>(String path, {Object? data}) =>
      _guard(() => _dio.put<T>(path, data: data));

  Future<Response<T>> delete<T>(String path, {Object? data}) =>
      _guard(() => _dio.delete<T>(path, data: data));

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw ApiException.timeout();
        case DioExceptionType.connectionError:
          throw ApiException.network();
        case DioExceptionType.badResponse:
          throw ApiException.server(
            e.response?.statusCode ?? 500,
            e.response?.statusMessage,
          );
        default:
          throw ApiException.unknown(e.message);
      }
    }
  }
}
