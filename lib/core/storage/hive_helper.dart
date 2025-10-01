import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import '../../data/models/video_model.dart';
import '../../data/models/download_model.dart';

/// Hive helper class for managing Hive storage
class HiveHelper {
  static HiveHelper? _instance;
  
  // Box names
  static const String _videoBox = 'video_box';
  static const String _downloadBox = 'download_box';
  static const String _settingsBox = 'settings_box';
  static const String _cacheBox = 'cache_box';
  static const String _userPrefsBox = 'user_prefs_box';
  static const String _searchHistoryBox = 'search_history_box';
  static const String _downloadHistoryBox = 'download_history_box';

  // Boxes
  Box<VideoModel>? _videoBoxInstance;
  Box<DownloadModel>? _downloadBoxInstance;
  Box<dynamic>? _settingsBoxInstance;
  Box<dynamic>? _cacheBoxInstance;
  Box<dynamic>? _userPrefsBoxInstance;
  Box<String>? _searchHistoryBoxInstance;
  Box<Map<String, dynamic>>? _downloadHistoryBoxInstance;

  HiveHelper._internal();

  factory HiveHelper() {
    _instance ??= HiveHelper._internal();
    return _instance!;
  }

  /// Initializes Hive storage
  Future<void> init() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Get application documents directory
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final hiveDir = Directory('${appDocumentDir.path}/hive');
      
      // Create hive directory if it doesn't exist
      if (!await hiveDir.exists()) {
        await hiveDir.create(recursive: true);
      }

      // Set Hive directory
      Hive.init(hiveDir.path);

      // Register adapters
      await _registerAdapters();

      // Open boxes
      await _openBoxes();
    } catch (e) {
      throw StorageException(message: 'Failed to initialize Hive: $e');
    }
  }

  /// Registers Hive adapters
  Future<void> _registerAdapters() async {
    try {
      // Register VideoModel adapter
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(VideoModelAdapter());
      }

      // Register VideoFormatModel adapter
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(VideoFormatModelAdapter());
      }

      // Register DownloadModel adapter
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(DownloadModelAdapter());
      }

      // Register DownloadStatsModel adapter
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(DownloadStatsModelAdapter());
      }
    } catch (e) {
      throw StorageException(message: 'Failed to register Hive adapters: $e');
    }
  }

  /// Opens all Hive boxes
  Future<void> _openBoxes() async {
    try {
      _videoBoxInstance = await Hive.openBox<VideoModel>(_videoBox);
      _downloadBoxInstance = await Hive.openBox<DownloadModel>(_downloadBox);
      _settingsBoxInstance = await Hive.openBox(_settingsBox);
      _cacheBoxInstance = await Hive.openBox(_cacheBox);
      _userPrefsBoxInstance = await Hive.openBox(_userPrefsBox);
      _searchHistoryBoxInstance = await Hive.openBox<String>(_searchHistoryBox);
      _downloadHistoryBoxInstance = await Hive.openBox<Map<String, dynamic>>(_downloadHistoryBox);
    } catch (e) {
      throw StorageException(message: 'Failed to open Hive boxes: $e');
    }
  }

  /// Gets video box
  Box<VideoModel> get videoBox {
    if (_videoBoxInstance == null || !_videoBoxInstance!.isOpen) {
      throw StorageException(message: 'Video box is not initialized');
    }
    return _videoBoxInstance!;
  }

  /// Gets download box
  Box<DownloadModel> get downloadBox {
    if (_downloadBoxInstance == null || !_downloadBoxInstance!.isOpen) {
      throw StorageException(message: 'Download box is not initialized');
    }
    return _downloadBoxInstance!;
  }

  /// Gets settings box
  Box<dynamic> get settingsBox {
    if (_settingsBoxInstance == null || !_settingsBoxInstance!.isOpen) {
      throw StorageException(message: 'Settings box is not initialized');
    }
    return _settingsBoxInstance!;
  }

  /// Gets cache box
  Box<dynamic> get cacheBox {
    if (_cacheBoxInstance == null || !_cacheBoxInstance!.isOpen) {
      throw StorageException(message: 'Cache box is not initialized');
    }
    return _cacheBoxInstance!;
  }

  /// Gets user preferences box
  Box<dynamic> get userPrefsBox {
    if (_userPrefsBoxInstance == null || !_userPrefsBoxInstance!.isOpen) {
      throw StorageException(message: 'User preferences box is not initialized');
    }
    return _userPrefsBoxInstance!;
  }

  /// Gets search history box
  Box<String> get searchHistoryBox {
    if (_searchHistoryBoxInstance == null || !_searchHistoryBoxInstance!.isOpen) {
      throw StorageException(message: 'Search history box is not initialized');
    }
    return _searchHistoryBoxInstance!;
  }

  /// Gets download history box
  Box<Map<String, dynamic>> get downloadHistoryBox {
    if (_downloadHistoryBoxInstance == null || !_downloadHistoryBoxInstance!.isOpen) {
      throw StorageException(message: 'Download history box is not initialized');
    }
    return _downloadHistoryBoxInstance!;
  }

  /// Saves video to cache
  Future<void> saveVideo(String key, VideoModel video) async {
    try {
      await videoBox.put(key, video);
    } catch (e) {
      throw StorageException(message: 'Failed to save video: $e');
    }
  }

  /// Gets video from cache
  VideoModel? getVideo(String key) {
    try {
      return videoBox.get(key);
    } catch (e) {
      throw StorageException(message: 'Failed to get video: $e');
    }
  }

  /// Removes video from cache
  Future<void> removeVideo(String key) async {
    try {
      await videoBox.delete(key);
    } catch (e) {
      throw StorageException(message: 'Failed to remove video: $e');
    }
  }

  /// Gets all cached videos
  List<VideoModel> getAllVideos() {
    try {
      return videoBox.values.toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get all videos: $e');
    }
  }

  /// Saves download
  Future<void> saveDownload(String key, DownloadModel download) async {
    try {
      await downloadBox.put(key, download);
    } catch (e) {
      throw StorageException(message: 'Failed to save download: $e');
    }
  }

  /// Gets download
  DownloadModel? getDownload(String key) {
    try {
      return downloadBox.get(key);
    } catch (e) {
      throw StorageException(message: 'Failed to get download: $e');
    }
  }

  /// Removes download
  Future<void> removeDownload(String key) async {
    try {
      await downloadBox.delete(key);
    } catch (e) {
      throw StorageException(message: 'Failed to remove download: $e');
    }
  }

  /// Gets all downloads
  List<DownloadModel> getAllDownloads() {
    try {
      return downloadBox.values.toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get all downloads: $e');
    }
  }

  /// Saves setting
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await settingsBox.put(key, value);
    } catch (e) {
      throw StorageException(message: 'Failed to save setting: $e');
    }
  }

  /// Gets setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      return settingsBox.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      throw StorageException(message: 'Failed to get setting: $e');
    }
  }

  /// Removes setting
  Future<void> removeSetting(String key) async {
    try {
      await settingsBox.delete(key);
    } catch (e) {
      throw StorageException(message: 'Failed to remove setting: $e');
    }
  }

  /// Gets all settings
  Map<String, dynamic> getAllSettings() {
    try {
      return Map<String, dynamic>.from(settingsBox.toMap());
    } catch (e) {
      throw StorageException(message: 'Failed to get all settings: $e');
    }
  }

  /// Saves cache data
  Future<void> saveCache(String key, dynamic value, {Duration? expiry}) async {
    try {
      final cacheData = {
        'value': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': expiry?.inMilliseconds,
      };
      await cacheBox.put(key, cacheData);
    } catch (e) {
      throw StorageException(message: 'Failed to save cache: $e');
    }
  }

  /// Gets cache data
  T? getCache<T>(String key) {
    try {
      final cacheData = cacheBox.get(key);
      if (cacheData == null) return null;

      final Map<String, dynamic> data = Map<String, dynamic>.from(cacheData);
      final timestamp = data['timestamp'] as int;
      final expiry = data['expiry'] as int?;

      // Check if cache is expired
      if (expiry != null) {
        final expiryTime = timestamp + expiry;
        if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
          // Cache expired, remove it
          cacheBox.delete(key);
          return null;
        }
      }

      return data['value'] as T?;
    } catch (e) {
      throw StorageException(message: 'Failed to get cache: $e');
    }
  }

  /// Removes cache data
  Future<void> removeCache(String key) async {
    try {
      await cacheBox.delete(key);
    } catch (e) {
      throw StorageException(message: 'Failed to remove cache: $e');
    }
  }

  /// Clears all cache
  Future<void> clearCache() async {
    try {
      await cacheBox.clear();
    } catch (e) {
      throw StorageException(message: 'Failed to clear cache: $e');
    }
  }

  /// Clears expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      final keysToRemove = <String>[];
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final key in cacheBox.keys) {
        final cacheData = cacheBox.get(key);
        if (cacheData != null) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(cacheData);
          final timestamp = data['timestamp'] as int;
          final expiry = data['expiry'] as int?;

          if (expiry != null) {
            final expiryTime = timestamp + expiry;
            if (now > expiryTime) {
              keysToRemove.add(key.toString());
            }
          }
        }
      }

      for (final key in keysToRemove) {
        await cacheBox.delete(key);
      }
    } catch (e) {
      throw StorageException(message: 'Failed to clear expired cache: $e');
    }
  }

  /// Saves user preference
  Future<void> saveUserPreference(String key, dynamic value) async {
    try {
      await userPrefsBox.put(key, value);
    } catch (e) {
      throw StorageException(message: 'Failed to save user preference: $e');
    }
  }

  /// Gets user preference
  T? getUserPreference<T>(String key, {T? defaultValue}) {
    try {
      return userPrefsBox.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      throw StorageException(message: 'Failed to get user preference: $e');
    }
  }

  /// Adds search query to history
  Future<void> addSearchHistory(String query) async {
    try {
      final history = searchHistoryBox.values.toList();
      
      // Remove if already exists
      history.remove(query);
      
      // Add to beginning
      history.insert(0, query);
      
      // Keep only last 50 searches
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }
      
      // Clear and add all
      await searchHistoryBox.clear();
      await searchHistoryBox.addAll(history);
    } catch (e) {
      throw StorageException(message: 'Failed to add search history: $e');
    }
  }

  /// Gets search history
  List<String> getSearchHistory() {
    try {
      return searchHistoryBox.values.toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get search history: $e');
    }
  }

  /// Clears search history
  Future<void> clearSearchHistory() async {
    try {
      await searchHistoryBox.clear();
    } catch (e) {
      throw StorageException(message: 'Failed to clear search history: $e');
    }
  }

  /// Adds download to history
  Future<void> addDownloadHistory(Map<String, dynamic> downloadInfo) async {
    try {
      final key = '${DateTime.now().millisecondsSinceEpoch}';
      await downloadHistoryBox.put(key, downloadInfo);
      
      // Keep only last 100 downloads
      if (downloadHistoryBox.length > 100) {
        final keys = downloadHistoryBox.keys.toList()..sort();
        final keysToRemove = keys.take(downloadHistoryBox.length - 100);
        for (final key in keysToRemove) {
          await downloadHistoryBox.delete(key);
        }
      }
    } catch (e) {
      throw StorageException(message: 'Failed to add download history: $e');
    }
  }

  /// Gets download history
  List<Map<String, dynamic>> getDownloadHistory() {
    try {
      return downloadHistoryBox.values.toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get download history: $e');
    }
  }

  /// Clears download history
  Future<void> clearDownloadHistory() async {
    try {
      await downloadHistoryBox.clear();
    } catch (e) {
      throw StorageException(message: 'Failed to clear download history: $e');
    }
  }

  /// Gets storage size for all boxes
  Future<int> getStorageSize() async {
    try {
      int totalSize = 0;
      
      // Calculate size for each box
      final boxes = [
        _videoBoxInstance,
        _downloadBoxInstance,
        _settingsBoxInstance,
        _cacheBoxInstance,
        _userPrefsBoxInstance,
        _searchHistoryBoxInstance,
        _downloadHistoryBoxInstance,
      ];

      for (final box in boxes) {
        if (box != null && box.isOpen) {
          // Estimate size based on number of entries
          // This is an approximation since Hive doesn't provide exact size
          totalSize += box.length * 1024; // Assume 1KB per entry on average
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Compacts all boxes to reduce storage size
  Future<void> compactStorage() async {
    try {
      final boxes = [
        _videoBoxInstance,
        _downloadBoxInstance,
        _settingsBoxInstance,
        _cacheBoxInstance,
        _userPrefsBoxInstance,
        _searchHistoryBoxInstance,
        _downloadHistoryBoxInstance,
      ];

      for (final box in boxes) {
        if (box != null && box.isOpen) {
          await box.compact();
        }
      }
    } catch (e) {
      throw StorageException(message: 'Failed to compact storage: $e');
    }
  }

  /// Closes all boxes
  Future<void> close() async {
    try {
      await _videoBoxInstance?.close();
      await _downloadBoxInstance?.close();
      await _settingsBoxInstance?.close();
      await _cacheBoxInstance?.close();
      await _userPrefsBoxInstance?.close();
      await _searchHistoryBoxInstance?.close();
      await _downloadHistoryBoxInstance?.close();
    } catch (e) {
      throw StorageException(message: 'Failed to close Hive boxes: $e');
    }
  }

  /// Deletes all Hive data
  Future<void> deleteAllData() async {
    try {
      await close();
      await Hive.deleteFromDisk();
    } catch (e) {
      throw StorageException(message: 'Failed to delete Hive data: $e');
    }
  }

  /// Gets storage information
  Map<String, dynamic> getStorageInfo() {
    try {
      return {
        'video_cache': _videoBoxInstance?.length ?? 0,
        'downloads': _downloadBoxInstance?.length ?? 0,
        'settings': _settingsBoxInstance?.length ?? 0,
        'cache': _cacheBoxInstance?.length ?? 0,
        'user_prefs': _userPrefsBoxInstance?.length ?? 0,
        'search_history': _searchHistoryBoxInstance?.length ?? 0,
        'download_history': _downloadHistoryBoxInstance?.length ?? 0,
        'total_entries': (_videoBoxInstance?.length ?? 0) +
            (_downloadBoxInstance?.length ?? 0) +
            (_settingsBoxInstance?.length ?? 0) +
            (_cacheBoxInstance?.length ?? 0) +
            (_userPrefsBoxInstance?.length ?? 0) +
            (_searchHistoryBoxInstance?.length ?? 0) +
            (_downloadHistoryBoxInstance?.length ?? 0),
      };
    } catch (e) {
      throw StorageException(message: 'Failed to get storage info: $e');
    }
  }

  /// Saves data to a specific box
  Future<void> saveToBox(String boxName, String key, dynamic value) async {
    try {
      Box<dynamic>? box = _getBoxByName(boxName);
      if (box != null) {
        await box.put(key, value);
      } else {
        throw StorageException(message: 'Box $boxName not found');
      }
    } catch (e) {
      throw StorageException(message: 'Failed to save to box $boxName: $e');
    }
  }

  /// Gets data from a specific box
  Future<T?> getFromBox<T>(String boxName, String key, {T? defaultValue}) async {
    try {
      Box<dynamic>? box = _getBoxByName(boxName);
      if (box != null) {
        return box.get(key, defaultValue: defaultValue) as T?;
      } else {
        throw StorageException(message: 'Box $boxName not found');
      }
    } catch (e) {
      throw StorageException(message: 'Failed to get from box $boxName: $e');
    }
  }

  /// Clears all data from a specific box
  Future<void> clearBox(String boxName) async {
    try {
      Box<dynamic>? box = _getBoxByName(boxName);
      if (box != null) {
        await box.clear();
      } else {
        throw StorageException(message: 'Box $boxName not found');
      }
    } catch (e) {
      throw StorageException(message: 'Failed to clear box $boxName: $e');
    }
  }

  /// Helper method to get box by name
  Box<dynamic>? _getBoxByName(String boxName) {
    switch (boxName) {
      case 'videos':
      case _videoBox:
        return _videoBoxInstance;
      case 'downloads':
      case _downloadBox:
        return _downloadBoxInstance;
      case 'settings':
      case _settingsBox:
        return _settingsBoxInstance;
      case 'cache':
      case _cacheBox:
        return _cacheBoxInstance;
      case 'user_prefs':
      case _userPrefsBox:
        return _userPrefsBoxInstance;
      case 'search_history':
      case _searchHistoryBox:
        return _searchHistoryBoxInstance;
      case 'download_history':
      case _downloadHistoryBox:
        return _downloadHistoryBoxInstance;
      default:
        return null;
    }
  }
}

/// Hive adapter for VideoModel
class VideoModelAdapter extends TypeAdapter<VideoModel> {
  @override
  final int typeId = 0;

  @override
  VideoModel read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return VideoModel.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, VideoModel obj) {
    writer.writeMap(obj.toJson());
  }
}

/// Hive adapter for VideoFormatModel
class VideoFormatModelAdapter extends TypeAdapter<VideoFormatModel> {
  @override
  final int typeId = 1;

  @override
  VideoFormatModel read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return VideoFormatModel.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, VideoFormatModel obj) {
    writer.writeMap(obj.toJson());
  }
}

/// Hive adapter for DownloadModel
class DownloadModelAdapter extends TypeAdapter<DownloadModel> {
  @override
  final int typeId = 2;

  @override
  DownloadModel read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return DownloadModel.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, DownloadModel obj) {
    writer.writeMap(obj.toJson());
  }
}

/// Hive adapter for DownloadStatsModel
class DownloadStatsModelAdapter extends TypeAdapter<DownloadStatsModel> {
  @override
  final int typeId = 3;

  @override
  DownloadStatsModel read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return DownloadStatsModel.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, DownloadStatsModel obj) {
    writer.writeMap(obj.toJson());
  }
}