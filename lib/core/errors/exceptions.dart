abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException([String message = 'Server error occurred']) : super(message);
}

class NetworkException extends AppException {
  NetworkException([String message = 'No internet connection']) : super(message);
}

class TimeoutException extends AppException {
  TimeoutException([String message = 'Connection timed out']) : super(message);
}

class BadRequestException extends AppException {
  BadRequestException([String message = 'Bad request']) : super(message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Unauthorized']) : super(message);
}

class ForbiddenException extends AppException {
  ForbiddenException([String message = 'Access forbidden']) : super(message);
}

class NotFoundException extends AppException {
  NotFoundException([String message = 'Resource not found']) : super(message);
}

class ConflictException extends AppException {
  ConflictException([String message = 'Conflict occurred']) : super(message);
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException([String message = 'Validation failed', this.errors])
      : super(message, details: errors);

  String? getFieldError(String field) {
    if (errors == null) return null;
    final fieldErrors = errors![field];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    if (fieldErrors is String) {
      return fieldErrors;
    }
    return null;
  }
}

class TooManyRequestsException extends AppException {
  TooManyRequestsException([String message = 'Too many requests']) : super(message);
}

class RequestCancelledException extends AppException {
  RequestCancelledException([String message = 'Request cancelled']) : super(message);
}

class CacheException extends AppException {
  CacheException([String message = 'Cache error']) : super(message);
}

class StorageException extends AppException {
  StorageException([String message = 'Storage error']) : super(message);
}

class FileException extends AppException {
  FileException([String message = 'File error']) : super(message);
}

class PermissionException extends AppException {
  PermissionException([String message = 'Permission denied']) : super(message);
}