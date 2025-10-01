import '../entities/video.dart';
import '../entities/download.dart';
import '../repositories/video_repository.dart';
import '../../core/error/failures.dart';

/// Use case for downloading videos
/// 
/// This use case handles the business logic for starting video downloads,
/// including validation, format selection, and path management.
class DownloadVideo {
  final DownloadRepository repository;

  DownloadVideo(this.repository);

  /// Executes the use case to start a video download
  /// 
  /// [params] - Parameters containing download configuration
  /// Returns a [Result] containing either a [Download] or [Failure]
  Future<Result<Download>> call(DownloadVideoParams params) async {
    // Validate video entity
    if (!params.video.isDownloadable) {
      return Error(ValidationFailure(
        message: 'Video is not downloadable',
        details: {
          'video_id': params.video.id,
          'is_live': params.video.isLiveStream,
          'is_private': params.video.isPrivate,
          'has_formats': params.video.availableFormats.isNotEmpty,
        },
      ));
    }

    // Validate selected format
    if (!params.video.availableFormats.contains(params.selectedFormat)) {
      return Error(ValidationFailure(
        message: 'Selected format is not available for this video',
        details: {
          'video_id': params.video.id,
          'selected_format': params.selectedFormat.formatId,
          'available_formats': params.video.availableFormats.map((f) => f.formatId).toList(),
        },
      ));
    }

    // Validate download path
    if (params.downloadPath.isEmpty) {
      return Error(ValidationFailure(
        message: 'Download path cannot be empty',
      ));
    }

    // Check storage space if file size is known
    if (params.selectedFormat.fileSize != null) {
      // This would typically check available storage space
      // For now, we'll assume it's valid
    }

    // Start the download
    try {
      final result = await repository.startDownload(
        video: params.video,
        format: params.selectedFormat,
        downloadPath: params.downloadPath,
        quality: params.quality,
      );
      return result;
    } catch (e) {
      return Error(DownloadFailure(
        message: 'Failed to start download',
        details: {
          'error': e.toString(),
          'video_id': params.video.id,
          'format_id': params.selectedFormat.formatId,
        },
      ));
    }
  }
}

/// Use case for pausing downloads
class PauseDownload {
  final DownloadRepository repository;

  PauseDownload(this.repository);

  /// Executes the use case to pause a download
  Future<Result<Download>> call(String downloadId) async {
    if (downloadId.isEmpty) {
      return Error(ValidationFailure(message: 'Download ID cannot be empty'));
    }

    try {
      return await repository.pauseDownload(downloadId);
    } catch (e) {
      return Error(DownloadFailure(
        message: 'Failed to pause download',
        details: {'error': e.toString(), 'download_id': downloadId},
      ));
    }
  }
}

/// Use case for resuming downloads
class ResumeDownload {
  final DownloadRepository repository;

  ResumeDownload(this.repository);

  /// Executes the use case to resume a download
  Future<Result<Download>> call(String downloadId) async {
    if (downloadId.isEmpty) {
      return Error(ValidationFailure(message: 'Download ID cannot be empty'));
    }

    try {
      return await repository.resumeDownload(downloadId);
    } catch (e) {
      return Error(DownloadFailure(
        message: 'Failed to resume download',
        details: {'error': e.toString(), 'download_id': downloadId},
      ));
    }
  }
}

/// Use case for cancelling downloads
class CancelDownload {
  final DownloadRepository repository;

  CancelDownload(this.repository);

  /// Executes the use case to cancel a download
  Future<Result<bool>> call(String downloadId) async {
    if (downloadId.isEmpty) {
      return Error(ValidationFailure(message: 'Download ID cannot be empty'));
    }

    try {
      return await repository.cancelDownload(downloadId);
    } catch (e) {
      return Error(DownloadFailure(
        message: 'Failed to cancel download',
        details: {'error': e.toString(), 'download_id': downloadId},
      ));
    }
  }
}

/// Use case for retrying failed downloads
class RetryDownload {
  final DownloadRepository repository;

  RetryDownload(this.repository);

  /// Executes the use case to retry a failed download
  Future<Result<Download>> call(String downloadId) async {
    if (downloadId.isEmpty) {
      return Error(ValidationFailure(message: 'Download ID cannot be empty'));
    }

    try {
      return await repository.retryDownload(downloadId);
    } catch (e) {
      return Error(DownloadFailure(
        message: 'Failed to retry download',
        details: {'error': e.toString(), 'download_id': downloadId},
      ));
    }
  }
}

/// Use case for getting all downloads
class GetAllDownloads {
  final DownloadRepository repository;

  GetAllDownloads(this.repository);

  /// Executes the use case to get all downloads
  Future<Result<List<Download>>> call() async {
    try {
      return await repository.getAllDownloads();
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to retrieve downloads',
        details: {'error': e.toString()},
      ));
    }
  }
}

/// Use case for getting active downloads
class GetActiveDownloads {
  final DownloadRepository repository;

  GetActiveDownloads(this.repository);

  /// Executes the use case to get active downloads
  Future<Result<List<Download>>> call() async {
    try {
      return await repository.getActiveDownloads();
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to retrieve active downloads',
        details: {'error': e.toString()},
      ));
    }
  }
}

/// Use case for getting completed downloads
class GetCompletedDownloads {
  final DownloadRepository repository;

  GetCompletedDownloads(this.repository);

  /// Executes the use case to get completed downloads
  Future<Result<List<Download>>> call() async {
    try {
      return await repository.getCompletedDownloads();
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to retrieve completed downloads',
        details: {'error': e.toString()},
      ));
    }
  }
}

/// Use case for deleting downloads
class DeleteDownload {
  final DownloadRepository repository;

  DeleteDownload(this.repository);

  /// Executes the use case to delete a download
  Future<Result<bool>> call(DeleteDownloadParams params) async {
    if (params.downloadId.isEmpty) {
      return Error(ValidationFailure(message: 'Download ID cannot be empty'));
    }

    try {
      return await repository.deleteDownload(
        downloadId: params.downloadId,
        deleteFile: params.deleteFile,
      );
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to delete download',
        details: {
          'error': e.toString(),
          'download_id': params.downloadId,
          'delete_file': params.deleteFile,
        },
      ));
    }
  }
}

/// Parameters for the DownloadVideo use case
class DownloadVideoParams {
  final Video video;
  final VideoFormat selectedFormat;
  final String downloadPath;
  final DownloadQuality quality;
  final Map<String, dynamic>? metadata;

  const DownloadVideoParams({
    required this.video,
    required this.selectedFormat,
    required this.downloadPath,
    this.quality = DownloadQuality.medium,
    this.metadata,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DownloadVideoParams &&
        other.video == video &&
        other.selectedFormat == selectedFormat &&
        other.downloadPath == downloadPath &&
        other.quality == quality;
  }

  @override
  int get hashCode {
    return video.hashCode ^
        selectedFormat.hashCode ^
        downloadPath.hashCode ^
        quality.hashCode;
  }

  @override
  String toString() {
    return 'DownloadVideoParams(video: ${video.id}, format: ${selectedFormat.formatId}, path: $downloadPath, quality: $quality)';
  }
}

/// Parameters for the DeleteDownload use case
class DeleteDownloadParams {
  final String downloadId;
  final bool deleteFile;

  const DeleteDownloadParams({
    required this.downloadId,
    this.deleteFile = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteDownloadParams &&
        other.downloadId == downloadId &&
        other.deleteFile == deleteFile;
  }

  @override
  int get hashCode => downloadId.hashCode ^ deleteFile.hashCode;

  @override
  String toString() {
    return 'DeleteDownloadParams(downloadId: $downloadId, deleteFile: $deleteFile)';
  }
}