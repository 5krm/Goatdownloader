import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_video_info.dart';
import '../../../domain/usecases/search_videos.dart';
import '../../../core/error/failures.dart';
import 'video_event.dart';
import 'video_state.dart';

/// BLoC for managing video-related operations
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final GetVideoInfo _getVideoInfo;
  final ValidateVideoUrl _validateVideoUrl;

  VideoBloc({
    required GetVideoInfo getVideoInfo,
    required ValidateVideoUrl validateVideoUrl,
  })  : _getVideoInfo = getVideoInfo,
        _validateVideoUrl = validateVideoUrl,
        super(const VideoInitial()) {
    on<GetVideoInfoEvent>(_onGetVideoInfo);
    on<ValidateVideoUrlEvent>(_onValidateVideoUrl);
    on<GetVideoFormatsEvent>(_onGetVideoFormats);
    on<GetVideoSubtitlesEvent>(_onGetVideoSubtitles);
    on<GetRelatedVideosEvent>(_onGetRelatedVideos);
    on<GetVideoCommentsEvent>(_onGetVideoComments);
    on<GetChannelInfoEvent>(_onGetChannelInfo);
    on<GetPlaylistInfoEvent>(_onGetPlaylistInfo);
    on<RefreshVideoInfoEvent>(_onRefreshVideoInfo);
    on<CheckVideoAvailabilityEvent>(_onCheckVideoAvailability);
    on<GetVideoThumbnailsEvent>(_onGetVideoThumbnails);
    on<ReportVideoEvent>(_onReportVideo);
    on<GetVideoAnalyticsEvent>(_onGetVideoAnalytics);
    on<ClearVideoDataEvent>(_onClearVideoData);
    on<ResetVideoStateEvent>(_onResetVideoState);
  }

  /// Handles getting video information
  Future<void> _onGetVideoInfo(
    GetVideoInfoEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    final result = await _getVideoInfo(GetVideoInfoParams(url: event.url));

    result.fold(
      (failure) => emit(VideoError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (video) => emit(VideoInfoLoaded(video: video)),
    );
  }

  /// Handles validating video URL
  Future<void> _onValidateVideoUrl(
    ValidateVideoUrlEvent event,
    Emitter<VideoState> emit,
  ) async {
    final result = await _validateVideoUrl(ValidateVideoUrlParams(url: event.url));

    result.fold(
      (failure) => emit(VideoUrlValidated(
        isValid: false,
        platform: null,
        videoId: null,
      )),
      (validationResult) => emit(VideoUrlValidated(
        isValid: validationResult['isValid'] as bool,
        platform: validationResult['platform'] as String?,
        videoId: validationResult['videoId'] as String?,
      )),
    );
  }

  /// Handles getting video formats
  Future<void> _onGetVideoFormats(
    GetVideoFormatsEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    try {
      // This would typically use a repository method
      // For now, we'll emit an empty list as a placeholder
      emit(const VideoFormatsLoaded(formats: []));
    } catch (e) {
      emit(VideoError(
        failure: ServerFailure(),
        message: 'Failed to get video formats: $e',
      ));
    }
  }

  /// Handles getting video subtitles
  Future<void> _onGetVideoSubtitles(
    GetVideoSubtitlesEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    try {
      // This would typically use a repository method
      // For now, we'll emit an empty list as a placeholder
      emit(const VideoSubtitlesLoaded(subtitles: []));
    } catch (e) {
      emit(VideoError(
        failure: ServerFailure(),
        message: 'Failed to get video subtitles: $e',
      ));
    }
  }

  /// Handles getting related videos
  Future<void> _onGetRelatedVideos(
    GetRelatedVideosEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    try {
      // This would typically use a repository method
      // For now, we'll emit an empty list as a placeholder
      emit(const RelatedVideosLoaded(relatedVideos: []));
    } catch (e) {
      emit(VideoError(
        failure: ServerFailure(),
        message: 'Failed to get related videos: $e',
      ));
    }
  }

  /// Handles getting video comments
  Future<void> _onGetVideoComments(
    GetVideoCommentsEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    try {
      // This would typically use a repository method
      // For now, we'll emit an empty list as a placeholder
      emit(const VideoCommentsLoaded(comments: []));
    } catch (e) {
      emit(VideoError(
        failure: ServerFailure(),
        message: 'Failed to get video comments: $e',
      ));
    }
  }

  /// Handles getting channel information
  Future<void> _onGetChannelInfo(
    GetChannelInfoEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    try {
      // This would typically use a repository method
      // For now, we'll emit an empty map as a placeholder
      emit(const ChannelInfoLoaded(channelInfo: {}));
    } catch (e) {
      emit(VideoError(
        failure: ServerFailure(),
        message: 'Failed to get channel info: $e',
      ));
    }
  }

  /// Handles getting playlist information
  Future<void> _onGetPlaylistInfo(
    GetPlaylistInfoEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    try {
      // This would typically use a repository method
      // For now, we'll emit an empty map as a placeholder
      emit(const PlaylistInfoLoaded(playlistInfo: {}));
    } catch (e) {
      emit(VideoError(
        failure: ServerFailure(),
        message: 'Failed to get playlist info: $e',
      ));
    }
  }

  /// Handles refreshing video information
  Future<void> _onRefreshVideoInfo(
    RefreshVideoInfoEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    try {
      // This would typically use a repository method to refresh
      // For now, we'll just emit a loading state
      emit(const VideoLoading());
    } catch (e) {
      emit(VideoError(
        failure: ServerFailure(),
        message: 'Failed to refresh video info: $e',
      ));
    }
  }

  /// Handles checking video availability
  Future<void> _onCheckVideoAvailability(
    CheckVideoAvailabilityEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    try {
      // This would typically use a repository method
      // For now, we'll assume the video is available
      emit(const VideoAvailabilityChecked(
        isAvailable: true,
        reason: null,
      ));
    } catch (e) {
      emit(VideoError(
        failure: ServerFailure(),
        message: 'Failed to check video availability: $e',
      ));
    }
  }

  /// Handles getting video thumbnails
  Future<void> _onGetVideoThumbnails(
    GetVideoThumbnailsEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    try {
      // This would typically use a repository method
      // For now, we'll emit an empty list as a placeholder
      emit(const VideoThumbnailsLoaded(thumbnails: []));
    } catch (e) {
      emit(VideoError(
        failure: ServerFailure(),
        message: 'Failed to get video thumbnails: $e',
      ));
    }
  }

  /// Handles reporting video
  Future<void> _onReportVideo(
    ReportVideoEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    try {
      // This would typically use a repository method
      // For now, we'll just emit a success message
      emit(const VideoReported(message: 'Video reported successfully'));
    } catch (e) {
      emit(VideoError(
        failure: ServerFailure(),
        message: 'Failed to report video: $e',
      ));
    }
  }

  /// Handles getting video analytics
  Future<void> _onGetVideoAnalytics(
    GetVideoAnalyticsEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    try {
      // This would typically use a repository method
      // For now, we'll emit an empty map as a placeholder
      emit(const VideoAnalyticsLoaded(analytics: {}));
    } catch (e) {
      emit(VideoError(
        failure: ServerFailure(),
        message: 'Failed to get video analytics: $e',
      ));
    }
  }

  /// Handles clearing video data
  Future<void> _onClearVideoData(
    ClearVideoDataEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoDataCleared());
  }

  /// Handles resetting video state
  Future<void> _onResetVideoState(
    ResetVideoStateEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoInitial());
  }

  /// Maps failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case CacheFailure:
        return 'Cache error occurred. Please clear cache and try again.';
      case NetworkFailure:
        return 'Network error. Please check your internet connection.';
      case ValidationFailure:
        return 'Invalid input. Please check your data and try again.';
      case NotFoundFailure:
        return 'Video not found. Please check the URL and try again.';
      case UnsupportedFormatFailure:
        return 'Unsupported video format or platform.';
      case PermissionFailure:
        return 'Permission denied. Please check your access rights.';
      case StorageFailure:
        return 'Storage error occurred. Please check available space.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}