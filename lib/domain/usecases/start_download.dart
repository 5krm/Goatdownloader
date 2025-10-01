import '../entities/video.dart';
import '../entities/video_format.dart';
import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for starting a new download
class StartDownload extends UseCase<Result<Download>, StartDownloadParams> {
  final DownloadRepository repository;

  StartDownload(this.repository);

  @override
  Future<Result<Download>> call(StartDownloadParams params) async {
    // Validate video entity
    if (params.video.id.isEmpty) {
      return Error(ValidationFailure(
        message: 'Video ID cannot be empty',
      ));
    }

    // Validate selected format
    if (params.format.formatId.isEmpty) {
      return Error(ValidationFailure(
        message: 'Format ID cannot be empty',
      ));
    }

    try {
      final result = await repository.startDownload(
        video: params.video,
        format: params.format,
        customPath: params.customPath,
        customFilename: params.customFilename,
        audioOnly: params.audioOnly,
        subtitleLanguage: params.subtitleLanguage,
      );
      return result;
    } catch (e) {
      return Error(DownloadFailure(
        message: 'Failed to start download',
        details: {
          'error': e.toString(),
          'video_id': params.video.id,
          'format_id': params.format.formatId,
        },
      ));
    }
  }
}

/// Parameters for the StartDownload use case
class StartDownloadParams {
  final Video video;
  final VideoFormat format;
  final String? customPath;
  final String? customFilename;
  final bool audioOnly;
  final String? subtitleLanguage;

  const StartDownloadParams({
    required this.video,
    required this.format,
    this.customPath,
    this.customFilename,
    this.audioOnly = false,
    this.subtitleLanguage,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StartDownloadParams &&
        other.video == video &&
        other.format == format &&
        other.customPath == customPath &&
        other.customFilename == customFilename &&
        other.audioOnly == audioOnly &&
        other.subtitleLanguage == subtitleLanguage;
  }

  @override
  int get hashCode {
    return video.hashCode ^
        format.hashCode ^
        customPath.hashCode ^
        customFilename.hashCode ^
        audioOnly.hashCode ^
        subtitleLanguage.hashCode;
  }

  @override
  String toString() {
    return 'StartDownloadParams(video: ${video.id}, format: ${format.formatId}, audioOnly: $audioOnly)';
  }
}