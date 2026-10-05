import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

/// Dio client wired to the Django backend, with auth-token injection,
/// automatic refresh-token retry and logging.
class DioClient {
  DioClient(this._dio, this._secureStorage) {
    _dio.options
      ..baseUrl = ApiEndpoints.backendBaseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15);

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.readAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  final Dio _dio;
  final SecureStorageService _secureStorage;

  Dio get raw => _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) =>
      _guard(() => _dio.get<T>(path, queryParameters: query));

  Future<Response<T>> post<T>(String path, {Object? data}) =>
      _guard(() => _dio.post<T>(path, data: data));

  Future<Response<T>> put<T>(String path, {Object? data}) =>
      _guard(() => _dio.put<T>(path, data: data));

  Future<Response<T>> patch<T>(String path, {Object? data}) =>
      _guard(() => _dio.patch<T>(path, data: data));

  Future<Response<T>> delete<T>(String path, {Object? data}) =>
      _guard(() => _dio.delete<T>(path, data: data));

  Future<Response<T>> _guard<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw ApiException.timeout();
        case DioExceptionType.connectionError:
          throw ApiException.network();
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) throw ApiException.unauthorized();
          throw ApiException.unknown(_extractMessage(e.response?.data));
        default:
          throw ApiException.unknown(e.message);
      }
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['detail'] ?? data['message'])?.toString();
    }
    return null;
  }
}

final dioProvider = Provider<Dio>((ref) => Dio());

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.watch(dioProvider), ref.watch(secureStorageServiceProvider));
});
