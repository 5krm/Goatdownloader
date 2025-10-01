import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for resuming a paused download
class ResumeDownload extends UseCase<Result<Download>, String> {
  final DownloadRepository repository;

  ResumeDownload(this.repository);

  @override
  Future<Result<Download>> call(String downloadId) async {
    if (downloadId.isEmpty) {
      return Error(ValidationFailure(message: 'Download ID cannot be empty'));
    }

    try {
      return await repository.resumeDownload(downloadId);
    } catch (e) {
      return Error(DownloadFailure(
        message: 'Failed to resume download',
        details: {'error': e.toString(), 'download_id': downloadId},
      ));
    }
  }
}