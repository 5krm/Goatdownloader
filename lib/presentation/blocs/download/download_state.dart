import 'package:equatable/equatable.dart';

import '../../../domain/entities/download.dart';
import '../../../core/error/failures.dart';
import '../../../data/models/download_model.dart';

/// Base class for all download states
abstract class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object?> get props => [];
}

/// Initial state when download BLoC is first created
class DownloadInitial extends DownloadState {
  const DownloadInitial();
}

/// State when download operation is loading
class DownloadLoading extends DownloadState {
  final String? message;

  const DownloadLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// State when download has started successfully
class DownloadStarted extends DownloadState {
  final DownloadModel download;

  const DownloadStarted({required this.download});

  @override
  List<Object?> get props => [download];
}

/// State when download has been paused
class DownloadPaused extends DownloadState {
  final String downloadId;

  const DownloadPaused({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// State when download has been resumed
class DownloadResumed extends DownloadState {
  final String downloadId;

  const DownloadResumed({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// State when download has been cancelled
class DownloadCancelled extends DownloadState {
  final String downloadId;
  final bool fileDeleted;

  const DownloadCancelled({
    required this.downloadId,
    required this.fileDeleted,
  });

  @override
  List<Object?> get props => [downloadId, fileDeleted];
}

/// State when download has completed successfully
class DownloadCompleted extends DownloadState {
  final DownloadModel download;

  const DownloadCompleted({required this.download});

  @override
  List<Object?> get props => [download];
}

/// State when download has failed
class DownloadFailed extends DownloadState {
  final String downloadId;
  final String error;

  const DownloadFailed({
    required this.downloadId,
    required this.error,
  });

  @override
  List<Object?> get props => [downloadId, error];
}

/// State when download is being retried
class DownloadRetrying extends DownloadState {
  final String downloadId;
  final int attemptNumber;

  const DownloadRetrying({
    required this.downloadId,
    required this.attemptNumber,
  });

  @override
  List<Object?> get props => [downloadId, attemptNumber];
}

/// State when download has been deleted
class DownloadDeleted extends DownloadState {
  final String downloadId;
  final bool fileDeleted;

  const DownloadDeleted({
    required this.downloadId,
    required this.fileDeleted,
  });

  @override
  List<Object?> get props => [downloadId, fileDeleted];
}

/// State when downloads list is loaded
class DownloadsLoaded extends DownloadState {
  final List<DownloadModel> downloads;
  final String? filterType;

  const DownloadsLoaded({
    required this.downloads,
    this.filterType,
  });

  @override
  List<Object?> get props => [downloads, filterType];

  DownloadsLoaded copyWith({
    List<DownloadModel>? downloads,
    String? filterType,
  }) {
    return DownloadsLoaded(
      downloads: downloads ?? this.downloads,
      filterType: filterType ?? this.filterType,
    );
  }
}

/// State when active downloads are loaded
class ActiveDownloadsLoaded extends DownloadState {
  final List<DownloadModel> downloads;

  const ActiveDownloadsLoaded({required this.downloads});

  @override
  List<Object?> get props => [downloads];
}

/// State when completed downloads are loaded
class CompletedDownloadsLoaded extends DownloadState {
  final List<DownloadModel> downloads;

  const CompletedDownloadsLoaded({required this.downloads});

  @override
  List<Object?> get props => [downloads];
}

/// State when failed downloads are loaded
class FailedDownloadsLoaded extends DownloadState {
  final List<DownloadModel> downloads;

  const FailedDownloadsLoaded({required this.downloads});

  @override
  List<Object?> get props => [downloads];
}

/// State when downloads by status are loaded
class DownloadsByStatusLoaded extends DownloadState {
  final List<DownloadModel> downloads;
  final DownloadStatus status;

  const DownloadsByStatusLoaded({
    required this.downloads,
    required this.status,
  });

  @override
  List<Object?> get props => [downloads, status];
}

/// State when downloads by platform are loaded
class DownloadsByPlatformLoaded extends DownloadState {
  final List<DownloadModel> downloads;
  final String platform;

  const DownloadsByPlatformLoaded({
    required this.downloads,
    required this.platform,
  });

  @override
  List<Object?> get props => [downloads, platform];
}

/// State when download search results are loaded
class DownloadSearchResultsLoaded extends DownloadState {
  final List<DownloadModel> downloads;
  final String query;

  const DownloadSearchResultsLoaded({
    required this.downloads,
    required this.query,
  });

  @override
  List<Object?> get props => [downloads, query];
}

/// State when single download is loaded
class DownloadByIdLoaded extends DownloadState {
  final DownloadModel download;

  const DownloadByIdLoaded({required this.download});

  @override
  List<Object?> get props => [download];
}

/// State when download metadata has been updated
class DownloadMetadataUpdated extends DownloadState {
  final String downloadId;

  const DownloadMetadataUpdated({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// State when download statistics are loaded
class DownloadStatisticsLoaded extends DownloadState {
  final DownloadStatsModel statistics;

  const DownloadStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

/// State when completed downloads have been cleared
class CompletedDownloadsCleared extends DownloadState {
  final int clearedCount;

  const CompletedDownloadsCleared({required this.clearedCount});

  @override
  List<Object?> get props => [clearedCount];
}

/// State when failed downloads have been cleared
class FailedDownloadsCleared extends DownloadState {
  final int clearedCount;

  const FailedDownloadsCleared({required this.clearedCount});

  @override
  List<Object?> get props => [clearedCount];
}

/// State when all downloads have been cleared
class AllDownloadsCleared extends DownloadState {
  final int clearedCount;
  final bool filesDeleted;

  const AllDownloadsCleared({
    required this.clearedCount,
    required this.filesDeleted,
  });

  @override
  List<Object?> get props => [clearedCount, filesDeleted];
}

/// State when max concurrent downloads has been set
class MaxConcurrentDownloadsSet extends DownloadState {
  final int maxConcurrent;

  const MaxConcurrentDownloadsSet({required this.maxConcurrent});

  @override
  List<Object?> get props => [maxConcurrent];
}

/// State when download queue is loaded
class DownloadQueueLoaded extends DownloadState {
  final List<DownloadModel> queue;

  const DownloadQueueLoaded({required this.queue});

  @override
  List<Object?> get props => [queue];
}

/// State when download queue has been reordered
class DownloadQueueReordered extends DownloadState {
  final List<String> newOrder;

  const DownloadQueueReordered({required this.newOrder});

  @override
  List<Object?> get props => [newOrder];
}

/// State when download has been moved in queue
class DownloadMovedInQueue extends DownloadState {
  final String downloadId;
  final String position; // 'top' or 'bottom'

  const DownloadMovedInQueue({
    required this.downloadId,
    required this.position,
  });

  @override
  List<Object?> get props => [downloadId, position];
}

/// State when download progress is being watched
class DownloadProgressWatching extends DownloadState {
  final String downloadId;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final double speed;
  final Duration estimatedTimeRemaining;

  const DownloadProgressWatching({
    required this.downloadId,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.speed,
    required this.estimatedTimeRemaining,
  });

  @override
  List<Object?> get props => [
        downloadId,
        progress,
        downloadedBytes,
        totalBytes,
        speed,
        estimatedTimeRemaining,
      ];
}

/// State when download progress watching has stopped
class DownloadProgressWatchingStopped extends DownloadState {
  final String downloadId;

  const DownloadProgressWatchingStopped({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// State when download settings have been updated
class DownloadSettingsUpdated extends DownloadState {
  const DownloadSettingsUpdated();
}

/// State when storage usage is loaded
class StorageUsageLoaded extends DownloadState {
  final int totalSize;
  final int availableSpace;
  final int usedSpace;
  final Map<String, int> sizeByStatus;

  const StorageUsageLoaded({
    required this.totalSize,
    required this.availableSpace,
    required this.usedSpace,
    required this.sizeByStatus,
  });

  @override
  List<Object?> get props => [totalSize, availableSpace, usedSpace, sizeByStatus];
}

/// State when storage cleanup is completed
class StorageCleanupCompleted extends DownloadState {
  final int freedSpace;
  final int removedFiles;

  const StorageCleanupCompleted({
    required this.freedSpace,
    required this.removedFiles,
  });

  @override
  List<Object?> get props => [freedSpace, removedFiles];
}

/// State when downloads have been exported
class DownloadsExported extends DownloadState {
  final String exportPath;
  final int exportedCount;

  const DownloadsExported({
    required this.exportPath,
    required this.exportedCount,
  });

  @override
  List<Object?> get props => [exportPath, exportedCount];
}

/// State when downloads have been imported
class DownloadsImported extends DownloadState {
  final int importedCount;
  final int skippedCount;

  const DownloadsImported({
    required this.importedCount,
    required this.skippedCount,
  });

  @override
  List<Object?> get props => [importedCount, skippedCount];
}

/// State when download file has been validated
class DownloadFileValidated extends DownloadState {
  final String downloadId;
  final bool isValid;
  final String? validationMessage;

  const DownloadFileValidated({
    required this.downloadId,
    required this.isValid,
    this.validationMessage,
  });

  @override
  List<Object?> get props => [downloadId, isValid, validationMessage];
}

/// State when download file has been repaired
class DownloadFileRepaired extends DownloadState {
  final String downloadId;
  final bool repairSuccessful;

  const DownloadFileRepaired({
    required this.downloadId,
    required this.repairSuccessful,
  });

  @override
  List<Object?> get props => [downloadId, repairSuccessful];
}

/// State when an error occurs
class DownloadError extends DownloadState {
  final Failure failure;
  final String message;

  const DownloadError({
    required this.failure,
    required this.message,
  });

  @override
  List<Object?> get props => [failure, message];
}

/// State for handling multiple concurrent download operations
class DownloadMultipleOperations extends DownloadState {
  final Map<String, DownloadState> operations;

  const DownloadMultipleOperations({required this.operations});

  @override
  List<Object?> get props => [operations];

  DownloadMultipleOperations copyWith({
    Map<String, DownloadState>? operations,
  }) {
    return DownloadMultipleOperations(
      operations: operations ?? this.operations,
    );
  }

  DownloadMultipleOperations addOperation(String key, DownloadState state) {
    final newOperations = Map<String, DownloadState>.from(operations);
    newOperations[key] = state;
    return copyWith(operations: newOperations);
  }

  DownloadMultipleOperations removeOperation(String key) {
    final newOperations = Map<String, DownloadState>.from(operations);
    newOperations.remove(key);
    return copyWith(operations: newOperations);
  }
}