import 'dart:async';

import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_remote_data_source.dart';
import '../datasources/video_local_data_source.dart';
import '../models/video_model.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/constants/app_constants.dart';

/// Implementation of VideoRepository
class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;
  final VideoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<Video>> getVideoInfo(String url) async {
    try {
      // Validate URL first
      final validationResult = await validateUrl(url);
      if (validationResult is Error) {
        return Error(validationResult.failure);
      }

      // Try to get from cache first
      final cachedVideo = await localDataSource.getCachedVideoInfo(url);
      if (cachedVideo != null && !_isCacheExpired(cachedVideo)) {
        return Success(cachedVideo);
      }

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        if (cachedVideo != null) {
          // Return cached data even if expired when offline
          return Success(cachedVideo);
        }
        return Error(NetworkFailure(message: 'No internet connection available'));
      }

      // Fetch from remote source
      final videoModel = await remoteDataSource.getVideoInfo(url);
      
      // Cache the result
      await localDataSource.cacheVideoInfo(url, videoModel);
      
      return Success(videoModel);
    } on NetworkException catch (e) {
      // Try to return cached data on network error
      final cachedVideo = await localDataSource.getCachedVideoInfo(url);
      if (cachedVideo != null) {
        return Success(cachedVideo);
      }
      return Error(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(message: e.message));
    } on UrlException catch (e) {
      return Error(UrlFailure(message: e.message));
    } on VideoProcessingException catch (e) {
      return Error(VideoProcessingFailure(message: e.message));
    } on CacheException catch (e) {
      return Error(CacheFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to get video info: $e'));
    }
  }

  @override
  Future<Result<List<Video>>> searchVideos({
    required String query,
    String? platform,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Validate parameters
      if (query.trim().isEmpty) {
        return Error(ValidationFailure('Search query cannot be empty'));
      }
      
      if (page < 1) {
        return Error(ValidationFailure('Page number must be greater than 0'));
      }
      
      if (limit < 1 || limit > 100) {
        return Error(ValidationFailure('Limit must be between 1 and 100'));
      }

      // Try to get from cache first
      final cacheKey = _generateSearchCacheKey(query, platform, page, limit);
      final cachedResults = await localDataSource.getCachedSearchResults(cacheKey);
      if (cachedResults != null && cachedResults.isNotEmpty) {
        return Success(cachedResults);
      }

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        if (cachedResults != null) {
          return Success(cachedResults);
        }
        return Error(NetworkFailure('No internet connection available'));
      }

      // Search from remote source
      final videoModels = await remoteDataSource.searchVideos(
        query: query,
        platform: platform,
        page: page,
        limit: limit,
      );
      
      // Cache the results
      await localDataSource.cacheSearchResults(cacheKey, videoModels);
      
      return Success(videoModels.cast<Video>());
    } on NetworkException catch (e) {
      // Try to return cached data on network error
      final cacheKey = _generateSearchCacheKey(query, platform, page, limit);
      final cachedResults = await localDataSource.getCachedSearchResults(cacheKey);
      if (cachedResults != null) {
        return Success(cachedResults);
      }
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on PlatformException catch (e) {
      return Error(PlatformFailure(e.message));
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to search videos: $e'));
    }
  }

  @override
  Future<Result<List<Video>>> getTrendingVideos({
    String? platform,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Validate parameters
      if (page < 1) {
        return Error(ValidationFailure('Page number must be greater than 0'));
      }
      
      if (limit < 1 || limit > 100) {
        return Error(ValidationFailure('Limit must be between 1 and 100'));
      }

      // Try to get from cache first
      final cacheKey = _generateTrendingCacheKey(platform, category, page, limit);
      final cachedResults = await localDataSource.getCachedTrendingVideos(cacheKey);
      if (cachedResults != null && cachedResults.isNotEmpty) {
        return Success(cachedResults);
      }

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        if (cachedResults != null) {
          return Success(cachedResults);
        }
        return Error(NetworkFailure('No internet connection available'));
      }

      // Get trending from remote source
      final videoModels = await remoteDataSource.getTrendingVideos(
        platform: platform,
        category: category,
        page: page,
        limit: limit,
      );
      
      // Cache the results
      await localDataSource.cacheTrendingVideos(cacheKey, videoModels);
      
      return Success(videoModels.cast<Video>());
    } on NetworkException catch (e) {
      // Try to return cached data on network error
      final cacheKey = _generateTrendingCacheKey(platform, category, page, limit);
      final cachedResults = await localDataSource.getCachedTrendingVideos(cacheKey);
      if (cachedResults != null) {
        return Success(cachedResults);
      }
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on PlatformException catch (e) {
      return Error(PlatformFailure(e.message));
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get trending videos: $e'));
    }
  }

  @override
  Future<Result<bool>> validateUrl(String url) async {
    try {
      if (url.trim().isEmpty) {
        return Error(UrlFailure('URL cannot be empty'));
      }

      // Basic URL format validation
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        return Error(UrlFailure('Invalid URL format'));
      }

      // Check if URL is from supported platform
      final supportedPlatforms = await getSupportedPlatforms();
      if (supportedPlatforms is Error) {
        return Error(supportedPlatforms.failure);
      }

      final platforms = (supportedPlatforms as Success<List<String>>).data;
      final isSupported = platforms.any((platform) => 
        url.toLowerCase().contains(platform.toLowerCase()));

      if (!isSupported) {
        return Error(PlatformFailure('Platform not supported'));
      }

      // Validate with remote source if connected
      if (await networkInfo.isConnected) {
        final isValid = await remoteDataSource.validateUrl(url);
        return Success(isValid);
      }

      // If offline, just return basic validation result
      return Success(true);
    } on UrlException catch (e) {
      return Error(UrlFailure(e.message));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to validate URL: $e'));
    }
  }

  @override
  Future<Result<List<String>>> getSupportedPlatforms() async {
    try {
      // Return hardcoded list of supported platforms
      const platforms = [
        'YouTube',
        'Facebook',
        'Instagram',
        'TikTok',
        'Twitter',
        'Vimeo',
      ];
      
      return Success(platforms);
    } catch (e) {
      return Error(UnknownFailure('Failed to get supported platforms: $e'));
    }
  }

  @override
  Future<Result<List<VideoFormat>>> getVideoFormats(String videoId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure('No internet connection available'));
      }

      final formats = await remoteDataSource.getVideoFormats(videoId);
      return Success(formats.cast<VideoFormat>());
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on VideoProcessingException catch (e) {
      return Error(VideoProcessingFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get video formats: $e'));
    }
  }

  @override
  Future<Result<List<String>>> getVideoSubtitles(String videoId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure('No internet connection available'));
      }

      final subtitles = await remoteDataSource.getVideoSubtitles(videoId);
      return Success(subtitles);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get video subtitles: $e'));
    }
  }

  @override
  Future<Result<List<Video>>> getRelatedVideos(String videoId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure('No internet connection available'));
      }

      final relatedVideos = await remoteDataSource.getRelatedVideos(videoId);
      return Success(relatedVideos.cast<Video>());
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get related videos: $e'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getVideoComments(String videoId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure('No internet connection available'));
      }

      final comments = await remoteDataSource.getVideoComments(videoId);
      return Success(comments);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get video comments: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getChannelInfo(String channelId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure('No internet connection available'));
      }

      final channelInfo = await remoteDataSource.getChannelInfo(channelId);
      return Success(channelInfo);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get channel info: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getPlaylistInfo(String playlistId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure('No internet connection available'));
      }

      final playlistInfo = await remoteDataSource.getPlaylistInfo(playlistId);
      return Success(playlistInfo);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get playlist info: $e'));
    }
  }

  @override
  Future<Result<Video>> refreshVideoInfo(String videoId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure('No internet connection available'));
      }

      // Clear cache first
      await localDataSource.clearVideoCache(videoId);

      // Fetch fresh data
      final videoModel = await remoteDataSource.refreshVideoInfo(videoId);
      
      // Cache the fresh data
      await localDataSource.cacheVideoInfo(videoId, videoModel);
      
      return Success(videoModel);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to refresh video info: $e'));
    }
  }

  @override
  Future<Result<bool>> isVideoAvailable(String videoId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure('No internet connection available'));
      }

      final isAvailable = await remoteDataSource.isVideoAvailable(videoId);
      return Success(isAvailable);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to check video availability: $e'));
    }
  }

  @override
  Future<Result<List<String>>> getVideoThumbnails(String videoId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure('No internet connection available'));
      }

      final thumbnails = await remoteDataSource.getVideoThumbnails(videoId);
      return Success(thumbnails);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get video thumbnails: $e'));
    }
  }

  @override
  Future<Result<bool>> reportVideo(String videoId, String reason) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure('No internet connection available'));
      }

      if (reason.trim().isEmpty) {
        return Error(ValidationFailure('Report reason cannot be empty'));
      }

      final success = await remoteDataSource.reportVideo(videoId, reason);
      return Success(success);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to report video: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getVideoAnalytics(String videoId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure('No internet connection available'));
      }

      final analytics = await remoteDataSource.getVideoAnalytics(videoId);
      return Success(analytics);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get video analytics: $e'));
    }
  }

  /// Helper method to check if cached data is expired
  bool _isCacheExpired(VideoModel cachedVideo) {
    // Implement cache expiration logic
    // For now, consider cache valid for 1 hour
    const cacheValidDuration = Duration(hours: 1);
    
    // This would need to be implemented based on when the video was cached
    // For now, return false (cache never expires)
    return false;
  }

  /// Generates cache key for search results
  String _generateSearchCacheKey(String query, String? platform, int page, int limit) {
    return 'search_${query}_${platform ?? 'all'}_${page}_$limit';
  }

  /// Generates cache key for trending videos
  String _generateTrendingCacheKey(String? platform, String? category, int page, int limit) {
    return 'trending_${platform ?? 'all'}_${category ?? 'all'}_${page}_$limit';
  }
}