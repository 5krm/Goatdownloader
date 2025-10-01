import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:sqflite/sqflite.dart';

import '../models/video_model.dart';
import '../../core/error/exceptions.dart';
import '../../core/constants/app_constants.dart';

/// Abstract interface for local video data operations
abstract class VideoLocalDataSource {
  /// Caches video information locally
  Future<void> cacheVideoInfo(VideoModel video);

  /// Retrieves cached video information
  Future<VideoModel?> getCachedVideoInfo(String url);

  /// Caches search results
  Future<void> cacheSearchResults(String query, List<VideoModel> videos);

  /// Retrieves cached search results
  Future<List<VideoModel>?> getCachedSearchResults(String query);

  /// Caches trending videos
  Future<void> cacheTrendingVideos(List<VideoModel> videos, String platform);

  /// Retrieves cached trending videos
  Future<List<VideoModel>?> getCachedTrendingVideos(String platform);

  /// Clears all cached data
  Future<void> clearCache();

  /// Clears expired cache entries
  Future<void> clearExpiredCache();

  /// Gets cache size in bytes
  Future<int> getCacheSize();

  /// Checks if video is cached
  Future<bool> isVideoCached(String url);

  /// Updates video cache timestamp
  Future<void> updateCacheTimestamp(String url);

  /// Gets recently viewed videos
  Future<List<VideoModel>> getRecentlyViewed();

  /// Adds video to recently viewed
  Future<void> addToRecentlyViewed(VideoModel video);

  /// Clears recently viewed videos
  Future<void> clearRecentlyViewed();

  /// Gets favorite videos
  Future<List<VideoModel>> getFavoriteVideos();

  /// Adds video to favorites
  Future<void> addToFavorites(VideoModel video);

  /// Removes video from favorites
  Future<void> removeFromFavorites(String videoId);

  /// Checks if video is favorite
  Future<bool> isFavorite(String videoId);

  /// Gets watch history
  Future<List<VideoModel>> getWatchHistory();

  /// Adds video to watch history
  Future<void> addToWatchHistory(VideoModel video);

  /// Clears watch history
  Future<void> clearWatchHistory();
}

/// Implementation of VideoLocalDataSource using Hive and SQLite
class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  final Database database;
  late final Box<String> _videoCache;
  late final Box<String> _searchCache;
  late final Box<String> _trendingCache;
  late final Box<String> _recentlyViewed;
  late final Box<String> _favorites;
  late final Box<String> _watchHistory;

  VideoLocalDataSourceImpl({required this.database});

  /// Initialize Hive boxes
  Future<void> initialize() async {
    try {
      _videoCache = await Hive.openBox<String>(AppConstants.videoCacheBox);
      _searchCache = await Hive.openBox<String>(AppConstants.searchCacheBox);
      _trendingCache = await Hive.openBox<String>(AppConstants.trendingCacheBox);
      _recentlyViewed = await Hive.openBox<String>(AppConstants.recentlyViewedBox);
      _favorites = await Hive.openBox<String>(AppConstants.favoritesBox);
      _watchHistory = await Hive.openBox<String>(AppConstants.watchHistoryBox);
    } catch (e) {
      throw CacheException(message: 'Failed to initialize local data source: $e');
    }
  }

  @override
  Future<void> cacheVideoInfo(VideoModel video) async {
    try {
      final cacheEntry = {
        'video': video.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expires_at': DateTime.now()
            .add(const Duration(hours: AppConstants.cacheExpirationHours))
            .millisecondsSinceEpoch,
      };

      await _videoCache.put(video.url, jsonEncode(cacheEntry));

      // Also cache in SQLite for more complex queries
      await database.insert(
        'video_cache',
        {
          'url': video.url,
          'video_id': video.id,
          'title': video.title,
          'platform': video.platform,
          'data': jsonEncode(video.toJson()),
          'cached_at': DateTime.now().millisecondsSinceEpoch,
          'expires_at': DateTime.now()
              .add(const Duration(hours: AppConstants.cacheExpirationHours))
              .millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache video info: $e');
    }
  }

  @override
  Future<VideoModel?> getCachedVideoInfo(String url) async {
    try {
      final cachedData = _videoCache.get(url);
      if (cachedData == null) return null;

      final cacheEntry = jsonDecode(cachedData) as Map<String, dynamic>;
      final expiresAt = cacheEntry['expires_at'] as int;

      // Check if cache has expired
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        await _videoCache.delete(url);
        return null;
      }

      final videoData = cacheEntry['video'] as Map<String, dynamic>;
      return VideoModel.fromJson(videoData);
    } catch (e) {
      // If there's an error reading cache, return null
      return null;
    }
  }

  @override
  Future<void> cacheSearchResults(String query, List<VideoModel> videos) async {
    try {
      final cacheEntry = {
        'videos': videos.map((v) => v.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expires_at': DateTime.now()
            .add(const Duration(minutes: AppConstants.searchCacheExpirationMinutes))
            .millisecondsSinceEpoch,
      };

      await _searchCache.put(query.toLowerCase(), jsonEncode(cacheEntry));
    } catch (e) {
      throw CacheException(message: 'Failed to cache search results: $e');
    }
  }

  @override
  Future<List<VideoModel>?> getCachedSearchResults(String query) async {
    try {
      final cachedData = _searchCache.get(query.toLowerCase());
      if (cachedData == null) return null;

      final cacheEntry = jsonDecode(cachedData) as Map<String, dynamic>;
      final expiresAt = cacheEntry['expires_at'] as int;

      // Check if cache has expired
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        await _searchCache.delete(query.toLowerCase());
        return null;
      }

      final videosData = cacheEntry['videos'] as List<dynamic>;
      return videosData
          .map((v) => VideoModel.fromJson(v as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheTrendingVideos(List<VideoModel> videos, String platform) async {
    try {
      final cacheEntry = {
        'videos': videos.map((v) => v.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expires_at': DateTime.now()
            .add(const Duration(hours: AppConstants.trendingCacheExpirationHours))
            .millisecondsSinceEpoch,
      };

      await _trendingCache.put(platform, jsonEncode(cacheEntry));
    } catch (e) {
      throw CacheException(message: 'Failed to cache trending videos: $e');
    }
  }

  @override
  Future<List<VideoModel>?> getCachedTrendingVideos(String platform) async {
    try {
      final cachedData = _trendingCache.get(platform);
      if (cachedData == null) return null;

      final cacheEntry = jsonDecode(cachedData) as Map<String, dynamic>;
      final expiresAt = cacheEntry['expires_at'] as int;

      // Check if cache has expired
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        await _trendingCache.delete(platform);
        return null;
      }

      final videosData = cacheEntry['videos'] as List<dynamic>;
      return videosData
          .map((v) => VideoModel.fromJson(v as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _videoCache.clear();
      await _searchCache.clear();
      await _trendingCache.clear();
      
      await database.delete('video_cache');
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  @override
  Future<void> clearExpiredCache() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Clear expired video cache
      final videoKeys = _videoCache.keys.toList();
      for (final key in videoKeys) {
        final cachedData = _videoCache.get(key);
        if (cachedData != null) {
          try {
            final cacheEntry = jsonDecode(cachedData) as Map<String, dynamic>;
            final expiresAt = cacheEntry['expires_at'] as int;
            if (now > expiresAt) {
              await _videoCache.delete(key);
            }
          } catch (e) {
            // If we can't parse the entry, delete it
            await _videoCache.delete(key);
          }
        }
      }

      // Clear expired search cache
      final searchKeys = _searchCache.keys.toList();
      for (final key in searchKeys) {
        final cachedData = _searchCache.get(key);
        if (cachedData != null) {
          try {
            final cacheEntry = jsonDecode(cachedData) as Map<String, dynamic>;
            final expiresAt = cacheEntry['expires_at'] as int;
            if (now > expiresAt) {
              await _searchCache.delete(key);
            }
          } catch (e) {
            await _searchCache.delete(key);
          }
        }
      }

      // Clear expired trending cache
      final trendingKeys = _trendingCache.keys.toList();
      for (final key in trendingKeys) {
        final cachedData = _trendingCache.get(key);
        if (cachedData != null) {
          try {
            final cacheEntry = jsonDecode(cachedData) as Map<String, dynamic>;
            final expiresAt = cacheEntry['expires_at'] as int;
            if (now > expiresAt) {
              await _trendingCache.delete(key);
            }
          } catch (e) {
            await _trendingCache.delete(key);
          }
        }
      }

      // Clear expired SQLite cache
      await database.delete(
        'video_cache',
        where: 'expires_at < ?',
        whereArgs: [now],
      );
    } catch (e) {
      throw CacheException(message: 'Failed to clear expired cache: $e');
    }
  }

  @override
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;

      // Calculate Hive cache sizes
      for (final value in _videoCache.values) {
        totalSize += value.length * 2; // Rough estimate (UTF-16)
      }
      for (final value in _searchCache.values) {
        totalSize += value.length * 2;
      }
      for (final value in _trendingCache.values) {
        totalSize += value.length * 2;
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<bool> isVideoCached(String url) async {
    try {
      final cachedData = _videoCache.get(url);
      if (cachedData == null) return false;

      final cacheEntry = jsonDecode(cachedData) as Map<String, dynamic>;
      final expiresAt = cacheEntry['expires_at'] as int;

      return DateTime.now().millisecondsSinceEpoch <= expiresAt;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateCacheTimestamp(String url) async {
    try {
      final cachedData = _videoCache.get(url);
      if (cachedData != null) {
        final cacheEntry = jsonDecode(cachedData) as Map<String, dynamic>;
        cacheEntry['timestamp'] = DateTime.now().millisecondsSinceEpoch;
        await _videoCache.put(url, jsonEncode(cacheEntry));
      }
    } catch (e) {
      // Ignore errors when updating timestamp
    }
  }

  @override
  Future<List<VideoModel>> getRecentlyViewed() async {
    try {
      final videos = <VideoModel>[];
      final keys = _recentlyViewed.keys.toList();
      
      // Sort by timestamp (most recent first)
      keys.sort((a, b) {
        final aData = _recentlyViewed.get(a);
        final bData = _recentlyViewed.get(b);
        if (aData == null || bData == null) return 0;
        
        try {
          final aEntry = jsonDecode(aData) as Map<String, dynamic>;
          final bEntry = jsonDecode(bData) as Map<String, dynamic>;
          final aTime = aEntry['timestamp'] as int;
          final bTime = bEntry['timestamp'] as int;
          return bTime.compareTo(aTime);
        } catch (e) {
          return 0;
        }
      });

      for (final key in keys.take(AppConstants.maxRecentlyViewed)) {
        final data = _recentlyViewed.get(key);
        if (data != null) {
          try {
            final entry = jsonDecode(data) as Map<String, dynamic>;
            final videoData = entry['video'] as Map<String, dynamic>;
            videos.add(VideoModel.fromJson(videoData));
          } catch (e) {
            // Skip invalid entries
          }
        }
      }

      return videos;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addToRecentlyViewed(VideoModel video) async {
    try {
      final entry = {
        'video': video.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _recentlyViewed.put(video.id, jsonEncode(entry));

      // Keep only the most recent items
      if (_recentlyViewed.length > AppConstants.maxRecentlyViewed) {
        final keys = _recentlyViewed.keys.toList();
        final entries = <MapEntry<String, int>>[];

        for (final key in keys) {
          final data = _recentlyViewed.get(key);
          if (data != null) {
            try {
              final entry = jsonDecode(data) as Map<String, dynamic>;
              final timestamp = entry['timestamp'] as int;
              entries.add(MapEntry(key, timestamp));
            } catch (e) {
              // Remove invalid entries
              await _recentlyViewed.delete(key);
            }
          }
        }

        // Sort by timestamp and remove oldest entries
        entries.sort((a, b) => b.value.compareTo(a.value));
        for (int i = AppConstants.maxRecentlyViewed; i < entries.length; i++) {
          await _recentlyViewed.delete(entries[i].key);
        }
      }
    } catch (e) {
      throw CacheException(message: 'Failed to add to recently viewed: $e');
    }
  }

  @override
  Future<void> clearRecentlyViewed() async {
    try {
      await _recentlyViewed.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear recently viewed: $e');
    }
  }

  @override
  Future<List<VideoModel>> getFavoriteVideos() async {
    try {
      final videos = <VideoModel>[];
      
      for (final data in _favorites.values) {
        try {
          final entry = jsonDecode(data) as Map<String, dynamic>;
          final videoData = entry['video'] as Map<String, dynamic>;
          videos.add(VideoModel.fromJson(videoData));
        } catch (e) {
          // Skip invalid entries
        }
      }

      return videos;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addToFavorites(VideoModel video) async {
    try {
      final entry = {
        'video': video.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _favorites.put(video.id, jsonEncode(entry));
    } catch (e) {
      throw CacheException(message: 'Failed to add to favorites: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(String videoId) async {
    try {
      await _favorites.delete(videoId);
    } catch (e) {
      throw CacheException(message: 'Failed to remove from favorites: $e');
    }
  }

  @override
  Future<bool> isFavorite(String videoId) async {
    try {
      return _favorites.containsKey(videoId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<VideoModel>> getWatchHistory() async {
    try {
      final videos = <VideoModel>[];
      final keys = _watchHistory.keys.toList();
      
      // Sort by timestamp (most recent first)
      keys.sort((a, b) {
        final aData = _watchHistory.get(a);
        final bData = _watchHistory.get(b);
        if (aData == null || bData == null) return 0;
        
        try {
          final aEntry = jsonDecode(aData) as Map<String, dynamic>;
          final bEntry = jsonDecode(bData) as Map<String, dynamic>;
          final aTime = aEntry['timestamp'] as int;
          final bTime = bEntry['timestamp'] as int;
          return bTime.compareTo(aTime);
        } catch (e) {
          return 0;
        }
      });

      for (final key in keys) {
        final data = _watchHistory.get(key);
        if (data != null) {
          try {
            final entry = jsonDecode(data) as Map<String, dynamic>;
            final videoData = entry['video'] as Map<String, dynamic>;
            videos.add(VideoModel.fromJson(videoData));
          } catch (e) {
            // Skip invalid entries
          }
        }
      }

      return videos;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addToWatchHistory(VideoModel video) async {
    try {
      final entry = {
        'video': video.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _watchHistory.put(video.id, jsonEncode(entry));
    } catch (e) {
      throw CacheException(message: 'Failed to add to watch history: $e');
    }
  }

  @override
  Future<void> clearWatchHistory() async {
    try {
      await _watchHistory.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear watch history: $e');
    }
  }
}