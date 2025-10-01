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

/// Abstract repository interface for download operations
abstract class DownloadRepository {
  /// Starts a new download
  Future<Result<Download>> startDownload({
    required Video video,
    required VideoFormat format,
    required String savePath,
    DownloadQuality? quality,
  });

  /// Pauses an active download
  Future<Result<bool>> pauseDownload(String downloadId);

  /// Resumes a paused download
  Future<Result<bool>> resumeDownload(String downloadId);

  /// Cancels a download
  Future<Result<bool>> cancelDownload(String downloadId);

  /// Retries a failed download
  Future<Result<bool>> retryDownload(String downloadId);

  /// Gets all downloads
  Future<Result<List<Download>>> getAllDownloads();

  /// Gets active downloads (downloading, paused, queued)
  Future<Result<List<Download>>> getActiveDownloads();

  /// Gets completed downloads
  Future<Result<List<Download>>> getCompletedDownloads();

  /// Gets download by ID
  Future<Result<Download?>> getDownloadById(String downloadId);

  /// Deletes a download
  Future<Result<bool>> deleteDownload(String downloadId);

  /// Clears completed downloads
  Future<Result<bool>> clearCompletedDownloads();

  /// Gets download statistics
  Future<Result<DownloadStats>> getDownloadStatistics();

  /// Sets maximum concurrent downloads
  Future<Result<bool>> setMaxConcurrentDownloads(int maxDownloads);

  /// Gets download queue
  Future<Result<List<String>>> getDownloadQueue();

  /// Reorders download queue
  Future<Result<bool>> reorderDownloadQueue(List<String> downloadIds);

  /// Watches download progress
  Stream<Download> watchDownloadProgress(String downloadId);

  /// Updates download metadata
  Future<Result<bool>> updateDownloadMetadata(String downloadId, Map<String, dynamic> metadata);
}