import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../data/services/storage_service.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storage = StorageService();
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // Skip auth header for public endpoints
    final publicEndpoints = [
      ApiConstants.login,
      ApiConstants.sendEmailOtp,
      ApiConstants.verifyEmailOtp,
      ApiConstants.sendPhoneOtp,
      ApiConstants.verifyPhoneOtp,
      ApiConstants.registerPatient,
      ApiConstants.forgotPassword,
      ApiConstants.resetPassword,
    ];

    final isPublicEndpoint = publicEndpoints.any(
          (endpoint) => options.path.contains(endpoint),
    );

    if (!isPublicEndpoint) {
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    if (kDebugMode) {
      print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
    }

    handler.next(options);
  }

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    if (kDebugMode) {
      print(
        '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    if (kDebugMode) {
      print(
        '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      );
      print('ERROR MESSAGE: ${err.message}');
    }

    // Handle 401 Unauthorized - Token refresh
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // Don't retry for login or refresh endpoints
      if (requestOptions.path.contains(ApiConstants.login) ||
          requestOptions.path.contains(ApiConstants.refreshToken)) {
        return handler.next(err);
      }

      // If already refreshing, add to pending requests
      if (_isRefreshing) {
        _pendingRequests.add(requestOptions);
        return handler.next(err);
      }

      _isRefreshing = true;

      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null) {
          // No refresh token, clear storage and reject
          await _storage.clearAll();
          return handler.next(err);
        }

        // Try to refresh the token
        final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
        final response = await dio.post(
          ApiConstants.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['data']['accessToken'];
          final newRefreshToken = response.data['data']['refreshToken'];

          // Store new tokens
          await _storage.setAccessToken(newAccessToken);
          await _storage.setRefreshToken(newRefreshToken);

          // Retry original request
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          try {
            final retryResponse = await dio.fetch(requestOptions);
            handler.resolve(retryResponse);
          } catch (e) {
            handler.next(err);
          }

          // Retry pending requests
          for (final pendingRequest in _pendingRequests) {
            pendingRequest.headers['Authorization'] = 'Bearer $newAccessToken';
            dio.fetch(pendingRequest);
          }
          _pendingRequests.clear();
        } else {
          // Refresh failed, clear storage
          await _storage.clearAll();
          handler.next(err);
        }
      } catch (e) {
        await _storage.clearAll();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
}

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final shouldRetry = _shouldRetry(err);

    if (shouldRetry) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        await Future.delayed(retryDelay * (retryCount + 1));

        final options = err.requestOptions;
        options.extra['retryCount'] = retryCount + 1;

        try {
          final dio = Dio();
          final response = await dio.fetch(options);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue with original error
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500 &&
            err.response!.statusCode! < 600);
  }
}