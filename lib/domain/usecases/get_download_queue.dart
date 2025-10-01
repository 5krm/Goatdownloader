import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for getting the download queue
class GetDownloadQueue extends UseCase<Result<List<Download>>, NoParams> {
  final DownloadRepository repository;

  GetDownloadQueue(this.repository);

  @override
  Future<Result<List<Download>>> call(NoParams params) async {
    try {
      return await repository.getDownloadQueue();
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to retrieve download queue',
        details: {'error': e.toString()},
      ));
    }
  }
}