import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';

import '../models/download_model.dart';
import '../models/video_model.dart';
import '../../domain/entities/download.dart';
import '../../domain/entities/video.dart';
import '../../core/error/exceptions.dart';
import '../../core/constants/app_constants.dart';

/// Abstract interface for local download data operations
abstract class DownloadLocalDataSource {
  /// Saves download information to local storage
  Future<void> saveDownload(DownloadModel download);

  /// Updates download progress and status
  Future<void> updateDownload(DownloadModel download);

  /// Gets download by ID
  Future<DownloadModel?> getDownload(String downloadId);

  /// Gets all downloads
  Future<List<DownloadModel>> getAllDownloads();

  /// Gets active downloads (downloading, paused, queued)
  Future<List<DownloadModel>> getActiveDownloads();

  /// Gets completed downloads
  Future<List<DownloadModel>> getCompletedDownloads();

  /// Gets failed downloads
  Future<List<DownloadModel>> getFailedDownloads();

  /// Deletes download record
  Future<void> deleteDownload(String downloadId);

  /// Deletes download file from storage
  Future<bool> deleteDownloadFile(String filePath);

  /// Gets download statistics
  Future<DownloadStatsModel> getDownloadStats();

  /// Clears completed downloads
  Future<void> clearCompletedDownloads();

  /// Gets downloads by status
  Future<List<DownloadModel>> getDownloadsByStatus(DownloadStatus status);

  /// Gets downloads by video platform
  Future<List<DownloadModel>> getDownloadsByPlatform(String platform);

  /// Searches downloads by title or description
  Future<List<DownloadModel>> searchDownloads(String query);

  /// Gets total storage used by downloads
  Future<int> getTotalStorageUsed();

  /// Gets available storage space
  Future<int> getAvailableStorage();

  /// Encrypts download file
  Future<bool> encryptDownloadFile(String filePath, String encryptionKey);

  /// Decrypts download file
  Future<bool> decryptDownloadFile(String filePath, String encryptionKey);

  /// Checks if file exists and is valid
  Future<bool> isFileValid(String filePath);

  /// Gets file size
  Future<int> getFileSize(String filePath);

  /// Creates download directory if it doesn't exist
  Future<void> ensureDownloadDirectory(String directoryPath);

  /// Moves download file to new location
  Future<bool> moveDownloadFile(String oldPath, String newPath);

  /// Gets download queue order
  Future<List<String>> getDownloadQueue();

  /// Updates download queue order
  Future<void> updateDownloadQueue(List<String> downloadIds);

  /// Backs up download database
  Future<bool> backupDownloadDatabase(String backupPath);

  /// Restores download database from backup
  Future<bool> restoreDownloadDatabase(String backupPath);
}

/// Implementation of DownloadLocalDataSource using SQLite
class DownloadLocalDataSourceImpl implements DownloadLocalDataSource {
  final Database database;

  DownloadLocalDataSourceImpl({required this.database});

  @override
  Future<void> saveDownload(DownloadModel download) async {
    try {
      await database.insert(
        'downloads',
        {
          'id': download.id,
          'video_data': jsonEncode((download.video as VideoModel).toJson()),
          'selected_format_data': jsonEncode((download.selectedFormat as VideoFormatModel).toJson()),
          'local_path': download.localPath,
          'status': download.status.name,
          'progress': download.progress,
          'downloaded_bytes': download.downloadedBytes,
          'total_bytes': download.totalBytes,
          'created_at': download.createdAt.millisecondsSinceEpoch,
          'started_at': download.startedAt?.millisecondsSinceEpoch,
          'paused_at': download.pausedAt?.millisecondsSinceEpoch,
          'completed_at': download.completedAt?.millisecondsSinceEpoch,
          'error_message': download.errorMessage,
          'quality': download.quality.name,
          'is_audio_only': download.isAudioOnly ? 1 : 0,
          'metadata': jsonEncode(download.metadata),
          'video_id': download.video.id,
          'video_title': download.video.title,
          'video_platform': download.video.platform,
          'file_size': download.selectedFormat.fileSize,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw StorageException(message: 'Failed to save download: $e');
    }
  }

  @override
  Future<void> updateDownload(DownloadModel download) async {
    try {
      await database.update(
        'downloads',
        {
          'status': download.status.name,
          'progress': download.progress,
          'downloaded_bytes': download.downloadedBytes,
          'total_bytes': download.totalBytes,
          'started_at': download.startedAt?.millisecondsSinceEpoch,
          'paused_at': download.pausedAt?.millisecondsSinceEpoch,
          'completed_at': download.completedAt?.millisecondsSinceEpoch,
          'error_message': download.errorMessage,
          'is_audio_only': download.isAudioOnly ? 1 : 0,
          'metadata': jsonEncode(download.metadata),
        },
        where: 'id = ?',
        whereArgs: [download.id],
      );
    } catch (e) {
      throw StorageException(message: 'Failed to update download: $e');
    }
  }

  @override
  Future<DownloadModel?> getDownload(String downloadId) async {
    try {
      final results = await database.query(
        'downloads',
        where: 'id = ?',
        whereArgs: [downloadId],
        limit: 1,
      );

      if (results.isEmpty) return null;

      return _mapToDownloadModel(results.first);
    } catch (e) {
      throw StorageException(message: 'Failed to get download: $e');
    }
  }

  @override
  Future<List<DownloadModel>> getAllDownloads() async {
    try {
      final results = await database.query(
        'downloads',
        orderBy: 'created_at DESC',
      );

      return results.map(_mapToDownloadModel).toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get all downloads: $e');
    }
  }

  @override
  Future<List<DownloadModel>> getActiveDownloads() async {
    try {
      final results = await database.query(
        'downloads',
        where: 'status IN (?, ?, ?)',
        whereArgs: [
          DownloadStatus.downloading.name,
          DownloadStatus.paused.name,
          DownloadStatus.queued.name,
        ],
        orderBy: 'created_at ASC',
      );

      return results.map(_mapToDownloadModel).toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get active downloads: $e');
    }
  }

  @override
  Future<List<DownloadModel>> getCompletedDownloads() async {
    try {
      final results = await database.query(
        'downloads',
        where: 'status = ?',
        whereArgs: [DownloadStatus.completed.name],
        orderBy: 'completed_at DESC',
      );

      return results.map(_mapToDownloadModel).toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get completed downloads: $e');
    }
  }

  @override
  Future<List<DownloadModel>> getFailedDownloads() async {
    try {
      final results = await database.query(
        'downloads',
        where: 'status = ?',
        whereArgs: [DownloadStatus.failed.name],
        orderBy: 'updated_at DESC',
      );

      return results.map(_mapToDownloadModel).toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get failed downloads: $e');
    }
  }

  @override
  Future<void> deleteDownload(String downloadId) async {
    try {
      await database.delete(
        'downloads',
        where: 'id = ?',
        whereArgs: [downloadId],
      );
    } catch (e) {
      throw StorageException(message: 'Failed to delete download: $e');
    }
  }

  @override
  Future<bool> deleteDownloadFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<DownloadStatsModel> getDownloadStats() async {
    try {
      final results = await database.rawQuery('''
        SELECT 
          COUNT(*) as total_downloads,
          SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as completed_downloads,
          SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as failed_downloads,
          SUM(CASE WHEN status IN (?, ?, ?) THEN 1 ELSE 0 END) as active_downloads,
          SUM(COALESCE(total_bytes, 0)) as total_size,
          SUM(COALESCE(downloaded_bytes, 0)) as downloaded_size
        FROM downloads
      ''', [
        DownloadStatus.completed.name,
        DownloadStatus.failed.name,
        DownloadStatus.downloading.name,
        DownloadStatus.paused.name,
        DownloadStatus.queued.name,
      ]);

      final row = results.first;

      // Calculate average speed (simplified)
      final completedResults = await database.query(
        'downloads',
        columns: ['total_bytes', 'created_at', 'completed_at'],
        where: 'status = ? AND completed_at IS NOT NULL AND total_bytes IS NOT NULL',
        whereArgs: [DownloadStatus.completed.name],
      );

      double averageSpeed = 0.0;
      Duration totalTime = Duration.zero;

      if (completedResults.isNotEmpty) {
        double totalSpeed = 0.0;
        int validDownloads = 0;
        int totalTimeMs = 0;

        for (final download in completedResults) {
          final totalBytes = download['total_bytes'] as int?;
          final createdAt = download['created_at'] as int?;
          final completedAt = download['completed_at'] as int?;

          if (totalBytes != null && createdAt != null && completedAt != null) {
            final duration = completedAt - createdAt;
            if (duration > 0) {
              final speed = (totalBytes / duration) * 1000; // bytes per second
              totalSpeed += speed;
              validDownloads++;
              totalTimeMs += duration;
            }
          }
        }

        if (validDownloads > 0) {
          averageSpeed = totalSpeed / validDownloads;
          totalTime = Duration(milliseconds: totalTimeMs);
        }
      }

      return DownloadStatsModel(
        totalDownloads: row['total_downloads'] as int? ?? 0,
        completedDownloads: row['completed_downloads'] as int? ?? 0,
        failedDownloads: row['failed_downloads'] as int? ?? 0,
        activeDownloads: row['active_downloads'] as int? ?? 0,
        totalSize: row['total_size'] as int? ?? 0,
        downloadedSize: row['downloaded_size'] as int? ?? 0,
        averageSpeed: averageSpeed,
        totalTime: totalTime,
      );
    } catch (e) {
      throw StorageException(message: 'Failed to get download stats: $e');
    }
  }

  @override
  Future<void> clearCompletedDownloads() async {
    try {
      await database.delete(
        'downloads',
        where: 'status = ?',
        whereArgs: [DownloadStatus.completed.name],
      );
    } catch (e) {
      throw StorageException(message: 'Failed to clear completed downloads: $e');
    }
  }

  @override
  Future<List<DownloadModel>> getDownloadsByStatus(DownloadStatus status) async {
    try {
      final results = await database.query(
        'downloads',
        where: 'status = ?',
        whereArgs: [status.name],
        orderBy: 'created_at DESC',
      );

      return results.map(_mapToDownloadModel).toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get downloads by status: $e');
    }
  }

  @override
  Future<List<DownloadModel>> getDownloadsByPlatform(String platform) async {
    try {
      final results = await database.query(
        'downloads',
        where: 'video_platform = ?',
        whereArgs: [platform],
        orderBy: 'created_at DESC',
      );

      return results.map(_mapToDownloadModel).toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get downloads by platform: $e');
    }
  }

  @override
  Future<List<DownloadModel>> searchDownloads(String query) async {
    try {
      final results = await database.query(
        'downloads',
        where: 'video_title LIKE ? OR video_id LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );

      return results.map(_mapToDownloadModel).toList();
    } catch (e) {
      throw StorageException(message: 'Failed to search downloads: $e');
    }
  }

  @override
  Future<int> getTotalStorageUsed() async {
    try {
      final results = await database.rawQuery('''
        SELECT SUM(COALESCE(downloaded_bytes, 0)) as total_used
        FROM downloads
        WHERE status = ?
      ''', [DownloadStatus.completed.name]);

      return results.first['total_used'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getAvailableStorage() async {
    try {
      // This is a simplified implementation
      // In a real app, you'd check the actual device storage
      final directory = Directory(AppConstants.defaultDownloadPath);
      if (await directory.exists()) {
        final stat = await directory.stat();
        // Return a large number as placeholder
        return 1024 * 1024 * 1024 * 10; // 10GB
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<bool> encryptDownloadFile(String filePath, String encryptionKey) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      final key = sha256.convert(utf8.encode(encryptionKey)).bytes;
      
      // Simple XOR encryption (in production, use proper encryption)
      final encryptedBytes = <int>[];
      for (int i = 0; i < bytes.length; i++) {
        encryptedBytes.add(bytes[i] ^ key[i % key.length]);
      }

      await file.writeAsBytes(encryptedBytes);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> decryptDownloadFile(String filePath, String encryptionKey) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      final key = sha256.convert(utf8.encode(encryptionKey)).bytes;
      
      // Simple XOR decryption (same as encryption for XOR)
      final decryptedBytes = <int>[];
      for (int i = 0; i < bytes.length; i++) {
        decryptedBytes.add(bytes[i] ^ key[i % key.length]);
      }

      await file.writeAsBytes(decryptedBytes);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isFileValid(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists() && await file.length() > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> ensureDownloadDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    } catch (e) {
      throw StorageException(message: 'Failed to create download directory: $e');
    }
  }

  @override
  Future<bool> moveDownloadFile(String oldPath, String newPath) async {
    try {
      final oldFile = File(oldPath);
      if (!await oldFile.exists()) return false;

      final newFile = File(newPath);
      await newFile.parent.create(recursive: true);
      await oldFile.copy(newPath);
      await oldFile.delete();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getDownloadQueue() async {
    try {
      final results = await database.query(
        'downloads',
        columns: ['id'],
        where: 'status IN (?, ?)',
        whereArgs: [DownloadStatus.queued.name, DownloadStatus.downloading.name],
        orderBy: 'created_at ASC',
      );

      return results.map((row) => row['id'] as String).toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get download queue: $e');
    }
  }

  @override
  Future<void> updateDownloadQueue(List<String> downloadIds) async {
    try {
      // This is a simplified implementation
      // In a real app, you might have a separate queue table
      for (int i = 0; i < downloadIds.length; i++) {
        await database.update(
          'downloads',
          {'queue_position': i},
          where: 'id = ?',
          whereArgs: [downloadIds[i]],
        );
      }
    } catch (e) {
      throw StorageException(message: 'Failed to update download queue: $e');
    }
  }

  @override
  Future<bool> backupDownloadDatabase(String backupPath) async {
    try {
      final dbFile = File(database.path);
      if (await dbFile.exists()) {
        await dbFile.copy(backupPath);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> restoreDownloadDatabase(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.copy(database.path);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to map database row to DownloadModel
  DownloadModel _mapToDownloadModel(Map<String, dynamic> row) {
    try {
      final videoData = jsonDecode(row['video_data'] as String) as Map<String, dynamic>;
      final formatData = jsonDecode(row['selected_format_data'] as String) as Map<String, dynamic>;
      final metadata = jsonDecode(row['metadata'] as String? ?? '{}') as Map<String, dynamic>;

      return DownloadModel(
        id: row['id'] as String,
        video: VideoModel.fromJson(videoData),
        selectedFormat: VideoFormatModel.fromJson(formatData),
        localPath: row['local_path'] as String,
        status: DownloadStatus.values.firstWhere(
          (status) => status.name == row['status'],
          orElse: () => DownloadStatus.queued,
        ),
        progress: (row['progress'] as num).toDouble(),
        downloadedBytes: row['downloaded_bytes'] as int,
        totalBytes: row['total_bytes'] as int?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
        startedAt: row['started_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(row['started_at'] as int)
            : null,
        pausedAt: row['paused_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(row['paused_at'] as int)
            : null,
        completedAt: row['completed_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(row['completed_at'] as int)
            : null,
        errorMessage: row['error_message'] as String?,
        quality: DownloadQuality.values.firstWhere(
          (quality) => quality.name == row['quality'],
          orElse: () => DownloadQuality.medium,
        ),
        isAudioOnly: (row['is_audio_only'] as int?) == 1,
        metadata: metadata,
      );
    } catch (e) {
      throw StorageException(message: 'Failed to parse download data: $e');
    }
  }
}