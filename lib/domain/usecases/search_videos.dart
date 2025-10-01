import '../entities/video.dart';
import '../repositories/video_repository.dart';
import '../../core/error/failures.dart';

/// Use case for searching videos across multiple platforms
/// 
/// This use case handles the business logic for searching videos,
/// including query validation, platform filtering, and result pagination.
class SearchVideos {
  final VideoRepository repository;

  SearchVideos(this.repository);

  /// Executes the use case to search for videos
  /// 
  /// [params] - Parameters containing search configuration
  /// Returns a [Result] containing either a list of [Video] or [Failure]
  Future<Result<List<Video>>> call(SearchVideosParams params) async {
    // Validate search query
    if (params.query.trim().isEmpty) {
      return Error(ValidationFailure(
        message: 'Search query cannot be empty',
      ));
    }

    if (params.query.trim().length < 2) {
      return Error(ValidationFailure(
        message: 'Search query must be at least 2 characters long',
        details: {'query': params.query, 'length': params.query.length},
      ));
    }

    // Validate pagination parameters
    if (params.page < 1) {
      return Error(ValidationFailure(
        message: 'Page number must be greater than 0',
        details: {'page': params.page},
      ));
    }

    if (params.limit < 1 || params.limit > 100) {
      return Error(ValidationFailure(
        message: 'Limit must be between 1 and 100',
        details: {'limit': params.limit},
      ));
    }

    // Validate platforms
    if (params.platforms.isNotEmpty) {
      final supportedPlatforms = repository.getSupportedPlatforms();
      final unsupportedPlatforms = params.platforms
          .where((platform) => !supportedPlatforms.contains(platform))
          .toList();

      if (unsupportedPlatforms.isNotEmpty) {
        return Error(ValidationFailure(
          message: 'Some platforms are not supported',
          details: {
            'unsupported_platforms': unsupportedPlatforms,
            'supported_platforms': supportedPlatforms,
          },
        ));
      }
    }

    // Execute search
    try {
      final result = await repository.searchVideos(
        query: params.query.trim(),
        platforms: params.platforms,
        page: params.page,
        limit: params.limit,
        sortBy: params.sortBy,
        filters: params.filters,
      );
      return result;
    } catch (e) {
      return Error(NetworkFailure(
        message: 'Failed to search videos',
        details: {
          'error': e.toString(),
          'query': params.query,
          'platforms': params.platforms,
        },
      ));
    }
  }
}

/// Use case for getting trending videos
class GetTrendingVideos {
  final VideoRepository repository;

  GetTrendingVideos(this.repository);

  /// Executes the use case to get trending videos
  /// 
  /// [params] - Parameters containing trending configuration
  /// Returns a [Result] containing either a list of [Video] or [Failure]
  Future<Result<List<Video>>> call(GetTrendingParams params) async {
    // Validate pagination parameters
    if (params.page < 1) {
      return Error(ValidationFailure(
        message: 'Page number must be greater than 0',
        details: {'page': params.page},
      ));
    }

    if (params.limit < 1 || params.limit > 100) {
      return Error(ValidationFailure(
        message: 'Limit must be between 1 and 100',
        details: {'limit': params.limit},
      ));
    }

    // Validate platforms
    if (params.platforms.isNotEmpty) {
      final supportedPlatforms = repository.getSupportedPlatforms();
      final unsupportedPlatforms = params.platforms
          .where((platform) => !supportedPlatforms.contains(platform))
          .toList();

      if (unsupportedPlatforms.isNotEmpty) {
        return Error(ValidationFailure(
          message: 'Some platforms are not supported',
          details: {
            'unsupported_platforms': unsupportedPlatforms,
            'supported_platforms': supportedPlatforms,
          },
        ));
      }
    }

    // Get trending videos
    try {
      final result = await repository.getTrendingVideos(
        platforms: params.platforms,
        category: params.category,
        region: params.region,
        page: params.page,
        limit: params.limit,
      );
      return result;
    } catch (e) {
      return Error(NetworkFailure(
        message: 'Failed to get trending videos',
        details: {
          'error': e.toString(),
          'platforms': params.platforms,
          'category': params.category,
          'region': params.region,
        },
      ));
    }
  }
}

/// Use case for validating video URLs
class ValidateVideoUrl {
  final VideoRepository repository;

  ValidateVideoUrl(this.repository);

  /// Executes the use case to validate a video URL
  /// 
  /// [url] - The URL to validate
  /// Returns a [Result] containing either validation result or [Failure]
  Future<Result<bool>> call(String url) async {
    if (url.trim().isEmpty) {
      return Error(ValidationFailure(
        message: 'URL cannot be empty',
      ));
    }

    // Basic URL format validation
    if (!_isValidUrl(url)) {
      return Error(ValidationFailure(
        message: 'Invalid URL format',
        details: {'url': url},
      ));
    }

    try {
      final isSupported = repository.isUrlSupported(url);
      if (!isSupported) {
        return Error(UrlFailure(
          message: 'URL platform not supported',
          details: {
            'url': url,
            'supported_platforms': repository.getSupportedPlatforms(),
          },
        ));
      }

      // Additional validation through repository
      final result = await repository.validateUrl(url);
      return result;
    } catch (e) {
      return Error(NetworkFailure(
        message: 'Failed to validate URL',
        details: {'error': e.toString(), 'url': url},
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

/// Parameters for the SearchVideos use case
class SearchVideosParams {
  final String query;
  final List<String> platforms;
  final int page;
  final int limit;
  final String? sortBy;
  final Map<String, dynamic>? filters;

  const SearchVideosParams({
    required this.query,
    this.platforms = const [],
    this.page = 1,
    this.limit = 20,
    this.sortBy,
    this.filters,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchVideosParams &&
        other.query == query &&
        _listEquals(other.platforms, platforms) &&
        other.page == page &&
        other.limit == limit &&
        other.sortBy == sortBy;
  }

  @override
  int get hashCode {
    return query.hashCode ^
        platforms.hashCode ^
        page.hashCode ^
        limit.hashCode ^
        sortBy.hashCode;
  }

  @override
  String toString() {
    return 'SearchVideosParams(query: $query, platforms: $platforms, page: $page, limit: $limit, sortBy: $sortBy)';
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Parameters for the GetTrendingVideos use case
class GetTrendingParams {
  final List<String> platforms;
  final String? category;
  final String? region;
  final int page;
  final int limit;

  const GetTrendingParams({
    this.platforms = const [],
    this.category,
    this.region,
    this.page = 1,
    this.limit = 20,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetTrendingParams &&
        _listEquals(other.platforms, platforms) &&
        other.category == category &&
        other.region == region &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    return platforms.hashCode ^
        category.hashCode ^
        region.hashCode ^
        page.hashCode ^
        limit.hashCode;
  }

  @override
  String toString() {
    return 'GetTrendingParams(platforms: $platforms, category: $category, region: $region, page: $page, limit: $limit)';
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}