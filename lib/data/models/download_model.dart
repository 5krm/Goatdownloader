import '../../domain/entities/download.dart';
import '../../domain/entities/video.dart';
import 'video_model.dart';

/// Data model for Download entity
/// 
/// This model extends the Download entity and provides serialization/deserialization
/// capabilities for data persistence and network operations.
class DownloadModel extends Download {
  const DownloadModel({
    required super.id,
    required super.video,
    required super.selectedFormat,
    required super.localPath,
    required super.status,
    super.progress = 0.0,
    super.downloadedBytes = 0,
    super.totalBytes = 0,
    required super.createdAt,
    super.startedAt,
    super.completedAt,
    super.pausedAt,
    super.errorMessage,
    super.quality = DownloadQuality.medium,
    super.isAudioOnly = false,
    super.metadata = const {},
  });

  /// Creates a DownloadModel from JSON
  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      id: json['id'] as String,
      video: VideoModel.fromJson(json['video'] as Map<String, dynamic>),
      selectedFormat: VideoFormatModel.fromJson(json['selected_format'] as Map<String, dynamic>),
      localPath: json['local_path'] as String,
      status: _parseDownloadStatus(json['status'] as String),
      progress: (json['progress'] as num).toDouble(),
      downloadedBytes: json['downloaded_bytes'] as int,
      totalBytes: json['total_bytes'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at'] as String) 
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      pausedAt: json['paused_at'] != null 
          ? DateTime.parse(json['paused_at'] as String) 
          : null,
      errorMessage: json['error_message'] as String?,
      quality: _parseDownloadQuality(json['quality'] as String?),
      isAudioOnly: json['is_audio_only'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts DownloadModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video': (video as VideoModel).toJson(),
      'selected_format': (selectedFormat as VideoFormatModel).toJson(),
      'local_path': localPath,
      'status': status.name,
      'progress': progress,
      'downloaded_bytes': downloadedBytes,
      'total_bytes': totalBytes,
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'paused_at': pausedAt?.toIso8601String(),
      'error_message': errorMessage,
      'quality': quality.name,
      'is_audio_only': isAudioOnly,
      'metadata': metadata,
    };
  }

  /// Creates a DownloadModel from Download entity
  factory DownloadModel.fromEntity(Download download) {
    return DownloadModel(
      id: download.id,
      video: download.video is VideoModel 
          ? download.video as VideoModel
          : VideoModel.fromEntity(download.video),
      selectedFormat: download.selectedFormat is VideoFormatModel
          ? download.selectedFormat as VideoFormatModel
          : VideoFormatModel.fromEntity(download.selectedFormat),
      localPath: download.localPath,
      status: download.status,
      progress: download.progress,
      downloadedBytes: download.downloadedBytes,
      totalBytes: download.totalBytes,
      createdAt: download.createdAt,
      startedAt: download.startedAt,
      completedAt: download.completedAt,
      pausedAt: download.pausedAt,
      errorMessage: download.errorMessage,
      quality: download.quality,
      isAudioOnly: download.isAudioOnly,
      metadata: download.metadata,
    );
  }

  /// Helper method to parse DownloadStatus from string
  static DownloadStatus _parseDownloadStatus(String statusString) {
    try {
      return DownloadStatus.values.firstWhere(
        (status) => status.name.toLowerCase() == statusString.toLowerCase(),
        orElse: () => DownloadStatus.queued,
      );
    } catch (e) {
      return DownloadStatus.queued;
    }
  }

  /// Helper method to parse DownloadQuality from string
  static DownloadQuality _parseDownloadQuality(String? qualityString) {
    if (qualityString == null) return DownloadQuality.medium;
    
    try {
      return DownloadQuality.values.firstWhere(
        (quality) => quality.name.toLowerCase() == qualityString.toLowerCase(),
        orElse: () => DownloadQuality.medium,
      );
    } catch (e) {
      return DownloadQuality.medium;
    }
  }

  @override
  DownloadModel copyWith({
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
    return DownloadModel(
      id: id ?? this.id,
      video: video is VideoModel 
          ? video 
          : (video != null ? VideoModel.fromEntity(video) : this.video as VideoModel),
      selectedFormat: selectedFormat is VideoFormatModel
          ? selectedFormat
          : (selectedFormat != null 
              ? VideoFormatModel.fromEntity(selectedFormat) 
              : this.selectedFormat as VideoFormatModel),
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
}

/// Data model for DownloadStats entity
class DownloadStatsModel extends DownloadStats {
  const DownloadStatsModel({
    required super.totalDownloads,
    required super.completedDownloads,
    required super.failedDownloads,
    required super.totalBytes,
    required super.totalTime,
    required super.averageSpeed,
    required super.platformStats,
    required super.qualityStats,
  });

  /// Creates a DownloadStatsModel from JSON
  factory DownloadStatsModel.fromJson(Map<String, dynamic> json) {
    return DownloadStatsModel(
      totalDownloads: json['total_downloads'] as int,
      completedDownloads: json['completed_downloads'] as int,
      failedDownloads: json['failed_downloads'] as int,
      totalBytes: json['total_bytes'] as int,
      totalTime: Duration(milliseconds: json['total_time_ms'] as int),
      averageSpeed: (json['average_speed'] as num).toDouble(),
      platformStats: Map<String, int>.from(json['platform_stats'] as Map),
      qualityStats: Map<DownloadQuality, int>.from(
        (json['quality_stats'] as Map).map(
          (key, value) => MapEntry(
            DownloadQuality.values.firstWhere((q) => q.name == key),
            value as int,
          ),
        ),
      ),
    );
  }

  /// Converts DownloadStatsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_downloads': totalDownloads,
      'completed_downloads': completedDownloads,
      'failed_downloads': failedDownloads,
      'total_bytes': totalBytes,
      'total_time_ms': totalTime.inMilliseconds,
      'average_speed': averageSpeed,
      'platform_stats': platformStats,
      'quality_stats': qualityStats.map(
        (key, value) => MapEntry(key.name, value),
      ),
    };
  }

  /// Creates a DownloadStatsModel from DownloadStats entity
  factory DownloadStatsModel.fromEntity(DownloadStats stats) {
    return DownloadStatsModel(
      totalDownloads: stats.totalDownloads,
      completedDownloads: stats.completedDownloads,
      failedDownloads: stats.failedDownloads,
      totalBytes: stats.totalBytes,
      totalTime: stats.totalTime,
      averageSpeed: stats.averageSpeed,
      platformStats: stats.platformStats,
      qualityStats: stats.qualityStats,
    );
  }

  @override
  DownloadStatsModel copyWith({
    int? totalDownloads,
    int? completedDownloads,
    int? failedDownloads,
    int? totalBytes,
    Duration? totalTime,
    double? averageSpeed,
    Map<String, int>? platformStats,
    Map<DownloadQuality, int>? qualityStats,
  }) {
    return DownloadStatsModel(
      totalDownloads: totalDownloads ?? this.totalDownloads,
      completedDownloads: completedDownloads ?? this.completedDownloads,
      failedDownloads: failedDownloads ?? this.failedDownloads,
      totalBytes: totalBytes ?? this.totalBytes,
      totalTime: totalTime ?? this.totalTime,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      platformStats: platformStats ?? this.platformStats,
      qualityStats: qualityStats ?? this.qualityStats,
    );
  }
}