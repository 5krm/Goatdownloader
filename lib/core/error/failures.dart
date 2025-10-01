import 'package:equatable/equatable.dart';

/// Abstract base class for all failures in the application
/// 
/// This follows the Clean Architecture pattern where all errors
/// are represented as Failure objects that can be handled uniformly
/// across different layers of the application.
abstract class Failure extends Equatable {
  final String message;
  final int? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Server-related failures (4xx, 5xx HTTP errors)
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Storage-related failures (file system, database)
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Video processing failures
class VideoProcessingFailure extends Failure {
  const VideoProcessingFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// URL parsing and validation failures
class UrlFailure extends Failure {
  const UrlFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authentication and authorization failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Download-specific failures
class DownloadFailure extends Failure {
  const DownloadFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Validation failures for user input
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Platform-specific failures (iOS, Android)
class PlatformFailure extends Failure {
  const PlatformFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Encryption/Decryption failures
class EncryptionFailure extends Failure {
  const EncryptionFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Rate limiting failures
class RateLimitFailure extends Failure {
  const RateLimitFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Not found failures (404-like errors)
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Unsupported format failures
class UnsupportedFormatFailure extends Failure {
  const UnsupportedFormatFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Generic failure for unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.details,
  });
}