/// Custom exceptions for the data layer
/// 
/// These exceptions are thrown by data sources and repositories
/// and are later converted to Failure objects in the domain layer.

/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Server response exceptions
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Storage-related exceptions
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Video processing exceptions
class VideoProcessingException extends AppException {
  const VideoProcessingException({
    required super.message,
    super.code,
    super.details,
  });
}

/// URL parsing exceptions
class UrlException extends AppException {
  const UrlException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Download-specific exceptions
class DownloadException extends AppException {
  const DownloadException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Platform-specific exceptions
class PlatformException extends AppException {
  const PlatformException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Encryption/Decryption exceptions
class EncryptionException extends AppException {
  const EncryptionException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Rate limiting exceptions
class RateLimitException extends AppException {
  const RateLimitException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Format not supported exceptions
class UnsupportedFormatException extends AppException {
  const UnsupportedFormatException({
    required super.message,
    super.code,
    super.details,
  });
}

/// File not found exceptions
class FileNotFoundException extends AppException {
  const FileNotFoundException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Insufficient storage exceptions
class InsufficientStorageException extends AppException {
  const InsufficientStorageException({
    required super.message,
    super.code,
    super.details,
  });
}