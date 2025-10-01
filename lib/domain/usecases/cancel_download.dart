import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for cancelling a download
class CancelDownload extends UseCase<Result<bool>, String> {
  final DownloadRepository repository;

  CancelDownload(this.repository);

  @override
  Future<Result<bool>> call(String downloadId) async {
    if (downloadId.isEmpty) {
      return Error(ValidationFailure(message: 'Download ID cannot be empty'));
    }

    try {
      return await repository.cancelDownload(downloadId);
    } catch (e) {
      return Error(DownloadFailure(
        message: 'Failed to cancel download',
        details: {'error': e.toString(), 'download_id': downloadId},
      ));
    }
  }
}