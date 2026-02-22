import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'api_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  static ApiClient? _instance;

  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
        validateStatus: (status) => status! < 500,
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(
        request: kDebugMode,
        requestBody: kDebugMode,
        responseBody: kDebugMode,
        error: true,
        requestHeader: kDebugMode,
        responseHeader: false,
      ),
    ]);
  }

  Dio get dio => _dio;

  // GET Request
  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // POST Request
  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // PUT Request
  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // PATCH Request
  Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // DELETE Request
  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Upload File
  Future<Response> uploadFile(
      String path, {
        required File file,
        required String fieldName,
        Map<String, dynamic>? data,
        ProgressCallback? onSendProgress,
        CancelToken? cancelToken,
      }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        if (data != null) ...data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Upload Multiple Files
  Future<Response> uploadMultipleFiles(
      String path, {
        required List<File> files,
        required String fieldName,
        Map<String, dynamic>? data,
        ProgressCallback? onSendProgress,
        CancelToken? cancelToken,
      }) async {
    try {
      final multipartFiles = await Future.wait(
        files.map((file) async {
          final fileName = file.path.split('/').last;
          return MapEntry(
            fieldName,
            await MultipartFile.fromFile(file.path, filename: fileName),
          );
        }),
      );

      final formData = FormData();
      for (final entry in multipartFiles) {
        formData.files.add(entry);
      }
      if (data != null) {
        formData.fields.addAll(
          data.entries.map((e) => MapEntry(e.key, e.value.toString())),
        );
      }

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Download File
  Future<Response> downloadFile(
      String url,
      String savePath, {
        ProgressCallback? onReceiveProgress,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Handle Response
  Response _handleResponse(Response response) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      return response;
    }

    final data = response.data;
    final message = data is Map ? data['message'] ?? 'An error occurred' : 'An error occurred';

    switch (statusCode) {
      case 400:
        throw BadRequestException(message);
      case 401:
        throw UnauthorizedException(message);
      case 403:
        throw ForbiddenException(message);
      case 404:
        throw NotFoundException(message);
      case 409:
        throw ConflictException(message);
      case 422:
        throw ValidationException(message, data['errors']);
      case 429:
        throw TooManyRequestsException(message);
      default:
        throw ServerException(message);
    }
  }

  // Handle Dio Exception
  AppException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection. Please check your network.');
      case DioExceptionType.badCertificate:
        return ServerException('Invalid certificate. Please contact support.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final data = e.response?.data;
        final message = data is Map ? data['message'] ?? e.message : e.message ?? 'An error occurred';

        switch (statusCode) {
          case 400:
            return BadRequestException(message);
          case 401:
            return UnauthorizedException(message);
          case 403:
            return ForbiddenException(message);
          case 404:
            return NotFoundException(message);
          case 409:
            return ConflictException(message);
          case 422:
            return ValidationException(message, data?['errors']);
          case 429:
            return TooManyRequestsException(message);
          case 500:
          case 502:
          case 503:
          case 504:
            return ServerException('Server error. Please try again later.');
          default:
            return ServerException(message);
        }
      case DioExceptionType.cancel:
        return RequestCancelledException('Request was cancelled');
      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          return NetworkException('No internet connection');
        }
        return ServerException(e.message ?? 'An unexpected error occurred');
    }
  }

  // Set Auth Token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove Auth Token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}