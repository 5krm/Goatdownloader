import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/download_model.dart';

/// Use case for getting download statistics
class GetDownloadStatistics extends UseCase<Result<DownloadStatsModel>, NoParams> {
  final DownloadRepository repository;

  GetDownloadStatistics(this.repository);

  @override
  Future<Result<DownloadStatsModel>> call(NoParams params) async {
    try {
      return await repository.getDownloadStatistics();
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to retrieve download statistics',
        details: {'error': e.toString()},
      ));
    }
  }
}