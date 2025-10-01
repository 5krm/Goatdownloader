import '../entities/video.dart';
import '../repositories/video_repository.dart';
import '../../core/error/failures.dart';

/// Use case for extracting video information from a URL
/// 
/// This use case encapsulates the business logic for getting video information
/// from various supported platforms. It validates the URL and delegates
/// the actual extraction to the repository layer.
class GetVideoInfo {
  final VideoRepository repository;

  GetVideoInfo(this.repository);

  /// Executes the use case to get video information
  /// 
  /// [params] - Parameters containing the video URL
  /// Returns a [Result] containing either a [Video] or [Failure]
  Future<Result<Video>> call(GetVideoInfoParams params) async {
    // Validate URL format
    if (!_isValidUrl(params.url)) {
      return Error(ValidationFailure(
        message: 'Invalid URL format',
        details: {'url': params.url},
      ));
    }

    // Check if URL is supported
    if (!repository.isUrlSupported(params.url)) {
      return Error(UrlFailure(
        message: 'URL platform not supported',
        details: {'url': params.url, 'supported_platforms': repository.getSupportedPlatforms()},
      ));
    }

    // Extract video information
    try {
      final result = await repository.getVideoInfo(params.url);
      return result;
    } catch (e) {
      return Error(UnknownFailure(
        message: 'Failed to extract video information',
        details: {'error': e.toString(), 'url': params.url},
      ));
    }
  }

  /// Validates if the provided string is a valid URL
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}

/// Parameters for the GetVideoInfo use case
class GetVideoInfoParams {
  final String url;
  final bool refreshCache;
  final Map<String, dynamic>? additionalOptions;

  const GetVideoInfoParams({
    required this.url,
    this.refreshCache = false,
    this.additionalOptions,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetVideoInfoParams &&
        other.url == url &&
        other.refreshCache == refreshCache;
  }

  @override
  int get hashCode => url.hashCode ^ refreshCache.hashCode;

  @override
  String toString() {
    return 'GetVideoInfoParams(url: $url, refreshCache: $refreshCache)';
  }
}