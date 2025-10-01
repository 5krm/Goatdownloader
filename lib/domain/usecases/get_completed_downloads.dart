import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for getting completed downloads
class GetCompletedDownloads extends UseCase<Result<List<Download>>, NoParams> {
  final DownloadRepository repository;

  GetCompletedDownloads(this.repository);

  @override
  Future<Result<List<Download>>> call(NoParams params) async {
    try {
      return await repository.getCompletedDownloads();
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to retrieve completed downloads',
        details: {'error': e.toString()},
      ));
    }
  }
}