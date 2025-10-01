import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for pausing a download
class PauseDownload extends UseCase<Result<Download>, String> {
  final DownloadRepository repository;

  PauseDownload(this.repository);

  @override
  Future<Result<Download>> call(String downloadId) async {
    if (downloadId.isEmpty) {
      return Error(ValidationFailure(message: 'Download ID cannot be empty'));
    }

    try {
      return await repository.pauseDownload(downloadId);
    } catch (e) {
      return Error(DownloadFailure(
        message: 'Failed to pause download',
        details: {'error': e.toString(), 'download_id': downloadId},
      ));
    }
  }
}