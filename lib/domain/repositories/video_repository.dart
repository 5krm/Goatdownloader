import '../entities/video.dart';
import '../entities/download.dart';
import '../../core/error/failures.dart';

/// Result type for handling success and failure cases
sealed class Result<T> {
  const Result();
  
  /// Fold method to handle both success and error cases
  R fold<R>(
    R Function(Failure failure) onError,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final failure) => onError(failure),
    };
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

/// Abstract repository interface for video operations
/// 
/// This interface defines all video-related operations that can be performed
/// in the application. It follows the Repository pattern from Clean Architecture,
/// allowing the domain layer to be independent of data sources.
abstract class VideoRepository {
  /// Extracts video information from a given URL
  /// 
  /// [url] - The video URL to extract information from
  /// Returns either a [Failure] or a [Video] entity
  Future<Result<Video>> getVideoInfo(String url);

  /// Searches for videos on supported platforms
  /// 
  /// [query] - The search query string
  /// [platform] - Optional platform to search on (null for all platforms)
  /// [limit] - Maximum number of results to return
  /// Returns either a [Failure] or a list of [Video] entities
  Future<Result<List<Video>>> searchVideos({
    required String query,
    String? platform,
    int limit = 20,
  });

  /// Gets trending videos from supported platforms
  /// 
  /// [platform] - Optional platform to get trending from (null for all)
  /// [category] - Optional category filter
  /// [limit] - Maximum number of results to return
  /// Returns either a [Failure] or a list of [Video] entities
  Future<Result<List<Video>>> getTrendingVideos({
    String? platform,
    VideoCategory? category,
    int limit = 20,
  });

  /// Validates if a URL is supported for video extraction
  /// 
  /// [url] - The URL to validate
  /// Returns true if the URL is supported, false otherwise
  bool isUrlSupported(String url);

  /// Gets supported platforms list
  /// 
  /// Returns a list of supported platform names
  List<String> getSupportedPlatforms();

  /// Gets video formats for a specific video
  /// 
  /// [videoId] - The video ID
  /// [platform] - The platform name
  /// Returns either a [Failure] or a list of [VideoFormat] entities
  Future<Either<Failure, List<VideoFormat>>> getVideoFormats({
    required String videoId,
    required String platform,
  });

  /// Gets video subtitles if available
  /// 
  /// [videoId] - The video ID
  /// [platform] - The platform name
  /// [language] - Preferred subtitle language
  /// Returns either a [Failure] or subtitle data
  Future<Either<Failure, Map<String, dynamic>>> getVideoSubtitles({
    required String videoId,
    required String platform,
    String language = 'en',
  });

  /// Gets related videos for a given video
  /// 
  /// [videoId] - The video ID to get related videos for
  /// [platform] - The platform name
  /// [limit] - Maximum number of results to return
  /// Returns either a [Failure] or a list of [Video] entities
  Future<Either<Failure, List<Video>>> getRelatedVideos({
    required String videoId,
    required String platform,
    int limit = 10,
  });

  /// Gets video comments if available
  /// 
  /// [videoId] - The video ID
  /// [platform] - The platform name
  /// [limit] - Maximum number of comments to return
  /// Returns either a [Failure] or comment data
  Future<Either<Failure, List<Map<String, dynamic>>>> getVideoComments({
    required String videoId,
    required String platform,
    int limit = 20,
  });

  /// Gets channel/user information for a video
  /// 
  /// [channelId] - The channel/user ID
  /// [platform] - The platform name
  /// Returns either a [Failure] or channel information
  Future<Either<Failure, Map<String, dynamic>>> getChannelInfo({
    required String channelId,
    required String platform,
  });

  /// Gets videos from a specific channel/user
  /// 
  /// [channelId] - The channel/user ID
  /// [platform] - The platform name
  /// [limit] - Maximum number of videos to return
  /// Returns either a [Failure] or a list of [Video] entities
  Future<Either<Failure, List<Video>>> getChannelVideos({
    required String channelId,
    required String platform,
    int limit = 20,
  });

  /// Gets playlist information and videos
  /// 
  /// [playlistId] - The playlist ID
  /// [platform] - The platform name
  /// Returns either a [Failure] or playlist data with videos
  Future<Either<Failure, Map<String, dynamic>>> getPlaylistInfo({
    required String playlistId,
    required String platform,
  });

  /// Refreshes video information (updates metadata)
  /// 
  /// [video] - The video to refresh
  /// Returns either a [Failure] or updated [Video] entity
  Future<Either<Failure, Video>> refreshVideoInfo(Video video);

  /// Checks if video is still available on the platform
  /// 
  /// [video] - The video to check
  /// Returns either a [Failure] or availability status
  Future<Either<Failure, bool>> checkVideoAvailability(Video video);

  /// Gets video thumbnail in different sizes
  /// 
  /// [videoId] - The video ID
  /// [platform] - The platform name
  /// [size] - Thumbnail size preference
  /// Returns either a [Failure] or thumbnail URLs
  Future<Either<Failure, Map<String, String>>> getVideoThumbnails({
    required String videoId,
    required String platform,
    String size = 'medium',
  });

  /// Reports a video (for content moderation)
  /// 
  /// [videoId] - The video ID to report
  /// [platform] - The platform name
  /// [reason] - Reason for reporting
  /// Returns either a [Failure] or success status
  Future<Either<Failure, bool>> reportVideo({
    required String videoId,
    required String platform,
    required String reason,
  });

  /// Gets video analytics/statistics
  /// 
  /// [videoId] - The video ID
  /// [platform] - The platform name
  /// Returns either a [Failure] or analytics data
  Future<Either<Failure, Map<String, dynamic>>> getVideoAnalytics({
    required String videoId,
    required String platform,
  });
}