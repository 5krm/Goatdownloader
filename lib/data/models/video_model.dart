import '../../domain/entities/video.dart';

/// Data model for Video entity
/// 
/// This model extends the Video entity and provides serialization/deserialization
/// capabilities for data persistence and network operations.
class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.title,
    required super.description,
    required super.originalUrl,
    required super.thumbnailUrl,
    required super.platform,
    required super.duration,
    required super.uploader,
    required super.uploadDate,
    required super.viewCount,
    required super.availableFormats,
    super.tags = const [],
    super.category = VideoCategory.other,
    super.language = 'en',
    super.isLiveStream = false,
    super.isPrivate = false,
    super.hasSubtitles = false,
    super.metadata = const {},
  });

  /// Creates a VideoModel from JSON
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      originalUrl: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      platform: json['platform'] as String,
      duration: Duration(seconds: json['duration'] as int),
      uploader: json['uploader'] as String? ?? '',
      uploadDate: DateTime.parse(json['upload_date'] as String),
      viewCount: json['view_count'] as int? ?? 0,
      availableFormats: (json['formats'] as List<dynamic>?)
          ?.map((format) => VideoFormatModel.fromJson(format as Map<String, dynamic>))
          .toList() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      category: _parseVideoCategory(json['category'] as String?),
      language: json['language'] as String? ?? 'en',
      isLiveStream: json['is_live'] as bool? ?? false,
      isPrivate: json['is_private'] as bool? ?? false,
      hasSubtitles: json['has_subtitles'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts VideoModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': originalUrl,
      'thumbnail_url': thumbnailUrl,
      'platform': platform,
      'duration': duration.inSeconds,
      'uploader': uploader,
      'upload_date': uploadDate.toIso8601String(),
      'view_count': viewCount,
      'formats': availableFormats.map((format) => 
        format is VideoFormatModel ? format.toJson() : VideoFormatModel.fromEntity(format).toJson()
      ).toList(),
      'tags': tags,
      'category': category.name,
      'language': language,
      'is_live': isLiveStream,
      'is_private': isPrivate,
      'has_subtitles': hasSubtitles,
      'metadata': metadata,
    };
  }

  /// Creates a VideoModel from Video entity
  factory VideoModel.fromEntity(Video video) {
    return VideoModel(
      id: video.id,
      title: video.title,
      description: video.description,
      originalUrl: video.originalUrl,
      thumbnailUrl: video.thumbnailUrl,
      platform: video.platform,
      duration: video.duration,
      uploader: video.uploader,
      uploadDate: video.uploadDate,
      viewCount: video.viewCount,
      availableFormats: video.availableFormats.map((format) => 
        format is VideoFormatModel ? format : VideoFormatModel.fromEntity(format)
      ).toList(),
      tags: video.tags,
      category: video.category,
      language: video.language,
      isLiveStream: video.isLiveStream,
      isPrivate: video.isPrivate,
      hasSubtitles: video.hasSubtitles,
      metadata: video.metadata,
    );
  }

  /// Helper method to parse VideoCategory from string
  static VideoCategory _parseVideoCategory(String? categoryString) {
    if (categoryString == null) return VideoCategory.other;
    
    try {
      return VideoCategory.values.firstWhere(
        (category) => category.name.toLowerCase() == categoryString.toLowerCase(),
        orElse: () => VideoCategory.other,
      );
    } catch (e) {
      return VideoCategory.other;
    }
  }

  @override
  VideoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? originalUrl,
    String? thumbnailUrl,
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
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      originalUrl: originalUrl ?? this.originalUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
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
}

/// Data model for VideoFormat entity
class VideoFormatModel extends VideoFormat {
  const VideoFormatModel({
    required super.formatId,
    required super.url,
    required super.quality,
    required super.fileSize,
    required super.bitrate,
    required super.codec,
    required super.type,
    required super.hasAudio,
    required super.hasVideo,
    super.fps,
    super.audioCodec,
    super.videoCodec,
    super.resolution,
    super.aspectRatio,
  });

  /// Creates a VideoFormatModel from JSON
  factory VideoFormatModel.fromJson(Map<String, dynamic> json) {
    return VideoFormatModel(
      formatId: json['format_id'] as String,
      url: json['url'] as String,
      quality: json['quality'] as String,
      fileSize: json['file_size'] as int?,
      bitrate: json['bitrate'] as int?,
      codec: json['codec'] as String? ?? '',
      type: _parseFormatType(json['type'] as String?),
      hasAudio: json['has_audio'] as bool? ?? false,
      hasVideo: json['has_video'] as bool? ?? false,
      fps: json['fps'] as int?,
      audioCodec: json['audio_codec'] as String?,
      videoCodec: json['video_codec'] as String?,
      resolution: json['resolution'] as String?,
      aspectRatio: json['aspect_ratio'] as String?,
    );
  }

  /// Converts VideoFormatModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'format_id': formatId,
      'url': url,
      'quality': quality,
      'file_size': fileSize,
      'bitrate': bitrate,
      'codec': codec,
      'type': type.name,
      'has_audio': hasAudio,
      'has_video': hasVideo,
      'fps': fps,
      'audio_codec': audioCodec,
      'video_codec': videoCodec,
      'resolution': resolution,
      'aspect_ratio': aspectRatio,
    };
  }

  /// Creates a VideoFormatModel from VideoFormat entity
  factory VideoFormatModel.fromEntity(VideoFormat format) {
    return VideoFormatModel(
      formatId: format.formatId,
      url: format.url,
      quality: format.quality,
      fileSize: format.fileSize,
      bitrate: format.bitrate,
      codec: format.codec,
      type: format.type,
      hasAudio: format.hasAudio,
      hasVideo: format.hasVideo,
      fps: format.fps,
      audioCodec: format.audioCodec,
      videoCodec: format.videoCodec,
      resolution: format.resolution,
      aspectRatio: format.aspectRatio,
    );
  }

  /// Helper method to parse FormatType from string
  static FormatType _parseFormatType(String? typeString) {
    if (typeString == null) return FormatType.video;
    
    try {
      return FormatType.values.firstWhere(
        (type) => type.name.toLowerCase() == typeString.toLowerCase(),
        orElse: () => FormatType.video,
      );
    } catch (e) {
      return FormatType.video;
    }
  }

  @override
  VideoFormatModel copyWith({
    String? formatId,
    String? url,
    String? quality,
    int? fileSize,
    int? bitrate,
    String? codec,
    FormatType? type,
    bool? hasAudio,
    bool? hasVideo,
    int? fps,
    String? audioCodec,
    String? videoCodec,
    String? resolution,
    String? aspectRatio,
  }) {
    return VideoFormatModel(
      formatId: formatId ?? this.formatId,
      url: url ?? this.url,
      quality: quality ?? this.quality,
      fileSize: fileSize ?? this.fileSize,
      bitrate: bitrate ?? this.bitrate,
      codec: codec ?? this.codec,
      type: type ?? this.type,
      hasAudio: hasAudio ?? this.hasAudio,
      hasVideo: hasVideo ?? this.hasVideo,
      fps: fps ?? this.fps,
      audioCodec: audioCodec ?? this.audioCodec,
      videoCodec: videoCodec ?? this.videoCodec,
      resolution: resolution ?? this.resolution,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }
}