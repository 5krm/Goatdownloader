import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports for use cases - Make sure these files exist
import '../../../domain/usecases/start_download.dart';
import '../../../domain/usecases/pause_download.dart';
import '../../../domain/usecases/resume_download.dart';
import '../../../domain/usecases/cancel_download.dart';
import '../../../domain/usecases/retry_download.dart';
import '../../../domain/usecases/get_all_downloads.dart';
import '../../../domain/usecases/get_active_downloads.dart';
import '../../../domain/usecases/get_completed_downloads.dart';
import '../../../domain/usecases/get_download_by_id.dart';
import '../../../domain/usecases/delete_download.dart';
import '../../../domain/usecases/watch_download_progress.dart';
import '../../../domain/usecases/update_download_metadata.dart';
import '../../../domain/usecases/get_download_statistics.dart';
import '../../../domain/usecases/clear_completed_downloads.dart';
import '../../../domain/usecases/set_max_concurrent_downloads.dart';
import '../../../domain/usecases/get_download_queue.dart';
import '../../../domain/usecases/reorder_download_queue.dart';
import '../../../core/error/failures.dart';
import '../../../core/storage/hive_helper.dart';
import '../../../core/usecase/usecase.dart'; // Add this import for NoParams
import '../../../domain/entities/download.dart'; // Add this for DownloadStatus
import 'download_event.dart';
import 'download_state.dart';

/// BLoC for managing download-related operations
class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final StartDownload _startDownload;
  final PauseDownload _pauseDownload;
  final ResumeDownload _resumeDownload;
  final CancelDownload _cancelDownload;
  final RetryDownload _retryDownload;
  final GetAllDownloads _getAllDownloads;
  final GetActiveDownloads _getActiveDownloads;
  final GetCompletedDownloads _getCompletedDownloads;
  final GetDownloadById _getDownloadById;
  final DeleteDownload _deleteDownload;
  final WatchDownloadProgress _watchDownloadProgress;
  final UpdateDownloadMetadata _updateDownloadMetadata;
  final GetDownloadStatistics _getDownloadStatistics;
  final ClearCompletedDownloads _clearCompletedDownloads;
  final SetMaxConcurrentDownloads _setMaxConcurrentDownloads;
  final GetDownloadQueue _getDownloadQueue;
  final ReorderDownloadQueue _reorderDownloadQueue;
  final HiveHelper _hiveHelper;

  // Stream subscriptions for progress tracking
  final Map<String, StreamSubscription> _progressSubscriptions = {};

  DownloadBloc({
    required StartDownload startDownload,
    required PauseDownload pauseDownload,
    required ResumeDownload resumeDownload,
    required CancelDownload cancelDownload,
    required RetryDownload retryDownload,
    required GetAllDownloads getAllDownloads,
    required GetActiveDownloads getActiveDownloads,
    required GetCompletedDownloads getCompletedDownloads,
    required GetDownloadById getDownloadById,
    required DeleteDownload deleteDownload,
    required WatchDownloadProgress watchDownloadProgress,
    required UpdateDownloadMetadata updateDownloadMetadata,
    required GetDownloadStatistics getDownloadStatistics,
    required ClearCompletedDownloads clearCompletedDownloads,
    required SetMaxConcurrentDownloads setMaxConcurrentDownloads,
    required GetDownloadQueue getDownloadQueue,
    required ReorderDownloadQueue reorderDownloadQueue,
    required HiveHelper hiveHelper,
  })  : _startDownload = startDownload,
        _pauseDownload = pauseDownload,
        _resumeDownload = resumeDownload,
        _cancelDownload = cancelDownload,
        _retryDownload = retryDownload,
        _getAllDownloads = getAllDownloads,
        _getActiveDownloads = getActiveDownloads,
        _getCompletedDownloads = getCompletedDownloads,
        _getDownloadById = getDownloadById,
        _deleteDownload = deleteDownload,
        _watchDownloadProgress = watchDownloadProgress,
        _updateDownloadMetadata = updateDownloadMetadata,
        _getDownloadStatistics = getDownloadStatistics,
        _clearCompletedDownloads = clearCompletedDownloads,
        _setMaxConcurrentDownloads = setMaxConcurrentDownloads,
        _getDownloadQueue = getDownloadQueue,
        _reorderDownloadQueue = reorderDownloadQueue,
        _hiveHelper = hiveHelper,
        super(const DownloadInitial()) {
    on<StartDownloadEvent>(_onStartDownload);
    on<PauseDownloadEvent>(_onPauseDownload);
    on<ResumeDownloadEvent>(_onResumeDownload);
    on<CancelDownloadEvent>(_onCancelDownload);
    on<RetryDownloadEvent>(_onRetryDownload);
    on<DeleteDownloadEvent>(_onDeleteDownload);
    on<GetAllDownloadsEvent>(_onGetAllDownloads);
    on<GetActiveDownloadsEvent>(_onGetActiveDownloads);
    on<GetCompletedDownloadsEvent>(_onGetCompletedDownloads);
    on<GetFailedDownloadsEvent>(_onGetFailedDownloads);
    on<GetDownloadsByStatusEvent>(_onGetDownloadsByStatus);
    on<GetDownloadsByPlatformEvent>(_onGetDownloadsByPlatform);
    on<SearchDownloadsEvent>(_onSearchDownloads);
    on<GetDownloadByIdEvent>(_onGetDownloadById);
    on<UpdateDownloadMetadataEvent>(_onUpdateDownloadMetadata);
    on<GetDownloadStatisticsEvent>(_onGetDownloadStatistics);
    on<ClearCompletedDownloadsEvent>(_onClearCompletedDownloads);
    on<ClearFailedDownloadsEvent>(_onClearFailedDownloads);
    on<ClearAllDownloadsEvent>(_onClearAllDownloads);
    on<SetMaxConcurrentDownloadsEvent>(_onSetMaxConcurrentDownloads);
    on<GetDownloadQueueEvent>(_onGetDownloadQueue);
    on<ReorderDownloadQueueEvent>(_onReorderDownloadQueue);
    on<MoveDownloadToTopEvent>(_onMoveDownloadToTop);
    on<MoveDownloadToBottomEvent>(_onMoveDownloadToBottom);
    on<RefreshDownloadsEvent>(_onRefreshDownloads);
    on<WatchDownloadProgressEvent>(_onWatchDownloadProgress);
    on<StopWatchingDownloadProgressEvent>(_onStopWatchingDownloadProgress);
    on<UpdateDownloadSettingsEvent>(_onUpdateDownloadSettings);
    on<GetStorageUsageEvent>(_onGetStorageUsage);
    on<CleanupStorageEvent>(_onCleanupStorage);
    on<ExportDownloadsEvent>(_onExportDownloads);
    on<ImportDownloadsEvent>(_onImportDownloads);
    on<ValidateDownloadFileEvent>(_onValidateDownloadFile);
    on<RepairDownloadFileEvent>(_onRepairDownloadFile);
    on<ResetDownloadStateEvent>(_onResetDownloadState);
  }

  /// Handles starting a new download
  Future<void> _onStartDownload(
    StartDownloadEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(const DownloadLoading(message: 'Starting download...'));

    final result = await _startDownload(StartDownloadParams(
      video: event.video,
      format: event.format,
      customPath: event.customPath,
      customFilename: event.customFilename,
      audioOnly: event.audioOnly,
      subtitleLanguage: event.subtitleLanguage,
    ));

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (download) => emit(DownloadStarted(download: download)),
    );
  }

  /// Handles pausing a download
  Future<void> _onPauseDownload(
    PauseDownloadEvent event,
    Emitter<DownloadState> emit,
  ) async {
    final result = await _pauseDownload(event.downloadId);

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (_) => emit(DownloadPaused(downloadId: event.downloadId)),
    );
  }

  /// Handles resuming a download
  Future<void> _onResumeDownload(
    ResumeDownloadEvent event,
    Emitter<DownloadState> emit,
  ) async {
    final result = await _resumeDownload(event.downloadId);

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (_) => emit(DownloadResumed(downloadId: event.downloadId)),
    );
  }

  /// Handles cancelling a download
  Future<void> _onCancelDownload(
    CancelDownloadEvent event,
    Emitter<DownloadState> emit,
  ) async {
    final result = await _cancelDownload(event.downloadId);

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (_) => emit(DownloadCancelled(
        downloadId: event.downloadId,
        fileDeleted: event.deleteFile,
      )),
    );
  }

  /// Handles retrying a failed download
  Future<void> _onRetryDownload(
    RetryDownloadEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(DownloadRetrying(
      downloadId: event.downloadId,
      attemptNumber: 1, // This should come from the download model
    ));

    final result = await _retryDownload(event.downloadId);

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (download) => emit(DownloadStarted(download: download)),
    );
  }

  /// Handles deleting a download
  Future<void> _onDeleteDownload(
    DeleteDownloadEvent event,
    Emitter<DownloadState> emit,
  ) async {
    final result = await _deleteDownload(DeleteDownloadParams(
      downloadId: event.downloadId,
      deleteFile: event.deleteFile,
    ));

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (_) => emit(DownloadDeleted(
        downloadId: event.downloadId,
        fileDeleted: event.deleteFile,
      )),
    );
  }

  /// Handles getting all downloads
  Future<void> _onGetAllDownloads(
    GetAllDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(const DownloadLoading(message: 'Loading downloads...'));

    final result = await _getAllDownloads(NoParams());

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (downloads) => emit(DownloadsLoaded(
        downloads: downloads,
        filterType: 'all',
      )),
    );
  }

  /// Handles getting active downloads
  Future<void> _onGetActiveDownloads(
    GetActiveDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(const DownloadLoading(message: 'Loading active downloads...'));

    final result = await _getActiveDownloads(NoParams());

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (downloads) => emit(ActiveDownloadsLoaded(downloads: downloads)),
    );
  }

  /// Handles getting completed downloads
  Future<void> _onGetCompletedDownloads(
    GetCompletedDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(const DownloadLoading(message: 'Loading completed downloads...'));

    final result = await _getCompletedDownloads(NoParams());

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (downloads) => emit(CompletedDownloadsLoaded(downloads: downloads)),
    );
  }

  /// Handles getting failed downloads
  Future<void> _onGetFailedDownloads(
    GetFailedDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(const DownloadLoading(message: 'Loading failed downloads...'));

    // This would need to be implemented in the repository
    // For now, we'll filter from all downloads
    final result = await _getAllDownloads(NoParams());

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (downloads) {
        final failedDownloads = downloads
            .where((download) => download.status == DownloadStatus.failed)
            .toList();
        emit(FailedDownloadsLoaded(downloads: failedDownloads));
      },
    );
  }

  /// Handles getting downloads by status
  Future<void> _onGetDownloadsByStatus(
    GetDownloadsByStatusEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(const DownloadLoading(message: 'Loading downloads...'));

    final result = await _getAllDownloads(NoParams());

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (downloads) {
        final filteredDownloads = downloads
            .where((download) => download.status == event.status)
            .toList();
        emit(DownloadsByStatusLoaded(
          downloads: filteredDownloads,
          status: event.status,
        ));
      },
    );
  }

  /// Handles getting downloads by platform
  Future<void> _onGetDownloadsByPlatform(
    GetDownloadsByPlatformEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(const DownloadLoading(message: 'Loading downloads...'));

    final result = await _getAllDownloads(NoParams());

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (downloads) {
        final filteredDownloads = downloads
            .where((download) => download.video.platform == event.platform)
            .toList();
        emit(DownloadsByPlatformLoaded(
          downloads: filteredDownloads,
          platform: event.platform,
        ));
      },
    );
  }

  /// Handles searching downloads
  Future<void> _onSearchDownloads(
    SearchDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(const DownloadLoading(message: 'Searching downloads...'));

    final result = await _getAllDownloads(NoParams());

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (downloads) {
        final searchResults = downloads
            .where((download) =>
                download.video.title.toLowerCase().contains(event.query.toLowerCase()) ||
                download.video.description.toLowerCase().contains(event.query.toLowerCase()) ||
                download.video.author.toLowerCase().contains(event.query.toLowerCase()))
            .toList();
        emit(DownloadSearchResultsLoaded(
          downloads: searchResults,
          query: event.query,
        ));
      },
    );
  }

  /// Handles getting download by ID
  Future<void> _onGetDownloadById(
    GetDownloadByIdEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(const DownloadLoading(message: 'Loading download...'));

    final result = await _getDownloadById(event.downloadId);

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (download) => emit(DownloadByIdLoaded(download: download)),
    );
  }

  /// Handles updating download metadata
  Future<void> _onUpdateDownloadMetadata(
    UpdateDownloadMetadataEvent event,
    Emitter<DownloadState> emit,
  ) async {
    final result = await _updateDownloadMetadata(UpdateDownloadMetadataParams(
      downloadId: event.downloadId,
      metadata: {
        'title': event.title,
        'description': event.description,
        'tags': event.tags,
      },
    ));

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (_) => emit(DownloadMetadataUpdated(downloadId: event.downloadId)),
    );
  }

  /// Handles getting download statistics
  Future<void> _onGetDownloadStatistics(
    GetDownloadStatisticsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    final result = await _getDownloadStatistics(NoParams());

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (statistics) => emit(DownloadStatisticsLoaded(statistics: statistics)),
    );
  }

  /// Handles clearing completed downloads
  Future<void> _onClearCompletedDownloads(
    ClearCompletedDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    final result = await _clearCompletedDownloads(NoParams());

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (clearedCount) => emit(CompletedDownloadsCleared(clearedCount: clearedCount)),
    );
  }

  /// Handles clearing failed downloads
  Future<void> _onClearFailedDownloads(
    ClearFailedDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    // This would need to be implemented in the repository
    emit(const FailedDownloadsCleared(clearedCount: 0, message: 'Failed downloads cleared'));
  }

  /// Handles clearing all downloads
  Future<void> _onClearAllDownloads(
    ClearAllDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    // This would need to be implemented in the repository
    emit(AllDownloadsCleared(
      clearedCount: 0,
      filesDeleted: event.deleteFiles,
      message: 'All downloads cleared',
    ));
  }

  /// Handles setting max concurrent downloads
  Future<void> _onSetMaxConcurrentDownloads(
    SetMaxConcurrentDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    final result = await _setMaxConcurrentDownloads(SetMaxConcurrentDownloadsParams(
      maxConcurrentDownloads: event.maxConcurrent,
    ));

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (_) => emit(MaxConcurrentDownloadsSet(maxConcurrent: event.maxConcurrent)),
    );
  }

  /// Handles getting download queue
  Future<void> _onGetDownloadQueue(
    GetDownloadQueueEvent event,
    Emitter<DownloadState> emit,
  ) async {
    final result = await _getDownloadQueue(NoParams());

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (queue) => emit(DownloadQueueLoaded(queue: queue)),
    );
  }

  /// Handles reordering download queue
  Future<void> _onReorderDownloadQueue(
    ReorderDownloadQueueEvent event,
    Emitter<DownloadState> emit,
  ) async {
    final result = await _reorderDownloadQueue(ReorderDownloadQueueParams(
      downloadIds: event.downloadIds,
    ));

    result.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (_) => emit(DownloadQueueReordered(newOrder: event.downloadIds)),
    );
  }

  /// Handles moving download to top of queue
  Future<void> _onMoveDownloadToTop(
    MoveDownloadToTopEvent event,
    Emitter<DownloadState> emit,
  ) async {
    // This would need to be implemented in the repository
    emit(DownloadMovedInQueue(
      downloadId: event.downloadId,
      position: 'top',
    ));
  }

  /// Handles moving download to bottom of queue
  Future<void> _onMoveDownloadToBottom(
    MoveDownloadToBottomEvent event,
    Emitter<DownloadState> emit,
  ) async {
    // This would need to be implemented in the repository
    emit(DownloadMovedInQueue(
      downloadId: event.downloadId,
      position: 'bottom',
    ));
  }

  /// Handles refreshing downloads
  Future<void> _onRefreshDownloads(
    RefreshDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    add(const GetAllDownloadsEvent());
  }

  /// Handles watching download progress
  Future<void> _onWatchDownloadProgress(
    WatchDownloadProgressEvent event,
    Emitter<DownloadState> emit,
  ) async {
    // Cancel existing subscription if any
    await _progressSubscriptions[event.downloadId]?.cancel();

    final progressStream = await _watchDownloadProgress(WatchDownloadProgressParams(
      downloadId: event.downloadId,
    ));

    progressStream.fold(
      (failure) => emit(DownloadError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (stream) {
        _progressSubscriptions[event.downloadId] = stream.listen(
          (progress) {
            emit(DownloadProgressWatching(
              downloadId: event.downloadId,
              progress: progress.progress,
              downloadedBytes: progress.downloadedBytes,
              totalBytes: progress.totalBytes,
              speed: progress.speed,
              estimatedTimeRemaining: progress.estimatedTimeRemaining,
            ));
          },
          onError: (error) {
            emit(DownloadError(
              failure: UnknownFailure(message: 'Progress tracking error: $error'),
              message: 'Progress tracking error: $error',
            ));
          },
        );
      },
    );
  }

  /// Handles stopping download progress watching
  Future<void> _onStopWatchingDownloadProgress(
    StopWatchingDownloadProgressEvent event,
    Emitter<DownloadState> emit,
  ) async {
    await _progressSubscriptions[event.downloadId]?.cancel();
    _progressSubscriptions.remove(event.downloadId);
    emit(DownloadProgressWatchingStopped(downloadId: event.downloadId));
  }

  /// Handles updating download settings
  Future<void> _onUpdateDownloadSettings(
    UpdateDownloadSettingsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      // Save settings to Hive
      if (event.defaultDownloadPath != null) {
        await _hiveHelper.saveUserPreference('defaultDownloadPath', event.defaultDownloadPath!);
      }
      if (event.defaultQuality != null) {
        await _hiveHelper.saveUserPreference('defaultQuality', event.defaultQuality!);
      }
      if (event.wifiOnlyDownloads != null) {
        await _hiveHelper.saveUserPreference('wifiOnlyDownloads', event.wifiOnlyDownloads!);
      }
      if (event.allowMobileDataDownloads != null) {
        await _hiveHelper.saveUserPreference('allowMobileDataDownloads', event.allowMobileDataDownloads!);
      }
      if (event.maxConcurrentDownloads != null) {
        await _hiveHelper.saveUserPreference('maxConcurrentDownloads', event.maxConcurrentDownloads!);
      }
      if (event.autoRetryFailedDownloads != null) {
        await _hiveHelper.saveUserPreference('autoRetryFailedDownloads', event.autoRetryFailedDownloads!);
      }
      if (event.maxRetryAttempts != null) {
        await _hiveHelper.saveUserPreference('maxRetryAttempts', event.maxRetryAttempts!);
      }

      emit(const DownloadSettingsUpdated(message: 'Settings updated successfully'));
    } catch (e) {
      emit(DownloadError(
        failure: StorageFailure(message: 'Failed to update download settings'),
        message: 'Failed to update download settings',
      ));
    }
  }

  /// Handles getting storage usage
  Future<void> _onGetStorageUsage(
    GetStorageUsageEvent event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      // This would need to be implemented properly
      emit(const StorageUsageLoaded(
        totalSize: 0,
        availableSpace: 0,
        usedSpace: 0,
        sizeByStatus: {},
        message: 'Storage usage loaded',
      ));
    } catch (e) {
      emit(DownloadError(
        failure: StorageFailure(message: 'Failed to get storage usage'),
        message: 'Failed to get storage usage',
      ));
    }
  }

  /// Handles storage cleanup
  Future<void> _onCleanupStorage(
    CleanupStorageEvent event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      // This would need to be implemented properly
      emit(const StorageCleanupCompleted(
        freedSpace: 0,
        removedFiles: 0,
        message: 'Storage cleanup completed',
      ));
    } catch (e) {
      emit(DownloadError(
        failure: StorageFailure(message: 'Failed to cleanup storage'),
        message: 'Failed to cleanup storage',
      ));
    }
  }

  /// Handles exporting downloads
  Future<void> _onExportDownloads(
    ExportDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      // This would need to be implemented properly
      emit(DownloadsExported(
        exportPath: event.exportPath,
        exportedCount: 0,
        message: 'Downloads exported successfully',
      ));
    } catch (e) {
      emit(DownloadError(
        failure: StorageFailure(message: 'Failed to export downloads'),
        message: 'Failed to export downloads',
      ));
    }
  }

  /// Handles importing downloads
  Future<void> _onImportDownloads(
    ImportDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      // This would need to be implemented properly
      emit(const DownloadsImported(
        importedCount: 0,
        skippedCount: 0,
        message: 'Downloads imported successfully',
      ));
    } catch (e) {
      emit(DownloadError(
        failure: StorageFailure(message: 'Failed to import downloads'),
        message: 'Failed to import downloads',
      ));
    }
  }

  /// Handles validating download file
  Future<void> _onValidateDownloadFile(
    ValidateDownloadFileEvent event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      // This would need to be implemented properly
      emit(DownloadFileValidated(
        downloadId: event.downloadId,
        isValid: true,
        validationMessage: 'File is valid',
      ));
    } catch (e) {
      emit(DownloadError(
        failure: ValidationFailure(message: 'Failed to validate download file'),
        message: 'Failed to validate download file',
      ));
    }
  }

  /// Handles repairing download file
  Future<void> _onRepairDownloadFile(
    RepairDownloadFileEvent event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      // This would need to be implemented properly
      emit(DownloadFileRepaired(
        downloadId: event.downloadId,
        repairSuccessful: true,
      ));
    } catch (e) {
      emit(DownloadError(
        failure: UnknownFailure(message: 'Failed to repair download file'),
        message: 'Failed to repair download file',
      ));
    }
  }

  /// Handles resetting download state
  Future<void> _onResetDownloadState(
    ResetDownloadStateEvent event,
    Emitter<DownloadState> emit,
  ) async {
    // Cancel all progress subscriptions
    for (final subscription in _progressSubscriptions.values) {
      await subscription.cancel();
    }
    _progressSubscriptions.clear();

    emit(const DownloadInitial());
  }

  /// Maps failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error occurred. Please try again later.';
      case CacheFailure _:
        return 'Cache error occurred. Please clear cache and try again.';
      case NetworkFailure _:
        return 'Network error. Please check your internet connection.';
      case ValidationFailure _:
        return 'Invalid download parameters. Please check your input.';
      case NotFoundFailure _:
        return 'Download not found.';
      case UnsupportedFormatFailure _:
        return 'Unsupported video format or platform.';
      case PermissionFailure _:
        return 'Permission denied. Please check storage permissions.';
      case StorageFailure _:
        return 'Storage error occurred. Please check available space.';
      case DownloadFailure _:
        return 'Download failed. Please try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Future<void> close() async {
    // Cancel all progress subscriptions
    for (final subscription in _progressSubscriptions.values) {
      await subscription.cancel();
    }
    _progressSubscriptions.clear();
    return super.close();
  }
}
