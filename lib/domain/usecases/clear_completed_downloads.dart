import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for clearing completed downloads
class ClearCompletedDownloads extends UseCase<Result<bool>, NoParams> {
  final DownloadRepository repository;

  ClearCompletedDownloads(this.repository);

  @override
  Future<Result<bool>> call(NoParams params) async {
    try {
      return await repository.clearCompletedDownloads();
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to clear completed downloads',
        details: {'error': e.toString()},
      ));
    }
  }
}