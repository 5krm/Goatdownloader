import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for getting a download by its ID
class GetDownloadById extends UseCase<Result<Download>, String> {
  final DownloadRepository repository;

  GetDownloadById(this.repository);

  @override
  Future<Result<Download>> call(String downloadId) async {
    if (downloadId.isEmpty) {
      return Error(ValidationFailure(message: 'Download ID cannot be empty'));
    }

    try {
      return await repository.getDownloadById(downloadId);
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to retrieve download',
        details: {'error': e.toString(), 'download_id': downloadId},
      ));
    }
  }
}