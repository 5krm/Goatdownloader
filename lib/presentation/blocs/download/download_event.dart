import 'package:equatable/equatable.dart';

import '../../../domain/entities/video.dart';
import '../../../domain/entities/download.dart';
import '../../../data/models/video_model.dart';

/// Base class for all download events
abstract class DownloadEvent extends Equatable {
  const DownloadEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start a new download
class StartDownloadEvent extends DownloadEvent {
  final VideoModel video;
  final VideoFormatModel format;
  final String? customPath;
  final String? customFilename;
  final bool audioOnly;
  final String? subtitleLanguage;

  const StartDownloadEvent({
    required this.video,
    required this.format,
    this.customPath,
    this.customFilename,
    this.audioOnly = false,
    this.subtitleLanguage,
  });

  @override
  List<Object?> get props => [
        video,
        format,
        customPath,
        customFilename,
        audioOnly,
        subtitleLanguage,
      ];
}

/// Event to pause a download
class PauseDownloadEvent extends DownloadEvent {
  final String downloadId;

  const PauseDownloadEvent({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// Event to resume a download
class ResumeDownloadEvent extends DownloadEvent {
  final String downloadId;

  const ResumeDownloadEvent({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// Event to cancel a download
class CancelDownloadEvent extends DownloadEvent {
  final String downloadId;
  final bool deleteFile;

  const CancelDownloadEvent({
    required this.downloadId,
    this.deleteFile = false,
  });

  @override
  List<Object?> get props => [downloadId, deleteFile];
}

/// Event to retry a failed download
class RetryDownloadEvent extends DownloadEvent {
  final String downloadId;

  const RetryDownloadEvent({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// Event to delete a download record and optionally its file
class DeleteDownloadEvent extends DownloadEvent {
  final String downloadId;
  final bool deleteFile;

  const DeleteDownloadEvent({
    required this.downloadId,
    this.deleteFile = true,
  });

  @override
  List<Object?> get props => [downloadId, deleteFile];
}

/// Event to get all downloads
class GetAllDownloadsEvent extends DownloadEvent {
  const GetAllDownloadsEvent();
}

/// Event to get active downloads
class GetActiveDownloadsEvent extends DownloadEvent {
  const GetActiveDownloadsEvent();
}

/// Event to get completed downloads
class GetCompletedDownloadsEvent extends DownloadEvent {
  const GetCompletedDownloadsEvent();
}

/// Event to get failed downloads
class GetFailedDownloadsEvent extends DownloadEvent {
  const GetFailedDownloadsEvent();
}

/// Event to get downloads by status
class GetDownloadsByStatusEvent extends DownloadEvent {
  final DownloadStatus status;

  const GetDownloadsByStatusEvent({required this.status});

  @override
  List<Object?> get props => [status];
}

/// Event to get downloads by platform
class GetDownloadsByPlatformEvent extends DownloadEvent {
  final String platform;

  const GetDownloadsByPlatformEvent({required this.platform});

  @override
  List<Object?> get props => [platform];
}

/// Event to search downloads
class SearchDownloadsEvent extends DownloadEvent {
  final String query;

  const SearchDownloadsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to get download by ID
class GetDownloadByIdEvent extends DownloadEvent {
  final String downloadId;

  const GetDownloadByIdEvent({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// Event to update download metadata
class UpdateDownloadMetadataEvent extends DownloadEvent {
  final String downloadId;
  final String? title;
  final String? description;
  final List<String>? tags;

  const UpdateDownloadMetadataEvent({
    required this.downloadId,
    this.title,
    this.description,
    this.tags,
  });

  @override
  List<Object?> get props => [downloadId, title, description, tags];
}

/// Event to get download statistics
class GetDownloadStatisticsEvent extends DownloadEvent {
  const GetDownloadStatisticsEvent();
}

/// Event to clear completed downloads
class ClearCompletedDownloadsEvent extends DownloadEvent {
  const ClearCompletedDownloadsEvent();
}

/// Event to clear failed downloads
class ClearFailedDownloadsEvent extends DownloadEvent {
  const ClearFailedDownloadsEvent();
}

/// Event to clear all downloads
class ClearAllDownloadsEvent extends DownloadEvent {
  final bool deleteFiles;

  const ClearAllDownloadsEvent({this.deleteFiles = false});

  @override
  List<Object?> get props => [deleteFiles];
}

/// Event to set maximum concurrent downloads
class SetMaxConcurrentDownloadsEvent extends DownloadEvent {
  final int maxConcurrent;

  const SetMaxConcurrentDownloadsEvent({required this.maxConcurrent});

  @override
  List<Object?> get props => [maxConcurrent];
}

/// Event to get download queue
class GetDownloadQueueEvent extends DownloadEvent {
  const GetDownloadQueueEvent();
}

/// Event to reorder download queue
class ReorderDownloadQueueEvent extends DownloadEvent {
  final List<String> downloadIds;

  const ReorderDownloadQueueEvent({required this.downloadIds});

  @override
  List<Object?> get props => [downloadIds];
}

/// Event to move download to top of queue
class MoveDownloadToTopEvent extends DownloadEvent {
  final String downloadId;

  const MoveDownloadToTopEvent({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// Event to move download to bottom of queue
class MoveDownloadToBottomEvent extends DownloadEvent {
  final String downloadId;

  const MoveDownloadToBottomEvent({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// Event to refresh downloads list
class RefreshDownloadsEvent extends DownloadEvent {
  const RefreshDownloadsEvent();
}

/// Event to watch download progress
class WatchDownloadProgressEvent extends DownloadEvent {
  final String downloadId;

  const WatchDownloadProgressEvent({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// Event to stop watching download progress
class StopWatchingDownloadProgressEvent extends DownloadEvent {
  final String downloadId;

  const StopWatchingDownloadProgressEvent({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// Event to update download settings
class UpdateDownloadSettingsEvent extends DownloadEvent {
  final String? defaultDownloadPath;
  final String? defaultQuality;
  final bool? wifiOnlyDownloads;
  final bool? allowMobileDataDownloads;
  final int? maxConcurrentDownloads;
  final bool? autoRetryFailedDownloads;
  final int? maxRetryAttempts;

  const UpdateDownloadSettingsEvent({
    this.defaultDownloadPath,
    this.defaultQuality,
    this.wifiOnlyDownloads,
    this.allowMobileDataDownloads,
    this.maxConcurrentDownloads,
    this.autoRetryFailedDownloads,
    this.maxRetryAttempts,
  });

  @override
  List<Object?> get props => [
        defaultDownloadPath,
        defaultQuality,
        wifiOnlyDownloads,
        allowMobileDataDownloads,
        maxConcurrentDownloads,
        autoRetryFailedDownloads,
        maxRetryAttempts,
      ];
}

/// Event to get storage usage
class GetStorageUsageEvent extends DownloadEvent {
  const GetStorageUsageEvent();
}

/// Event to cleanup storage
class CleanupStorageEvent extends DownloadEvent {
  final bool removeIncompleteDownloads;
  final bool removeOldDownloads;
  final int? olderThanDays;

  const CleanupStorageEvent({
    this.removeIncompleteDownloads = false,
    this.removeOldDownloads = false,
    this.olderThanDays,
  });

  @override
  List<Object?> get props => [
        removeIncompleteDownloads,
        removeOldDownloads,
        olderThanDays,
      ];
}

/// Event to export downloads list
class ExportDownloadsEvent extends DownloadEvent {
  final String exportPath;
  final String format; // json, csv, etc.

  const ExportDownloadsEvent({
    required this.exportPath,
    required this.format,
  });

  @override
  List<Object?> get props => [exportPath, format];
}

/// Event to import downloads list
class ImportDownloadsEvent extends DownloadEvent {
  final String importPath;

  const ImportDownloadsEvent({required this.importPath});

  @override
  List<Object?> get props => [importPath];
}

/// Event to reset download state
class ResetDownloadStateEvent extends DownloadEvent {
  const ResetDownloadStateEvent();
}

/// Event to validate download file
class ValidateDownloadFileEvent extends DownloadEvent {
  final String downloadId;

  const ValidateDownloadFileEvent({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}

/// Event to repair download file
class RepairDownloadFileEvent extends DownloadEvent {
  final String downloadId;

  const RepairDownloadFileEvent({required this.downloadId});

  @override
  List<Object?> get props => [downloadId];
}