import 'package:dio/dio.dart';
import 'package:goatdownloder/domain/entities/video.dart';
import 'package:html/parser.dart' as html_parser;

import '../models/video_model.dart';
import '../../core/error/exceptions.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/network_info.dart';

/// Abstract interface for remote video data operations
abstract class VideoRemoteDataSource {
  /// Extracts video information from a URL
  Future<VideoModel> getVideoInfo(String url);

  /// Searches for videos on supported platforms
  Future<List<VideoModel>> searchVideos({
    required String query,
    List<String> platforms = const [],
    int page = 1,
    int limit = 20,
    String? sortBy,
    Map<String, dynamic>? filters,
  });

  /// Gets trending videos from supported platforms
  Future<List<VideoModel>> getTrendingVideos({
    List<String> platforms = const [],
    String? category,
    String? region,
    int page = 1,
    int limit = 20,
  });

  /// Validates if a URL is supported and accessible
  Future<bool> validateUrl(String url);

  /// Gets available video formats for a URL
  Future<List<VideoFormatModel>> getVideoFormats(String url);

  /// Gets video subtitles/captions
  Future<List<String>> getVideoSubtitles(String url);

  /// Gets related videos
  Future<List<VideoModel>> getRelatedVideos(String videoId, String platform);

  /// Gets video comments
  Future<List<Map<String, dynamic>>> getVideoComments(String videoId, String platform);

  /// Gets channel information
  Future<Map<String, dynamic>> getChannelInfo(String channelId, String platform);

  /// Gets playlist information
  Future<Map<String, dynamic>> getPlaylistInfo(String playlistId, String platform);

  /// Refreshes video information (bypasses cache)
  Future<VideoModel> refreshVideoInfo(String url);

  /// Checks if video is available
  Future<bool> isVideoAvailable(String url);

  /// Gets video thumbnails in different resolutions
  Future<List<String>> getVideoThumbnails(String url);

  /// Reports a video (for content moderation)
  Future<bool> reportVideo(String videoId, String platform, String reason);

  /// Gets video analytics/statistics
  Future<Map<String, dynamic>> getVideoAnalytics(String videoId, String platform);
}

/// Implementation of VideoRemoteDataSource using multiple extractors
class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final Dio dio;
  final NetworkInfo networkInfo;

  VideoRemoteDataSourceImpl({
    required this.dio,
    required this.networkInfo,
  });

  @override
  Future<VideoModel> getVideoInfo(String url) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      final platform = _detectPlatform(url);
      
      switch (platform) {
        case 'youtube':
          return await _getYouTubeVideoInfo(url);
        case 'facebook':
          return await _getFacebookVideoInfo(url);
        case 'instagram':
          return await _getInstagramVideoInfo(url);
        case 'tiktok':
          return await _getTikTokVideoInfo(url);
        default:
          throw UnsupportedFormatException('Platform not supported: $platform', message: 'Platform not supported: $platform');
      }
    } on DioException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw VideoProcessingException(message: 'Failed to extract video info: $e');        
    }
  }

  @override
  Future<List<VideoModel>> searchVideos({
    required String query,
    List<String> platforms = const [],
    int page = 1,
    int limit = 20,
    String? sortBy,
    Map<String, dynamic>? filters,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      final List<VideoModel> allResults = [];
      final targetPlatforms = platforms.isEmpty ? ['youtube'] : platforms;

      for (final platform in targetPlatforms) {
        try {
          List<VideoModel> platformResults;
          
          switch (platform) {
            case 'youtube':
              platformResults = await _searchYouTubeVideos(query, page, limit, sortBy);
              break;
            case 'facebook':
              platformResults = await _searchFacebookVideos(query, page, limit);
              break;
            case 'instagram':
              platformResults = await _searchInstagramVideos(query, page, limit);
              break;
            case 'tiktok':
              platformResults = await _searchTikTokVideos(query, page, limit);
              break;
            default:
              continue;
          }
          
          allResults.addAll(platformResults);
        } catch (e) {
          // Continue with other platforms if one fails
          continue;
        }
      }

      return allResults;
    } on DioException catch (e) {
      throw NetworkException(message: 'Network error during search: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: 'Search failed: $e');
    }
  }

  @override
  Future<List<VideoModel>> getTrendingVideos({
    List<String> platforms = const [],
    String? category,
    String? region,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      final List<VideoModel> allResults = [];
      final targetPlatforms = platforms.isEmpty ? ['youtube'] : platforms;

      for (final platform in targetPlatforms) {
        try {
          List<VideoModel> platformResults;
          
          switch (platform) {
            case 'youtube':
              platformResults = await _getYouTubeTrendingVideos(category, region, limit);
              break;
            case 'facebook':
              platformResults = await _getFacebookTrendingVideos(limit);
              break;
            case 'instagram':
              platformResults = await _getInstagramTrendingVideos(limit);
              break;
            case 'tiktok':
              platformResults = await _getTikTokTrendingVideos(limit);
              break;
            default:
              continue;
          }
          
          allResults.addAll(platformResults);
        } catch (e) {
          // Continue with other platforms if one fails
          continue;
        }
      }

      return allResults;
    } on DioException catch (e) {
      throw NetworkException(message: 'Network error during trending fetch: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: 'Trending fetch failed: $e');  
    }
  }

  @override
  Future<bool> validateUrl(String url) async {
    try {
      if (!await networkInfo.isConnected) {
        return false;
      }

      final platform = _detectPlatform(url);
      if (platform == 'unknown') {
        return false;
      }

      // Try to get basic info to validate
      await getVideoInfo(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<VideoFormatModel>> getVideoFormats(String url) async {
    try {
      final video = await getVideoInfo(url);
      return video.availableFormats.map((format) => 
        format is VideoFormatModel ? format : VideoFormatModel.fromEntity(format)
      ).toList();
    } catch (e) {
      throw VideoProcessingException(message: 'Failed to get video formats: $e');
    }
  }

  @override
  Future<List<String>> getVideoSubtitles(String url) async {
    try {
      final video = await getVideoInfo(url);
      // Return empty list for now since VideoModel doesn't have subtitles property
      // This should be implemented based on the actual subtitle extraction logic
      return [];
    } catch (e) {
      throw VideoProcessingException(message: 'Failed to get video subtitles: $e');
    }
  }

  @override
  Future<List<VideoModel>> getRelatedVideos(String videoId, String platform) async {
    // Mock implementation - return empty list for now
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getVideoComments(String videoId, String platform) async {
    // Mock implementation - return empty list for now
    return [];
  }

  @override
  Future<Map<String, dynamic>> getChannelInfo(String channelId, String platform) async {
    // Mock implementation
    return {
      'id': channelId,
      'name': 'Sample Channel',
      'description': 'Sample channel description',
      'subscriberCount': 100000,
      'videoCount': 500,
    };
  }

  @override
  Future<Map<String, dynamic>> getPlaylistInfo(String playlistId, String platform) async {
    // Mock implementation
    return {
      'id': playlistId,
      'title': 'Sample Playlist',
      'description': 'Sample playlist description',
      'videoCount': 25,
    };
  }

  @override
  Future<VideoModel> refreshVideoInfo(String url) async {
    // For now, just call getVideoInfo (no caching implemented yet)
    return await getVideoInfo(url);
  }

  @override
  Future<bool> isVideoAvailable(String url) async {
    return await validateUrl(url);
  }

  @override
  Future<List<String>> getVideoThumbnails(String url) async {
    try {
      final video = await getVideoInfo(url);
      return [video.thumbnailUrl];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> reportVideo(String videoId, String platform, String reason) async {
    // Mock implementation - always return true
    return true;
  }

  @override
  Future<Map<String, dynamic>> getVideoAnalytics(String videoId, String platform) async {
    // Mock implementation
    return {
      'views': 1000000,
      'likes': 50000,
      'dislikes': 1000,
      'comments': 5000,
      'shares': 2500,
    };
  }

  // Helper methods
  String _detectPlatform(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return 'youtube';
    } else if (url.contains('facebook.com') || url.contains('fb.watch')) {
      return 'facebook';
    } else if (url.contains('instagram.com')) {
      return 'instagram';
    } else if (url.contains('tiktok.com')) {
      return 'tiktok';
    }

    return 'unknown';
  }

  String _extractVideoId(String url) {
    if (url.contains('youtube.com/watch?v=')) {
      return url.split('v=')[1].split('&')[0];
    } else if (url.contains('youtu.be/')) {
      return url.split('youtu.be/')[1].split('?')[0];
    }
    return 'mock_video_id';
  }

  // YouTube-specific implementations
  Future<VideoModel> _getYouTubeVideoInfo(String url) async {
    try {
      // Mock implementation for YouTube video info
      final videoId = _extractVideoId(url);
      
      return VideoModel(
        id: videoId,
        title: 'Sample YouTube Video',
        description: 'This is a sample video description for testing purposes.',
        originalUrl: url,
        thumbnailUrl: 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
        platform: 'youtube',
        duration: const Duration(minutes: 5, seconds: 30),
        uploader: 'Sample Channel',
        uploadDate: DateTime.now().subtract(const Duration(days: 7)),
        viewCount: 1000000,
        availableFormats: const [
          VideoFormatModel(
            formatId: '22',
            url: 'https://sample-video-url.mp4',
            qualityLabel: '720p',
            quality: 720,
            extension: 'mp4',
            fileSize: 50000000,
            bitrate: 1000000,
            codec: 'avc1.64001F',
            type: FormatType.video,
            hasAudio: true,
            hasVideo: true,
          ),
        ],
        tags: const ['sample', 'video', 'test'],
        category: VideoCategory.entertainment,
        language: 'en',
        isLiveStream: false,
        isPrivate: false,
        hasSubtitles: false,
        metadata: const {},
      );
    } catch (e) {
      throw VideoProcessingException('Failed to extract YouTube video: $e');
    }
  }

  Future<List<VideoModel>> _searchYouTubeVideos(String query, int page, int limit, String? sortBy) async {
    try {
      // Mock implementation for YouTube search
      final videos = <VideoModel>[];
      
      // Generate mock search results
      for (int i = 0; i < limit; i++) {
        final videoId = 'mock_video_${i + ((page - 1) * limit)}';
        videos.add(VideoModel(
          id: videoId,
          title: 'Sample Video ${i + 1} - $query',
          description: 'This is a sample video description for search query: $query',
          originalUrl: 'https://youtube.com/watch?v=$videoId',
          thumbnailUrl: 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
          platform: 'youtube',
          duration: Duration(minutes: 3 + (i % 10), seconds: 30),
          uploader: 'Sample Channel ${i + 1}',
          uploadDate: DateTime.now().subtract(Duration(days: i + 1)),
          viewCount: 100000 + (i * 10000),
          availableFormats: const [],
          tags: ['sample', 'video', query.toLowerCase()],
          category: VideoCategory.entertainment,
          language: 'en',
          isLiveStream: false,
          isPrivate: false,
          hasSubtitles: false,
          metadata: const {},
        ));
      }

      return videos;
    } catch (e) {
      throw ServerException('YouTube search failed: $e');
    }
  }

  Future<List<VideoModel>> _getYouTubeTrendingVideos(String? category, String? region, int limit) async {
    // Mock implementation using search
    return await _searchYouTubeVideos('trending', 1, limit, 'relevance');
  }

  // Placeholder implementations for other platforms
  Future<VideoModel> _getFacebookVideoInfo(String url) async {
    throw UnsupportedFormatException(message: 'Facebook extraction not yet implemented');
  }

  Future<VideoModel> _getInstagramVideoInfo(String url) async {
    throw UnsupportedFormatException(message: 'Instagram extraction not yet implemented');
  }

  Future<VideoModel> _getTikTokVideoInfo(String url) async {
    throw UnsupportedFormatException(message: 'TikTok extraction not yet implemented');
  }

  Future<List<VideoModel>> _searchFacebookVideos(String query, int page, int limit) async {
    throw UnsupportedFormatException(message: 'Facebook search not yet implemented');
  }

  Future<List<VideoModel>> _searchInstagramVideos(String query, int page, int limit) async {
    throw UnsupportedFormatException(message: 'Instagram search not yet implemented');
  }

  Future<List<VideoModel>> _searchTikTokVideos(String query, int page, int limit) async {
    throw UnsupportedFormatException(message: 'TikTok search not yet implemented');
  }

  Future<List<VideoModel>> _getFacebookTrendingVideos(int limit) async {
    throw UnsupportedFormatException(message: 'Facebook trending not yet implemented');
  }

  Future<List<VideoModel>> _getInstagramTrendingVideos(int limit) async {
    throw UnsupportedFormatException(message: 'Instagram trending not yet implemented');
  }

  Future<List<VideoModel>> _getTikTokTrendingVideos(int limit) async {
    throw UnsupportedFormatException(message: 'TikTok trending not yet implemented');
  }
}