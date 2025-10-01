import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import '../../domain/entities/download.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/download_local_data_source.dart';
import '../datasources/download_remote_data_source.dart';
import '../models/download_model.dart';
import '../models/video_model.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/constants/app_constants.dart';

/// Implementation of DownloadRepository
class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadLocalDataSource localDataSource;
  final DownloadRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  final Map<String, StreamController<Download>> _downloadStreams = {};
  final Map<String, CancelToken> _cancelTokens = {};
  int _maxConcurrentDownloads = AppConstants.maxConcurrentDownloads;

  DownloadRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<Download>> startDownload({
    required Video video,
    required VideoFormat format,
    required String savePath,
    DownloadQuality? quality,
  }) async {
    try {
      // Validate inputs
      if (video.id.isEmpty) {
        return Error(ValidationFailure(message: 'Video ID cannot be empty'));
      }

      if (format.url.isEmpty) {
        return Error(ValidationFailure(message: 'Format URL cannot be empty'));
      }
      
      if (savePath.isEmpty) {
        return Error(ValidationFailure(message: 'Save path cannot be empty'));
      }

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure(message: 'No internet connection available'));
      }

      // Check if already downloading
      final existingDownload = await localDataSource.getDownload(video.id);
      if (existingDownload != null && 
          (existingDownload.status == DownloadStatus.downloading ||
           existingDownload.status == DownloadStatus.queued)) {
        return Error(DownloadFailure(message: 'Video is already being downloaded'));
      }

      // Check concurrent downloads limit
      final activeDownloads = await localDataSource.getActiveDownloads();
      final currentlyDownloading = activeDownloads
          .where((d) => d.status == DownloadStatus.downloading)
          .length;

      // Determine initial status
      final initialStatus = currentlyDownloading >= _maxConcurrentDownloads
          ? DownloadStatus.queued
          : DownloadStatus.downloading;

      // Ensure download directory exists
      await localDataSource.ensureDownloadDirectory(path.dirname(savePath));

      // Create download entity
      final download = DownloadModel(
        id: video.id,
        video: video is VideoModel ? video : VideoModel.fromEntity(video),
        selectedFormat: format is VideoFormatModel 
            ? format 
            : VideoFormatModel.fromEntity(format),
        localPath: savePath,
        status: initialStatus,
        progress: 0.0,
        downloadedBytes: 0,
        totalBytes: format.fileSize ?? 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        completedAt: null,
        errorMessage: null,
        quality: quality ?? _determineQualityFromFormat(format),
        metadata: {},
      );

      // Save download to local storage
      await localDataSource.saveDownload(download);

      // Start download if not queued
      if (initialStatus == DownloadStatus.downloading) {
        await _startActualDownload(download);
      }

      return Success(download);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(message: e.message));
    } on StorageException catch (e) {
      return Error(StorageFailure(message: e.message));
    } on PermissionException catch (e) {
      return Error(PermissionFailure(message: e.message));
    } on DownloadException catch (e) {
      return Error(DownloadFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to start download: $e'));
    }
  }

  @override
  Future<Result<bool>> pauseDownload(String downloadId) async {
    try {
      final download = await localDataSource.getDownload(downloadId);
      if (download == null) {
        return Error(DownloadFailure(message: 'Download not found'));
      }

      if (download.status != DownloadStatus.downloading) {
        return Error(DownloadFailure(message: 'Download is not currently active'));
      }

      // Pause the remote download
      await remoteDataSource.pauseDownload(downloadId);

      // Update local status
      final updatedDownload = download.copyWith(
        status: DownloadStatus.paused,
        updatedAt: DateTime.now(),
      );
      await localDataSource.updateDownload(updatedDownload);

      // Cancel the cancel token
      _cancelTokens[downloadId]?.cancel('Download paused by user');
      _cancelTokens.remove(downloadId);

      // Notify listeners
      _notifyDownloadUpdate(updatedDownload);

      // Start next queued download if any
      await _processDownloadQueue();

      return Success(true);
    } on DownloadException catch (e) {
      return Error(DownloadFailure(message: e.message));
    } on StorageException catch (e) {
      return Error(StorageFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to pause download: $e'));
    }
  }

  @override
  Future<Result<bool>> resumeDownload(String downloadId) async {
    try {
      final download = await localDataSource.getDownload(downloadId);
      if (download == null) {
        return Error(DownloadFailure(message: 'Download not found'));
      }

      if (download.status != DownloadStatus.paused) {
        return Error(DownloadFailure(message: 'Download is not paused'));
      }

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure(message: 'No internet connection available'));
      }

      // Check concurrent downloads limit
      final activeDownloads = await localDataSource.getActiveDownloads();
      final currentlyDownloading = activeDownloads
          .where((d) => d.status == DownloadStatus.downloading)
          .length;

      if (currentlyDownloading >= _maxConcurrentDownloads) {
        // Add to queue
        final updatedDownload = download.copyWith(
          status: DownloadStatus.queued,
          updatedAt: DateTime.now(),
        );
        await localDataSource.updateDownload(updatedDownload);
        _notifyDownloadUpdate(updatedDownload);
        return Success(true);
      }

      // Check if file exists for resume
      final file = File(download.localPath);
      final resumeFrom = await file.exists() ? await file.length() : 0;

      // Update status to downloading
      final updatedDownload = download.copyWith(
        status: DownloadStatus.downloading,
        updatedAt: DateTime.now(),
      );
      await localDataSource.updateDownload(updatedDownload);

      // Resume the download
      await _resumeActualDownload(updatedDownload, resumeFrom);

      return Success(true);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(message: e.message));
    } on DownloadException catch (e) {
      return Error(DownloadFailure(message: e.message));
    } on StorageException catch (e) {
      return Error(StorageFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to resume download: $e'));
    }
  }

  @override
  Future<Result<bool>> cancelDownload(String downloadId) async {
    try {
      final download = await localDataSource.getDownload(downloadId);
      if (download == null) {
        return Error(DownloadFailure(message: 'Download not found'));
      }

      // Cancel the remote download
      await remoteDataSource.cancelDownload(downloadId);

      // Update local status
      final updatedDownload = download.copyWith(
        status: DownloadStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      await localDataSource.updateDownload(updatedDownload);

      // Cancel the cancel token
      _cancelTokens[downloadId]?.cancel('Download cancelled by user');
      _cancelTokens.remove(downloadId);

      // Close stream
      _downloadStreams[downloadId]?.close();
      _downloadStreams.remove(downloadId);

      // Delete partial file
      await localDataSource.deleteDownloadFile(download.localPath);

      // Notify listeners
      _notifyDownloadUpdate(updatedDownload);

      // Start next queued download if any
      await _processDownloadQueue();

      return Success(true);
    } on DownloadException catch (e) {
      return Error(DownloadFailure(message: e.message));
    } on StorageException catch (e) {
      return Error(StorageFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to cancel download: $e'));
    }
  }

  @override
  Future<Result<bool>> retryDownload(String downloadId) async {
    try {
      final download = await localDataSource.getDownload(downloadId);
      if (download == null) {
        return Error(DownloadFailure(message: 'Download not found'));
      }

      if (download.status != DownloadStatus.failed) {
        return Error(DownloadFailure(message: 'Download has not failed'));
      }

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Error(NetworkFailure(message: 'No internet connection available'));
      }

      // Reset download status
      final updatedDownload = download.copyWith(
        status: DownloadStatus.downloading,
        progress: 0.0,
        downloadedBytes: 0,
        updatedAt: DateTime.now(),
        errorMessage: null,
      );
      await localDataSource.updateDownload(updatedDownload);

      // Retry the download
      await _retryActualDownload(updatedDownload);

      return Success(true);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(message: e.message));
    } on DownloadException catch (e) {
      return Error(DownloadFailure(message: e.message));
    } on StorageException catch (e) {
      return Error(StorageFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to retry download: $e'));
    }
  }

  @override
  Future<Result<List<Download>>> getAllDownloads() async {
    try {
      final downloads = await localDataSource.getAllDownloads();
      return Success(downloads.cast<Download>());
    } on StorageException catch (e) {
      return Error(StorageFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to get all downloads: $e'));
    }
  }

  @override
  Future<Result<List<Download>>> getActiveDownloads() async {
    try {
      final downloads = await localDataSource.getActiveDownloads();
      return Success(downloads.cast<Download>());
    } on StorageException catch (e) {
      return Error(StorageFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to get active downloads: $e'));
    }
  }

  @override
  Future<Result<List<Download>>> getCompletedDownloads() async {
    try {
      final downloads = await localDataSource.getCompletedDownloads();
      return Success(downloads.cast<Download>());
    } on StorageException catch (e) {
      return Error(StorageFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to get completed downloads: $e'));
    }
  }

  @override
  Future<Result<Download?>> getDownloadById(String downloadId) async {
    try {
      final download = await localDataSource.getDownload(downloadId);
      return Success(download);
    } on StorageException catch (e) {
      return Error(StorageFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to get download: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteDownload(String downloadId) async {
    try {
      final download = await localDataSource.getDownload(downloadId);
      if (download == null) {
        return Error(DownloadFailure(message: 'Download not found'));
      }

      // Cancel if active
      if (download.status == DownloadStatus.downloading ||
          download.status == DownloadStatus.queued) {
        await cancelDownload(downloadId);
      }

      // Delete file
      await localDataSource.deleteDownloadFile(download.localPath);

      // Delete from database
      await localDataSource.deleteDownload(downloadId);

      return Success(true);
    } on DownloadException catch (e) {
      return Error(DownloadFailure(message: e.message));
    } on StorageException catch (e) {
      return Error(StorageFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to delete download: $e'));
    }
  }

  @override
  Stream<Download> watchDownloadProgress(String downloadId) {
    if (!_downloadStreams.containsKey(downloadId)) {
      _downloadStreams[downloadId] = StreamController<Download>.broadcast();
    }
    return _downloadStreams[downloadId]!.stream;
  }

  @override
  Future<Result<bool>> updateDownloadMetadata(String downloadId, Map<String, dynamic> metadata) async {
    try {
      final download = await localDataSource.getDownload(downloadId);
      if (download == null) {
        return Error(DownloadFailure(message: 'Download not found'));
      }

      final updatedDownload = download.copyWith(
        metadata: {...download.metadata, ...metadata},
        updatedAt: DateTime.now(),
      );
      await localDataSource.updateDownload(updatedDownload);

      _notifyDownloadUpdate(updatedDownload);
      return Success(true);
    } on StorageException catch (e) {
      return Error(StorageFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to update download metadata: $e'));
    }
  }

  @override
  Future<Result<DownloadStats>> getDownloadStatistics() async {
    try {
      final stats = await localDataSource.getDownloadStats();
      return Success(stats);
    } on StorageException catch (e) {
      return Error(StorageFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to get download statistics: $e'));
    }
  }

  @override
  Future<Result<bool>> clearCompletedDownloads() async {
    try {
      await localDataSource.clearCompletedDownloads();
      return Success(true);
    } on StorageException catch (e) {
      return Error(StorageFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to clear completed downloads: $e'));
    }
  }

  @override
  Future<Result<bool>> setMaxConcurrentDownloads(int maxDownloads) async {
    try {
      if (maxDownloads < 1 || maxDownloads > 10) {
        return Error(ValidationFailure(message: 'Max concurrent downloads must be between 1 and 10'));
      }

      _maxConcurrentDownloads = maxDownloads;
      
      // Process queue to start/stop downloads as needed
      await _processDownloadQueue();
      
      return Success(true);
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to set max concurrent downloads: $e'));
    }
  }

  @override
  Future<Result<List<String>>> getDownloadQueue() async {
    try {
      final queue = await localDataSource.getDownloadQueue();
      return Success(queue);
    } on StorageException catch (e) {
      return Error(StorageFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to get download queue: $e'));
    }
  }

  @override
  Future<Result<bool>> reorderDownloadQueue(List<String> downloadIds) async {
    try {
      await localDataSource.updateDownloadQueue(downloadIds);
      await _processDownloadQueue();
      return Success(true);
    } on StorageException catch (e) {
      return Error(StorageFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to reorder download queue: $e'));
    }
  }

  /// Starts the actual download process
  Future<void> _startActualDownload(DownloadModel download) async {
    final cancelToken = CancelToken();
    _cancelTokens[download.id] = cancelToken;

    await remoteDataSource.startDownload(
      downloadId: download.id,
      video: download.video as VideoModel,
      format: download.selectedFormat as VideoFormatModel,
      savePath: download.localPath,
      onProgress: (progress, downloadedBytes, totalBytes) async {
        final updatedDownload = download.copyWith(
          progress: progress,
          downloadedBytes: downloadedBytes,
          totalBytes: totalBytes,
          updatedAt: DateTime.now(),
        );
        await localDataSource.updateDownload(updatedDownload);
        _notifyDownloadUpdate(updatedDownload);
      },
      onError: (error) async {
        final updatedDownload = download.copyWith(
          status: DownloadStatus.failed,
          errorMessage: error,
          updatedAt: DateTime.now(),
        );
        await localDataSource.updateDownload(updatedDownload);
        _notifyDownloadUpdate(updatedDownload);
        _cleanupDownload(download.id);
        await _processDownloadQueue();
      },
      onComplete: () async {
        final updatedDownload = download.copyWith(
          status: DownloadStatus.completed,
          progress: 1.0,
          completedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await localDataSource.updateDownload(updatedDownload);
        _notifyDownloadUpdate(updatedDownload);
        _cleanupDownload(download.id);
        await _processDownloadQueue();
      },
      cancelToken: cancelToken,
    );
  }

  /// Resumes an actual download
  Future<void> _resumeActualDownload(DownloadModel download, int resumeFrom) async {
    final cancelToken = CancelToken();
    _cancelTokens[download.id] = cancelToken;

    await remoteDataSource.resumeDownload(
      downloadId: download.id,
      format: download.selectedFormat as VideoFormatModel,
      savePath: download.localPath,
      resumeFrom: resumeFrom,
      onProgress: (progress, downloadedBytes, totalBytes) async {
        final updatedDownload = download.copyWith(
          progress: progress,
          downloadedBytes: downloadedBytes,
          totalBytes: totalBytes,
          updatedAt: DateTime.now(),
        );
        await localDataSource.updateDownload(updatedDownload);
        _notifyDownloadUpdate(updatedDownload);
      },
      onError: (error) async {
        final updatedDownload = download.copyWith(
          status: DownloadStatus.failed,
          errorMessage: error,
          updatedAt: DateTime.now(),
        );
        await localDataSource.updateDownload(updatedDownload);
        _notifyDownloadUpdate(updatedDownload);
        _cleanupDownload(download.id);
        await _processDownloadQueue();
      },
      onComplete: () async {
        final updatedDownload = download.copyWith(
          status: DownloadStatus.completed,
          progress: 1.0,
          completedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await localDataSource.updateDownload(updatedDownload);
        _notifyDownloadUpdate(updatedDownload);
        _cleanupDownload(download.id);
        await _processDownloadQueue();
      },
      cancelToken: cancelToken,
    );
  }

  /// Retries an actual download
  Future<void> _retryActualDownload(DownloadModel download) async {
    final cancelToken = CancelToken();
    _cancelTokens[download.id] = cancelToken;

    await remoteDataSource.retryDownload(
      downloadId: download.id,
      format: download.selectedFormat as VideoFormatModel,
      savePath: download.localPath,
      onProgress: (progress, downloadedBytes, totalBytes) async {
        final updatedDownload = download.copyWith(
          progress: progress,
          downloadedBytes: downloadedBytes,
          totalBytes: totalBytes,
          updatedAt: DateTime.now(),
        );
        await localDataSource.updateDownload(updatedDownload);
        _notifyDownloadUpdate(updatedDownload);
      },
      onError: (error) async {
        final updatedDownload = download.copyWith(
          status: DownloadStatus.failed,
          errorMessage: error,
          updatedAt: DateTime.now(),
        );
        await localDataSource.updateDownload(updatedDownload);
        _notifyDownloadUpdate(updatedDownload);
        _cleanupDownload(download.id);
        await _processDownloadQueue();
      },
      onComplete: () async {
        final updatedDownload = download.copyWith(
          status: DownloadStatus.completed,
          progress: 1.0,
          completedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await localDataSource.updateDownload(updatedDownload);
        _notifyDownloadUpdate(updatedDownload);
        _cleanupDownload(download.id);
        await _processDownloadQueue();
      },
      cancelToken: cancelToken,
    );
  }

  /// Processes the download queue to start next downloads
  Future<void> _processDownloadQueue() async {
    try {
      final activeDownloads = await localDataSource.getActiveDownloads();
      final currentlyDownloading = activeDownloads
          .where((d) => d.status == DownloadStatus.downloading)
          .length;

      if (currentlyDownloading < _maxConcurrentDownloads) {
        final queuedDownloads = activeDownloads
            .where((d) => d.status == DownloadStatus.queued)
            .toList();

        final slotsAvailable = _maxConcurrentDownloads - currentlyDownloading;
        final downloadsToStart = queuedDownloads.take(slotsAvailable);

        for (final download in downloadsToStart) {
          final updatedDownload = download.copyWith(
            status: DownloadStatus.downloading,
            updatedAt: DateTime.now(),
          );
          await localDataSource.updateDownload(updatedDownload);
          _notifyDownloadUpdate(updatedDownload);
          
          // Start the download
          unawaited(_startActualDownload(updatedDownload));
        }
      }
    } catch (e) {
      // Log error but don't throw
      print('Error processing download queue: $e');
    }
  }

  /// Notifies listeners about download updates
  void _notifyDownloadUpdate(DownloadModel download) {
    final stream = _downloadStreams[download.id];
    if (stream != null && !stream.isClosed) {
      stream.add(download);
    }
  }

  /// Cleans up download resources
  void _cleanupDownload(String downloadId) {
    _cancelTokens.remove(downloadId);
    _downloadStreams[downloadId]?.close();
    _downloadStreams.remove(downloadId);
  }

  /// Determines quality from format
  DownloadQuality _determineQualityFromFormat(VideoFormat format) {
    final quality = format.quality?.toLowerCase() ?? '';
    
    if (quality.contains('1080') || quality.contains('high')) {
      return DownloadQuality.high;
    } else if (quality.contains('720') || quality.contains('medium')) {
      return DownloadQuality.medium;
    } else if (quality.contains('480') || quality.contains('360') || quality.contains('low')) {
      return DownloadQuality.low;
    }
    
    return DownloadQuality.medium;
  }

  /// Disposes all resources
  void dispose() {
    for (final token in _cancelTokens.values) {
      if (!token.isCancelled) {
        token.cancel('Repository disposed');
      }
    }
    
    for (final stream in _downloadStreams.values) {
      stream.close();
    }
    
    _cancelTokens.clear();
    _downloadStreams.clear();
  }

  @override
  Stream<Download> getDownloadProgressStream(String downloadId) {
    if (!_downloadStreams.containsKey(downloadId)) {
      _downloadStreams[downloadId] = StreamController<Download>.broadcast();
    }
    return _downloadStreams[downloadId]!.stream;
  }

  @override
  Stream<List<Download>> getAllDownloadsStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) async {
      final result = await getAllDownloads();
      return result is Success<List<Download>> ? result.data : <Download>[];
    }).asyncMap((future) => future);
  }

  @override
  Future<Result<DownloadStats>> getDownloadStats() async {
    try {
      final stats = await localDataSource.getDownloadStats();
      return Success(stats);
    } on StorageException catch (e) {
      return Error(StorageFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(message: 'Failed to get download stats: $e'));
    }
  }
}

/// Extension to avoid awaiting futures in fire-and-forget scenarios
extension Unawaited on Future {
  void get unawaited => then((_) {}, onError: (_) {});
}