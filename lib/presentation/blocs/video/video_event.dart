import 'package:equatable/equatable.dart';

/// Base class for all video events
abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

/// Event to get video information from URL
class GetVideoInfoEvent extends VideoEvent {
  final String url;

  const GetVideoInfoEvent({required this.url});

  @override
  List<Object?> get props => [url];
}

/// Event to validate video URL
class ValidateVideoUrlEvent extends VideoEvent {
  final String url;

  const ValidateVideoUrlEvent({required this.url});

  @override
  List<Object?> get props => [url];
}

/// Event to get video formats
class GetVideoFormatsEvent extends VideoEvent {
  final String videoId;
  final String platform;

  const GetVideoFormatsEvent({
    required this.videoId,
    required this.platform,
  });

  @override
  List<Object?> get props => [videoId, platform];
}

/// Event to get video subtitles
class GetVideoSubtitlesEvent extends VideoEvent {
  final String videoId;
  final String platform;

  const GetVideoSubtitlesEvent({
    required this.videoId,
    required this.platform,
  });

  @override
  List<Object?> get props => [videoId, platform];
}

/// Event to get related videos
class GetRelatedVideosEvent extends VideoEvent {
  final String videoId;
  final String platform;
  final int limit;

  const GetRelatedVideosEvent({
    required this.videoId,
    required this.platform,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [videoId, platform, limit];
}

/// Event to get video comments
class GetVideoCommentsEvent extends VideoEvent {
  final String videoId;
  final String platform;
  final int limit;

  const GetVideoCommentsEvent({
    required this.videoId,
    required this.platform,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [videoId, platform, limit];
}

/// Event to get channel information
class GetChannelInfoEvent extends VideoEvent {
  final String channelId;
  final String platform;

  const GetChannelInfoEvent({
    required this.channelId,
    required this.platform,
  });

  @override
  List<Object?> get props => [channelId, platform];
}

/// Event to get playlist information
class GetPlaylistInfoEvent extends VideoEvent {
  final String playlistId;
  final String platform;

  const GetPlaylistInfoEvent({
    required this.playlistId,
    required this.platform,
  });

  @override
  List<Object?> get props => [playlistId, platform];
}

/// Event to refresh video information
class RefreshVideoInfoEvent extends VideoEvent {
  final String videoId;
  final String platform;

  const RefreshVideoInfoEvent({
    required this.videoId,
    required this.platform,
  });

  @override
  List<Object?> get props => [videoId, platform];
}

/// Event to check if video is available
class CheckVideoAvailabilityEvent extends VideoEvent {
  final String videoId;
  final String platform;

  const CheckVideoAvailabilityEvent({
    required this.videoId,
    required this.platform,
  });

  @override
  List<Object?> get props => [videoId, platform];
}

/// Event to get video thumbnails
class GetVideoThumbnailsEvent extends VideoEvent {
  final String videoId;
  final String platform;

  const GetVideoThumbnailsEvent({
    required this.videoId,
    required this.platform,
  });

  @override
  List<Object?> get props => [videoId, platform];
}

/// Event to report video
class ReportVideoEvent extends VideoEvent {
  final String videoId;
  final String platform;
  final String reason;
  final String? description;

  const ReportVideoEvent({
    required this.videoId,
    required this.platform,
    required this.reason,
    this.description,
  });

  @override
  List<Object?> get props => [videoId, platform, reason, description];
}

/// Event to get video analytics
class GetVideoAnalyticsEvent extends VideoEvent {
  final String videoId;
  final String platform;

  const GetVideoAnalyticsEvent({
    required this.videoId,
    required this.platform,
  });

  @override
  List<Object?> get props => [videoId, platform];
}

/// Event to clear video data
class ClearVideoDataEvent extends VideoEvent {
  const ClearVideoDataEvent();
}

/// Event to reset video state
class ResetVideoStateEvent extends VideoEvent {
  const ResetVideoStateEvent();
}