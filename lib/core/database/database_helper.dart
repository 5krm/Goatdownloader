import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../error/exceptions.dart';

/// Database helper class for managing SQLite database
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  /// Gets the database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initializes the database
  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = path.join(documentsDirectory.path, AppConstants.databaseName);
      
      return await openDatabase(
        dbPath,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
        onOpen: _onOpen,
      );
    } catch (e) {
      throw StorageException(message: 'Failed to initialize database: $e');
    }
  }

  /// Creates database tables
  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // Downloads table
    batch.execute('''
      CREATE TABLE downloads (
        id TEXT PRIMARY KEY,
        video_data TEXT NOT NULL,
        selected_format_data TEXT NOT NULL,
        local_path TEXT NOT NULL,
        status TEXT NOT NULL,
        progress REAL NOT NULL DEFAULT 0.0,
        downloaded_bytes INTEGER NOT NULL DEFAULT 0,
        total_bytes INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        completed_at INTEGER,
        error_message TEXT,
        quality TEXT NOT NULL,
        metadata TEXT NOT NULL DEFAULT '{}',
        video_id TEXT NOT NULL,
        video_title TEXT NOT NULL,
        video_platform TEXT NOT NULL,
        file_size INTEGER,
        queue_position INTEGER DEFAULT 0
      )
    ''');

    // Video cache table
    batch.execute('''
      CREATE TABLE video_cache (
        id TEXT PRIMARY KEY,
        url TEXT NOT NULL UNIQUE,
        video_data TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL,
        access_count INTEGER NOT NULL DEFAULT 1,
        last_accessed INTEGER NOT NULL
      )
    ''');

    // Search cache table
    batch.execute('''
      CREATE TABLE search_cache (
        id TEXT PRIMARY KEY,
        cache_key TEXT NOT NULL UNIQUE,
        results_data TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL,
        query TEXT NOT NULL,
        platform TEXT,
        page INTEGER NOT NULL DEFAULT 1,
        limit_count INTEGER NOT NULL DEFAULT 20
      )
    ''');

    // Trending cache table
    batch.execute('''
      CREATE TABLE trending_cache (
        id TEXT PRIMARY KEY,
        cache_key TEXT NOT NULL UNIQUE,
        results_data TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL,
        platform TEXT,
        category TEXT,
        page INTEGER NOT NULL DEFAULT 1,
        limit_count INTEGER NOT NULL DEFAULT 20
      )
    ''');

    // Recently viewed videos table
    batch.execute('''
      CREATE TABLE recently_viewed (
        id TEXT PRIMARY KEY,
        video_id TEXT NOT NULL,
        video_data TEXT NOT NULL,
        viewed_at INTEGER NOT NULL,
        view_duration INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Favorites table
    batch.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        video_id TEXT NOT NULL UNIQUE,
        video_data TEXT NOT NULL,
        added_at INTEGER NOT NULL,
        category TEXT DEFAULT 'general'
      )
    ''');

    // Watch history table
    batch.execute('''
      CREATE TABLE watch_history (
        id TEXT PRIMARY KEY,
        video_id TEXT NOT NULL,
        video_data TEXT NOT NULL,
        watched_at INTEGER NOT NULL,
        watch_duration INTEGER NOT NULL DEFAULT 0,
        total_duration INTEGER NOT NULL DEFAULT 0,
        completed BOOLEAN NOT NULL DEFAULT 0
      )
    ''');

    // Settings table
    batch.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'string',
        updated_at INTEGER NOT NULL
      )
    ''');

    // Download statistics table
    batch.execute('''
      CREATE TABLE download_statistics (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        downloads_count INTEGER NOT NULL DEFAULT 0,
        total_size INTEGER NOT NULL DEFAULT 0,
        success_count INTEGER NOT NULL DEFAULT 0,
        failed_count INTEGER NOT NULL DEFAULT 0,
        average_speed REAL NOT NULL DEFAULT 0.0
      )
    ''');

    // Create indexes for better performance
    batch.execute('CREATE INDEX idx_downloads_status ON downloads(status)');
    batch.execute('CREATE INDEX idx_downloads_created_at ON downloads(created_at)');
    batch.execute('CREATE INDEX idx_downloads_video_id ON downloads(video_id)');
    batch.execute('CREATE INDEX idx_downloads_platform ON downloads(video_platform)');
    batch.execute('CREATE INDEX idx_downloads_queue_position ON downloads(queue_position)');
    
    batch.execute('CREATE INDEX idx_video_cache_url ON video_cache(url)');
    batch.execute('CREATE INDEX idx_video_cache_expires_at ON video_cache(expires_at)');
    batch.execute('CREATE INDEX idx_video_cache_last_accessed ON video_cache(last_accessed)');
    
    batch.execute('CREATE INDEX idx_search_cache_key ON search_cache(cache_key)');
    batch.execute('CREATE INDEX idx_search_cache_expires_at ON search_cache(expires_at)');
    batch.execute('CREATE INDEX idx_search_cache_query ON search_cache(query)');
    
    batch.execute('CREATE INDEX idx_trending_cache_key ON trending_cache(cache_key)');
    batch.execute('CREATE INDEX idx_trending_cache_expires_at ON trending_cache(expires_at)');
    
    batch.execute('CREATE INDEX idx_recently_viewed_video_id ON recently_viewed(video_id)');
    batch.execute('CREATE INDEX idx_recently_viewed_viewed_at ON recently_viewed(viewed_at)');
    
    batch.execute('CREATE INDEX idx_favorites_video_id ON favorites(video_id)');
    batch.execute('CREATE INDEX idx_favorites_added_at ON favorites(added_at)');
    batch.execute('CREATE INDEX idx_favorites_category ON favorites(category)');
    
    batch.execute('CREATE INDEX idx_watch_history_video_id ON watch_history(video_id)');
    batch.execute('CREATE INDEX idx_watch_history_watched_at ON watch_history(watched_at)');
    
    batch.execute('CREATE INDEX idx_settings_key ON settings(key)');
    
    batch.execute('CREATE INDEX idx_download_statistics_date ON download_statistics(date)');

    await batch.commit(noResult: true);
  }

  /// Handles database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final batch = db.batch();

    // Handle version upgrades
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
      batch.execute('ALTER TABLE downloads ADD COLUMN queue_position INTEGER DEFAULT 0');
      batch.execute('CREATE INDEX idx_downloads_queue_position ON downloads(queue_position)');
    }

    if (oldVersion < 3) {
      // Add download statistics table for version 3
      batch.execute('''
        CREATE TABLE IF NOT EXISTS download_statistics (
          id TEXT PRIMARY KEY,
          date TEXT NOT NULL,
          downloads_count INTEGER NOT NULL DEFAULT 0,
          total_size INTEGER NOT NULL DEFAULT 0,
          success_count INTEGER NOT NULL DEFAULT 0,
          failed_count INTEGER NOT NULL DEFAULT 0,
          average_speed REAL NOT NULL DEFAULT 0.0
        )
      ''');
      batch.execute('CREATE INDEX idx_download_statistics_date ON download_statistics(date)');
    }

    await batch.commit(noResult: true);
  }

  /// Handles database downgrades
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // Handle downgrades if necessary
    // Usually, we would recreate the database for major downgrades
    if (newVersion < oldVersion) {
      await _dropAllTables(db);
      await _onCreate(db, newVersion);
    }
  }

  /// Called when database is opened
  Future<void> _onOpen(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
    
    // Set journal mode to WAL for better performance
    await db.execute('PRAGMA journal_mode = WAL');
    
    // Set synchronous mode to NORMAL for better performance
    await db.execute('PRAGMA synchronous = NORMAL');
    
    // Set cache size (negative value means KB)
    await db.execute('PRAGMA cache_size = -2000'); // 2MB cache
  }

  /// Drops all tables (used for downgrades)
  Future<void> _dropAllTables(Database db) async {
    final batch = db.batch();
    
    batch.execute('DROP TABLE IF EXISTS downloads');
    batch.execute('DROP TABLE IF EXISTS video_cache');
    batch.execute('DROP TABLE IF EXISTS search_cache');
    batch.execute('DROP TABLE IF EXISTS trending_cache');
    batch.execute('DROP TABLE IF EXISTS recently_viewed');
    batch.execute('DROP TABLE IF EXISTS favorites');
    batch.execute('DROP TABLE IF EXISTS watch_history');
    batch.execute('DROP TABLE IF EXISTS settings');
    batch.execute('DROP TABLE IF EXISTS download_statistics');
    
    await batch.commit(noResult: true);
  }

  /// Clears all cache tables
  Future<void> clearAllCache() async {
    try {
      final db = await database;
      final batch = db.batch();
      
      batch.delete('video_cache');
      batch.delete('search_cache');
      batch.delete('trending_cache');
      
      await batch.commit(noResult: true);
    } catch (e) {
      throw StorageException(message: 'Failed to clear cache: $e');
    }
  }

  /// Clears expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;
      final batch = db.batch();
      
      batch.delete('video_cache', where: 'expires_at < ?', whereArgs: [now]);
      batch.delete('search_cache', where: 'expires_at < ?', whereArgs: [now]);
      batch.delete('trending_cache', where: 'expires_at < ?', whereArgs: [now]);
      
      await batch.commit(noResult: true);
    } catch (e) {
      throw StorageException(message: 'Failed to clear expired cache: $e');
    }
  }

  /// Gets database size in bytes
  Future<int> getDatabaseSize() async {
    try {
      final db = await database;
      final file = File(db.path);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Optimizes database (VACUUM)
  Future<void> optimizeDatabase() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
    } catch (e) {
      throw StorageException(message: 'Failed to optimize database: $e');
    }
  }

  /// Backs up database to specified path
  Future<bool> backupDatabase(String backupPath) async {
    try {
      final db = await database;
      final sourceFile = File(db.path);
      
      if (await sourceFile.exists()) {
        await sourceFile.copy(backupPath);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Restores database from backup
  Future<bool> restoreDatabase(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        return false;
      }

      // Close current database
      await _database?.close();
      _database = null;

      // Get database path
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = path.join(documentsDirectory.path, AppConstants.databaseName);

      // Copy backup to database location
      await backupFile.copy(dbPath);

      // Reinitialize database
      _database = await _initDatabase();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Closes the database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Deletes the database file
  Future<void> deleteDatabase() async {
    try {
      await close();
      
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = path.join(documentsDirectory.path, AppConstants.databaseName);
      
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Also delete WAL and SHM files
      final walFile = File('$dbPath-wal');
      if (await walFile.exists()) {
        await walFile.delete();
      }
      
      final shmFile = File('$dbPath-shm');
      if (await shmFile.exists()) {
        await shmFile.delete();
      }
    } catch (e) {
      throw StorageException(message: 'Failed to delete database: $e');
    }
  }

  /// Gets database information
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await database;
      final size = await getDatabaseSize();
      
      // Get table counts
      final downloads = await db.rawQuery('SELECT COUNT(*) as count FROM downloads');
      final videoCache = await db.rawQuery('SELECT COUNT(*) as count FROM video_cache');
      final searchCache = await db.rawQuery('SELECT COUNT(*) as count FROM search_cache');
      final trendingCache = await db.rawQuery('SELECT COUNT(*) as count FROM trending_cache');
      final recentlyViewed = await db.rawQuery('SELECT COUNT(*) as count FROM recently_viewed');
      final favorites = await db.rawQuery('SELECT COUNT(*) as count FROM favorites');
      final watchHistory = await db.rawQuery('SELECT COUNT(*) as count FROM watch_history');
      
      return {
        'path': db.path,
        'version': await db.getVersion(),
        'size': size,
        'sizeFormatted': _formatBytes(size),
        'tables': {
          'downloads': downloads.first['count'],
          'video_cache': videoCache.first['count'],
          'search_cache': searchCache.first['count'],
          'trending_cache': trendingCache.first['count'],
          'recently_viewed': recentlyViewed.first['count'],
          'favorites': favorites.first['count'],
          'watch_history': watchHistory.first['count'],
        },
      };
    } catch (e) {
      throw StorageException(message: 'Failed to get database info: $e');
    }
  }

  /// Formats bytes to human readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}