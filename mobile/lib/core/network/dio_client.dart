import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';

final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

final dioProvider = Provider<Dio>((ref) {
  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  return _buildDio(storage, ref);
});

Dio _buildDio(FlutterSecureStorage storage, Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-App-Platform': 'flutter',
      },
    ),
  );

  dio.interceptors.addAll([
    _AuthInterceptor(storage: storage, dio: dio, ref: ref),
    _LoggingInterceptor(),
    _ErrorInterceptor(),
  ]);

  return dio;
}

/// Injects Authorization header and handles 401 refresh
class _AuthInterceptor extends QueuedInterceptorsWrapper {
  final FlutterSecureStorage storage;
  final Dio dio;
  final Ref ref;

  _AuthInterceptor({
    required this.storage,
    required this.dio,
    required this.ref,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken =
            await storage.read(key: AppConstants.refreshTokenKey);
        if (refreshToken == null) {
          _handleLogout(ref);
          return handler.next(err);
        }

        // Attempt token refresh
        final refreshResponse = await Dio().post(
          '${AppConstants.baseUrl}/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken =
            refreshResponse.data['access_token'] as String;
        final newRefreshToken =
            refreshResponse.data['refresh_token'] as String?;

        await storage.write(
          key: AppConstants.accessTokenKey,
          value: newAccessToken,
        );
        if (newRefreshToken != null) {
          await storage.write(
            key: AppConstants.refreshTokenKey,
            value: newRefreshToken,
          );
        }

        // Retry original request
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await dio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        _handleLogout(ref);
        return handler.next(err);
      }
    }
    handler.next(err);
  }

  void _handleLogout(Ref ref) {
    // Invalidate auth state – router redirect handles navigation
    // ref.invalidate(authStateProvider);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('[REQ] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('[RES] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('[ERR] ${err.response?.statusCode} ${err.message}');
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appError = _mapError(err);
    handler.next(appError);
  }

  DioException _mapError(DioException err) {
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Check your internet.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final body = err.response?.data;
        message = _extractServerMessage(body, statusCode);
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection.';
        break;
      default:
        message = 'Something went wrong. Please try again.';
    }
    return err.copyWith(message: message);
  }

  String _extractServerMessage(dynamic body, int statusCode) {
    if (body is Map) {
      return body['message']?.toString() ??
          body['error']?.toString() ??
          'Server error ($statusCode)';
    }
    return 'Server error ($statusCode)';
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;

  const ApiResponse({
    this.data,
    this.message,
    this.success = true,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    return ApiResponse(
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : null,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
    );
  }
}

/// Failure class for error handling
class Failure {
  final String message;
  final int? statusCode;
  final String? code;

  const Failure({
    required this.message,
    this.statusCode,
    this.code,
  });

  factory Failure.fromDio(DioException e) {
    return Failure(
      message: e.message ?? 'Unknown error',
      statusCode: e.response?.statusCode,
    );
  }

  @override
  String toString() => 'Failure(message: $message, code: $statusCode)';
}