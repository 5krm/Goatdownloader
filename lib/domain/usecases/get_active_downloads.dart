import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for getting active downloads
class GetActiveDownloads extends UseCase<Result<List<Download>>, NoParams> {
  final DownloadRepository repository;

  GetActiveDownloads(this.repository);

  @override
  Future<Result<List<Download>>> call(NoParams params) async {
    try {
      return await repository.getActiveDownloads();
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to retrieve active downloads',
        details: {'error': e.toString()},
      ));
    }
  }
}