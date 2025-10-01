import 'package:equatable/equatable.dart';
import 'video.dart';

/// Represents a download operation with its current state and progress
/// 
/// This entity tracks the download process from initiation to completion,
/// including progress updates, pause/resume functionality, and error handling.
class Download extends Equatable {
  final String id;
  final Video video;
  final VideoFormat selectedFormat;
  final String localPath;
  final DownloadStatus status;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? pausedAt;
  final String? errorMessage;
  final DownloadQuality quality;
  final bool isAudioOnly;
  final Map<String, dynamic> metadata;

  const Download({
    required this.id,
    required this.video,
    required this.selectedFormat,
    required this.localPath,
    required this.status,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.pausedAt,
    this.errorMessage,
    this.quality = DownloadQuality.medium,
    this.isAudioOnly = false,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        video,
        selectedFormat,
        localPath,
        status,
        progress,
        downloadedBytes,
        totalBytes,
        createdAt,
        startedAt,
        completedAt,
        pausedAt,
        errorMessage,
        quality,
        isAudioOnly,
        metadata,
      ];

  /// Creates a copy of this download with updated fields
  Download copyWith({
    String? id,
    Video? video,
    VideoFormat? selectedFormat,
    String? localPath,
    DownloadStatus? status,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? pausedAt,
    String? errorMessage,
    DownloadQuality? quality,
    bool? isAudioOnly,
    Map<String, dynamic>? metadata,
  }) {
    return Download(
      id: id ?? this.id,
      video: video ?? this.video,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      quality: quality ?? this.quality,
      isAudioOnly: isAudioOnly ?? this.isAudioOnly,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Gets the download speed in bytes per second
  double get downloadSpeed {
    if (startedAt == null || downloadedBytes == 0) return 0.0;
    
    final elapsed = DateTime.now().difference(startedAt!);
    if (elapsed.inSeconds == 0) return 0.0;
    
    return downloadedBytes / elapsed.inSeconds;
  }

  /// Gets formatted download speed string
  String get formattedDownloadSpeed {
    final speed = downloadSpeed;
    if (speed >= 1024 * 1024) {
      return '${(speed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    } else if (speed >= 1024) {
      return '${(speed / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${speed.toStringAsFixed(0)} B/s';
    }
  }

  /// Gets estimated time remaining for download
  Duration? get estimatedTimeRemaining {
    if (status != DownloadStatus.downloading || downloadSpeed == 0) {
      return null;
    }
    
    final remainingBytes = totalBytes - downloadedBytes;
    final secondsRemaining = remainingBytes / downloadSpeed;
    
    return Duration(seconds: secondsRemaining.round());
  }

  /// Gets formatted time remaining string
  String get formattedTimeRemaining {
    final timeRemaining = estimatedTimeRemaining;
    if (timeRemaining == null) return 'Unknown';
    
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes.remainder(60);
    final seconds = timeRemaining.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Gets formatted file size string
  String get formattedFileSize {
    if (totalBytes == 0) return 'Unknown size';
    
    final sizeInMB = totalBytes / (1024 * 1024);
    if (sizeInMB >= 1024) {
      return '${(sizeInMB / 1024).toStringAsFixed(1)} GB';
    } else {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }

  /// Gets formatted downloaded size string
  String get formattedDownloadedSize {
    final sizeInMB = downloadedBytes / (1024 * 1024);
    if (sizeInMB >= 1024) {
      return '${(sizeInMB / 1024).toStringAsFixed(1)} GB';
    } else {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }

  /// Gets progress percentage as integer
  int get progressPercentage => (progress * 100).round();

  /// Checks if download can be paused
  bool get canPause => status == DownloadStatus.downloading;

  /// Checks if download can be resumed
  bool get canResume => status == DownloadStatus.paused;

  /// Checks if download can be cancelled
  bool get canCancel => status == DownloadStatus.downloading || 
                       status == DownloadStatus.paused ||
                       status == DownloadStatus.queued;

  /// Checks if download can be retried
  bool get canRetry => status == DownloadStatus.failed;

  /// Checks if download is active (downloading or queued)
  bool get isActive => status == DownloadStatus.downloading || 
                      status == DownloadStatus.queued;

  /// Checks if download is completed successfully
  bool get isCompleted => status == DownloadStatus.completed;

  /// Checks if download has failed
  bool get isFailed => status == DownloadStatus.failed;

  /// Gets the total download duration
  Duration? get totalDownloadDuration {
    if (startedAt == null) return null;
    
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  /// Gets formatted total download duration
  String get formattedDownloadDuration {
    final duration = totalDownloadDuration;
    if (duration == null) return 'Unknown';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// Enum representing different download statuses
enum DownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

/// Extension methods for DownloadStatus
extension DownloadStatusExtension on DownloadStatus {
  String get displayName {
    switch (this) {
      case DownloadStatus.queued:
        return 'Queued';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get icon {
    switch (this) {
      case DownloadStatus.queued:
        return '⏳';
      case DownloadStatus.downloading:
        return '⬇️';
      case DownloadStatus.paused:
        return '⏸️';
      case DownloadStatus.completed:
        return '✅';
      case DownloadStatus.failed:
        return '❌';
      case DownloadStatus.cancelled:
        return '🚫';
    }
  }

  bool get isActive => this == DownloadStatus.downloading || 
                      this == DownloadStatus.queued;

  bool get isFinished => this == DownloadStatus.completed || 
                        this == DownloadStatus.failed || 
                        this == DownloadStatus.cancelled;
}

/// Enum for download quality presets
enum DownloadQuality {
  low,
  medium,
  high,
  highest,
  audioOnly,
}

/// Extension methods for DownloadQuality
extension DownloadQualityExtension on DownloadQuality {
  String get displayName {
    switch (this) {
      case DownloadQuality.low:
        return 'Low (360p)';
      case DownloadQuality.medium:
        return 'Medium (480p)';
      case DownloadQuality.high:
        return 'High (720p)';
      case DownloadQuality.highest:
        return 'Highest (1080p+)';
      case DownloadQuality.audioOnly:
        return 'Audio Only';
    }
  }

  String get qualityLabel {
    switch (this) {
      case DownloadQuality.low:
        return '360p';
      case DownloadQuality.medium:
        return '480p';
      case DownloadQuality.high:
        return '720p';
      case DownloadQuality.highest:
        return '1080p';
      case DownloadQuality.audioOnly:
        return 'Audio';
    }
  }

  int get qualityValue {
    switch (this) {
      case DownloadQuality.low:
        return 360;
      case DownloadQuality.medium:
        return 480;
      case DownloadQuality.high:
        return 720;
      case DownloadQuality.highest:
        return 1080;
      case DownloadQuality.audioOnly:
        return 0;
    }
  }
}

/// Download statistics for analytics
class DownloadStats extends Equatable {
  final int totalDownloads;
  final int completedDownloads;
  final int failedDownloads;
  final int totalBytes;
  final Duration totalTime;
  final double averageSpeed;
  final Map<String, int> platformStats;
  final Map<DownloadQuality, int> qualityStats;

  const DownloadStats({
    required this.totalDownloads,
    required this.completedDownloads,
    required this.failedDownloads,
    required this.totalBytes,
    required this.totalTime,
    required this.averageSpeed,
    required this.platformStats,
    required this.qualityStats,
  });

  @override
  List<Object?> get props => [
        totalDownloads,
        completedDownloads,
        failedDownloads,
        totalBytes,
        totalTime,
        averageSpeed,
        platformStats,
        qualityStats,
      ];

  double get successRate {
    if (totalDownloads == 0) return 0.0;
    return completedDownloads / totalDownloads;
  }

  String get formattedTotalSize {
    final sizeInGB = totalBytes / (1024 * 1024 * 1024);
    if (sizeInGB >= 1) {
      return '${sizeInGB.toStringAsFixed(1)} GB';
    } else {
      final sizeInMB = totalBytes / (1024 * 1024);
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }

  String get formattedAverageSpeed {
    if (averageSpeed >= 1024 * 1024) {
      return '${(averageSpeed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    } else if (averageSpeed >= 1024) {
      return '${(averageSpeed / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${averageSpeed.toStringAsFixed(0)} B/s';
    }
  }
}