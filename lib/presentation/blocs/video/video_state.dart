import 'package:equatable/equatable.dart';

import '../../../domain/entities/video.dart';
import '../../../core/error/failures.dart';

/// Base class for all video states
abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VideoInitial extends VideoState {
  const VideoInitial();
}

/// Loading state
class VideoLoading extends VideoState {
  const VideoLoading();
}

/// Video info loaded successfully
class VideoInfoLoaded extends VideoState {
  final Video video;

  const VideoInfoLoaded({required this.video});

  @override
  List<Object?> get props => [video];
}

/// Video URL validation result
class VideoUrlValidated extends VideoState {
  final bool isValid;
  final String? platform;
  final String? videoId;

  const VideoUrlValidated({
    required this.isValid,
    this.platform,
    this.videoId,
  });

  @override
  List<Object?> get props => [isValid, platform, videoId];
}

/// Video formats loaded
class VideoFormatsLoaded extends VideoState {
  final List<VideoFormat> formats;

  const VideoFormatsLoaded({required this.formats});

  @override
  List<Object?> get props => [formats];
}

/// Video subtitles loaded
class VideoSubtitlesLoaded extends VideoState {
  final List<Map<String, dynamic>> subtitles;

  const VideoSubtitlesLoaded({required this.subtitles});

  @override
  List<Object?> get props => [subtitles];
}

/// Related videos loaded
class RelatedVideosLoaded extends VideoState {
  final List<Video> relatedVideos;

  const RelatedVideosLoaded({required this.relatedVideos});

  @override
  List<Object?> get props => [relatedVideos];
}

/// Video comments loaded
class VideoCommentsLoaded extends VideoState {
  final List<Map<String, dynamic>> comments;

  const VideoCommentsLoaded({required this.comments});

  @override
  List<Object?> get props => [comments];
}

/// Channel info loaded
class ChannelInfoLoaded extends VideoState {
  final Map<String, dynamic> channelInfo;

  const ChannelInfoLoaded({required this.channelInfo});

  @override
  List<Object?> get props => [channelInfo];
}

/// Playlist info loaded
class PlaylistInfoLoaded extends VideoState {
  final Map<String, dynamic> playlistInfo;

  const PlaylistInfoLoaded({required this.playlistInfo});

  @override
  List<Object?> get props => [playlistInfo];
}

/// Video availability checked
class VideoAvailabilityChecked extends VideoState {
  final bool isAvailable;
  final String? reason;

  const VideoAvailabilityChecked({
    required this.isAvailable,
    this.reason,
  });

  @override
  List<Object?> get props => [isAvailable, reason];
}

/// Video thumbnails loaded
class VideoThumbnailsLoaded extends VideoState {
  final List<String> thumbnails;

  const VideoThumbnailsLoaded({required this.thumbnails});

  @override
  List<Object?> get props => [thumbnails];
}

/// Video reported successfully
class VideoReported extends VideoState {
  final String message;

  const VideoReported({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Video analytics loaded
class VideoAnalyticsLoaded extends VideoState {
  final Map<String, dynamic> analytics;

  const VideoAnalyticsLoaded({required this.analytics});

  @override
  List<Object?> get props => [analytics];
}

/// Video data cleared
class VideoDataCleared extends VideoState {
  const VideoDataCleared();
}

/// Error state
class VideoError extends VideoState {
  final Failure failure;
  final String message;

  const VideoError({
    required this.failure,
    required this.message,
  });

  @override
  List<Object?> get props => [failure, message];
}

/// Multiple operations state (for handling multiple concurrent operations)
class VideoMultipleOperations extends VideoState {
  final Video? video;
  final List<VideoFormat>? formats;
  final List<Map<String, dynamic>>? subtitles;
  final List<Video>? relatedVideos;
  final List<Map<String, dynamic>>? comments;
  final Map<String, dynamic>? channelInfo;
  final Map<String, dynamic>? playlistInfo;
  final bool? isAvailable;
  final List<String>? thumbnails;
  final Map<String, dynamic>? analytics;
  final bool isLoading;

  const VideoMultipleOperations({
    this.video,
    this.formats,
    this.subtitles,
    this.relatedVideos,
    this.comments,
    this.channelInfo,
    this.playlistInfo,
    this.isAvailable,
    this.thumbnails,
    this.analytics,
    this.isLoading = false,
  });

  VideoMultipleOperations copyWith({
    Video? video,
    List<VideoFormat>? formats,
    List<Map<String, dynamic>>? subtitles,
    List<Video>? relatedVideos,
    List<Map<String, dynamic>>? comments,
    Map<String, dynamic>? channelInfo,
    Map<String, dynamic>? playlistInfo,
    bool? isAvailable,
    List<String>? thumbnails,
    Map<String, dynamic>? analytics,
    bool? isLoading,
  }) {
    return VideoMultipleOperations(
      video: video ?? this.video,
      formats: formats ?? this.formats,
      subtitles: subtitles ?? this.subtitles,
      relatedVideos: relatedVideos ?? this.relatedVideos,
      comments: comments ?? this.comments,
      channelInfo: channelInfo ?? this.channelInfo,
      playlistInfo: playlistInfo ?? this.playlistInfo,
      isAvailable: isAvailable ?? this.isAvailable,
      thumbnails: thumbnails ?? this.thumbnails,
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        video,
        formats,
        subtitles,
        relatedVideos,
        comments,
        channelInfo,
        playlistInfo,
        isAvailable,
        thumbnails,
        analytics,
        isLoading,
      ];
}