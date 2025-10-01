import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for reordering the download queue
class ReorderDownloadQueue extends UseCase<Result<List<Download>>, ReorderDownloadQueueParams> {
  final DownloadRepository repository;

  ReorderDownloadQueue(this.repository);

  @override
  Future<Result<List<Download>>> call(ReorderDownloadQueueParams params) async {
    if (params.downloadIds.isEmpty) {
      return Error(ValidationFailure(message: 'Download IDs list cannot be empty'));
    }

    try {
      return await repository.reorderDownloadQueue(params.downloadIds);
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to reorder download queue',
        details: {
          'error': e.toString(),
          'download_ids': params.downloadIds,
        },
      ));
    }
  }
}

/// Parameters for the ReorderDownloadQueue use case
class ReorderDownloadQueueParams {
  final List<String> downloadIds;

  const ReorderDownloadQueueParams({
    required this.downloadIds,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReorderDownloadQueueParams &&
        other.downloadIds == downloadIds;
  }

  @override
  int get hashCode => downloadIds.hashCode;

  @override
  String toString() {
    return 'ReorderDownloadQueueParams(downloadIds: $downloadIds)';
  }
}