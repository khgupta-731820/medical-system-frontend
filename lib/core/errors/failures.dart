import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error']) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed']) : super(message);
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ValidationFailure([String message = 'Validation failed', this.errors])
      : super(message);

  @override
  List<Object?> get props => [message, errors];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found']) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Unknown error occurred']) : super(message);
}