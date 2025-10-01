import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for setting maximum concurrent downloads
class SetMaxConcurrentDownloads extends UseCase<Result<bool>, SetMaxConcurrentDownloadsParams> {
  final DownloadRepository repository;

  SetMaxConcurrentDownloads(this.repository);

  @override
  Future<Result<bool>> call(SetMaxConcurrentDownloadsParams params) async {
    if (params.maxConcurrentDownloads <= 0) {
      return Error(ValidationFailure(message: 'Maximum concurrent downloads must be greater than 0'));
    }

    if (params.maxConcurrentDownloads > 10) {
      return Error(ValidationFailure(message: 'Maximum concurrent downloads cannot exceed 10'));
    }

    try {
      return await repository.setMaxConcurrentDownloads(params.maxConcurrentDownloads);
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to set maximum concurrent downloads',
        details: {
          'error': e.toString(),
          'max_concurrent_downloads': params.maxConcurrentDownloads,
        },
      ));
    }
  }
}

/// Parameters for the SetMaxConcurrentDownloads use case
class SetMaxConcurrentDownloadsParams {
  final int maxConcurrentDownloads;

  const SetMaxConcurrentDownloadsParams({
    required this.maxConcurrentDownloads,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SetMaxConcurrentDownloadsParams &&
        other.maxConcurrentDownloads == maxConcurrentDownloads;
  }

  @override
  int get hashCode => maxConcurrentDownloads.hashCode;

  @override
  String toString() {
    return 'SetMaxConcurrentDownloadsParams(maxConcurrentDownloads: $maxConcurrentDownloads)';
  }
}