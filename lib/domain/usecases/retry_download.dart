import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for retrying a failed download
class RetryDownload extends UseCase<Result<Download>, String> {
  final DownloadRepository repository;

  RetryDownload(this.repository);

  @override
  Future<Result<Download>> call(String downloadId) async {
    if (downloadId.isEmpty) {
      return Error(ValidationFailure(message: 'Download ID cannot be empty'));
    }

    try {
      return await repository.retryDownload(downloadId);
    } catch (e) {
      return Error(DownloadFailure(
        message: 'Failed to retry download',
        details: {'error': e.toString(), 'download_id': downloadId},
      ));
    }
  }
}