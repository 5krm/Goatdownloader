import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for getting all downloads
class GetAllDownloads extends UseCase<Result<List<Download>>, NoParams> {
  final DownloadRepository repository;

  GetAllDownloads(this.repository);

  @override
  Future<Result<List<Download>>> call(NoParams params) async {
    try {
      return await repository.getAllDownloads();
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to retrieve downloads',
        details: {'error': e.toString()},
      ));
    }
  }
}