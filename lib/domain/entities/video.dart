import 'package:equatable/equatable.dart';

/// Core Video entity representing a downloadable video
/// 
/// This entity contains all the essential information about a video
/// that can be downloaded from various platforms. It's platform-agnostic
/// and contains only business logic relevant data.
class Video extends Equatable {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String originalUrl;
  final String platform;
  final Duration duration;
  final String uploader;
  final DateTime uploadDate;
  final int viewCount;
  final List<VideoFormat> availableFormats;
  final List<String> tags;
  final VideoCategory category;
  final String language;
  final bool isLiveStream;
  final bool isPrivate;
  final bool hasSubtitles;
  final Map<String, dynamic> metadata;

  const Video({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.originalUrl,
    required this.platform,
    required this.duration,
    required this.uploader,
    required this.uploadDate,
    required this.viewCount,
    required this.availableFormats,
    this.tags = const [],
    this.category = VideoCategory.other,
    this.language = 'en',
    this.isLiveStream = false,
    this.isPrivate = false,
    this.hasSubtitles = false,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        thumbnailUrl,
        originalUrl,
        platform,
        duration,
        uploader,
        uploadDate,
        viewCount,
        availableFormats,
        tags,
        category,
        language,
        isLiveStream,
        isPrivate,
        hasSubtitles,
        metadata,
      ];

  /// Creates a copy of this video with updated fields
  Video copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? originalUrl,
    String? platform,
    Duration? duration,
    String? uploader,
    DateTime? uploadDate,
    int? viewCount,
    List<VideoFormat>? availableFormats,
    List<String>? tags,
    VideoCategory? category,
    String? language,
    bool? isLiveStream,
    bool? isPrivate,
    bool? hasSubtitles,
    Map<String, dynamic>? metadata,
  }) {
    return Video(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      originalUrl: originalUrl ?? this.originalUrl,
      platform: platform ?? this.platform,
      duration: duration ?? this.duration,
      uploader: uploader ?? this.uploader,
      uploadDate: uploadDate ?? this.uploadDate,
      viewCount: viewCount ?? this.viewCount,
      availableFormats: availableFormats ?? this.availableFormats,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      language: language ?? this.language,
      isLiveStream: isLiveStream ?? this.isLiveStream,
      isPrivate: isPrivate ?? this.isPrivate,
      hasSubtitles: hasSubtitles ?? this.hasSubtitles,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Gets the best quality video format available
  VideoFormat? get bestQualityFormat {
    if (availableFormats.isEmpty) return null;
    
    final videoFormats = availableFormats
        .where((format) => format.type == FormatType.video)
        .toList();
    
    if (videoFormats.isEmpty) return availableFormats.first;
    
    videoFormats.sort((a, b) => b.quality.compareTo(a.quality));
    return videoFormats.first;
  }

  /// Gets the lowest quality video format available
  VideoFormat? get lowestQualityFormat {
    if (availableFormats.isEmpty) return null;
    
    final videoFormats = availableFormats
        .where((format) => format.type == FormatType.video)
        .toList();
    
    if (videoFormats.isEmpty) return availableFormats.first;
    
    videoFormats.sort((a, b) => a.quality.compareTo(b.quality));
    return videoFormats.first;
  }

  /// Gets audio-only formats
  List<VideoFormat> get audioFormats {
    return availableFormats
        .where((format) => format.type == FormatType.audio)
        .toList();
  }

  /// Gets video formats only
  List<VideoFormat> get videoFormats {
    return availableFormats
        .where((format) => format.type == FormatType.video)
        .toList();
  }

  /// Gets the estimated file size for a specific quality
  int? getEstimatedSize(String quality) {
    final format = availableFormats.firstWhere(
      (f) => f.qualityLabel == quality,
      orElse: () => availableFormats.first,
    );
    return format.fileSize;
  }

  /// Checks if the video is downloadable
  bool get isDownloadable {
    return !isLiveStream && !isPrivate && availableFormats.isNotEmpty;
  }

  /// Gets formatted duration string
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Gets formatted view count
  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M views';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K views';
    } else {
      return '$viewCount views';
    }
  }
}

/// Represents different video/audio formats available for download
class VideoFormat extends Equatable {
  final String formatId;
  final String url;
  final String qualityLabel;
  final int quality;
  final String extension;
  final int? fileSize;
  final int? bitrate;
  final String codec;
  final FormatType type;
  final bool hasAudio;
  final bool hasVideo;
  final Map<String, dynamic> additionalInfo;

  const VideoFormat({
    required this.formatId,
    required this.url,
    required this.qualityLabel,
    required this.quality,
    required this.extension,
    this.fileSize,
    this.bitrate,
    required this.codec,
    required this.type,
    this.hasAudio = false,
    this.hasVideo = false,
    this.additionalInfo = const {},
  });

  @override
  List<Object?> get props => [
        formatId,
        url,
        qualityLabel,
        quality,
        extension,
        fileSize,
        bitrate,
        codec,
        type,
        hasAudio,
        hasVideo,
        additionalInfo,
      ];

  /// Gets formatted file size string
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown size';
    
    final sizeInMB = fileSize! / (1024 * 1024);
    if (sizeInMB >= 1024) {
      return '${(sizeInMB / 1024).toStringAsFixed(1)} GB';
    } else {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }

  /// Gets formatted bitrate string
  String get formattedBitrate {
    if (bitrate == null) return 'Unknown bitrate';
    
    if (bitrate! >= 1000) {
      return '${(bitrate! / 1000).toStringAsFixed(1)} Mbps';
    } else {
      return '$bitrate kbps';
    }
  }

  VideoFormat copyWith({
    String? formatId,
    String? url,
    String? qualityLabel,
    int? quality,
    String? extension,
    int? fileSize,
    int? bitrate,
    String? codec,
    FormatType? type,
    bool? hasAudio,
    bool? hasVideo,
    Map<String, dynamic>? additionalInfo,
  }) {
    return VideoFormat(
      formatId: formatId ?? this.formatId,
      url: url ?? this.url,
      qualityLabel: qualityLabel ?? this.qualityLabel,
      quality: quality ?? this.quality,
      extension: extension ?? this.extension,
      fileSize: fileSize ?? this.fileSize,
      bitrate: bitrate ?? this.bitrate,
      codec: codec ?? this.codec,
      type: type ?? this.type,
      hasAudio: hasAudio ?? this.hasAudio,
      hasVideo: hasVideo ?? this.hasVideo,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}

/// Enum for different format types
enum FormatType {
  video,
  audio,
  combined,
}

/// Enum for video categories
enum VideoCategory {
  music,
  gaming,
  education,
  entertainment,
  news,
  sports,
  technology,
  lifestyle,
  comedy,
  documentary,
  other,
}

/// Extension methods for VideoCategory
extension VideoCategoryExtension on VideoCategory {
  String get displayName {
    switch (this) {
      case VideoCategory.music:
        return 'Music';
      case VideoCategory.gaming:
        return 'Gaming';
      case VideoCategory.education:
        return 'Education';
      case VideoCategory.entertainment:
        return 'Entertainment';
      case VideoCategory.news:
        return 'News';
      case VideoCategory.sports:
        return 'Sports';
      case VideoCategory.technology:
        return 'Technology';
      case VideoCategory.lifestyle:
        return 'Lifestyle';
      case VideoCategory.comedy:
        return 'Comedy';
      case VideoCategory.documentary:
        return 'Documentary';
      case VideoCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case VideoCategory.music:
        return '🎵';
      case VideoCategory.gaming:
        return '🎮';
      case VideoCategory.education:
        return '📚';
      case VideoCategory.entertainment:
        return '🎬';
      case VideoCategory.news:
        return '📰';
      case VideoCategory.sports:
        return '⚽';
      case VideoCategory.technology:
        return '💻';
      case VideoCategory.lifestyle:
        return '🌟';
      case VideoCategory.comedy:
        return '😂';
      case VideoCategory.documentary:
        return '🎥';
      case VideoCategory.other:
        return '📁';
    }
  }
}