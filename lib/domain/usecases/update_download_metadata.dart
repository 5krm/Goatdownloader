import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for updating download metadata
class UpdateDownloadMetadata extends UseCase<Result<Download>, UpdateDownloadMetadataParams> {
  final DownloadRepository repository;

  UpdateDownloadMetadata(this.repository);

  @override
  Future<Result<Download>> call(UpdateDownloadMetadataParams params) async {
    if (params.downloadId.isEmpty) {
      return Error(ValidationFailure(message: 'Download ID cannot be empty'));
    }

    try {
      return await repository.updateDownloadMetadata(
        downloadId: params.downloadId,
        metadata: params.metadata,
      );
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to update download metadata',
        details: {
          'error': e.toString(),
          'download_id': params.downloadId,
        },
      ));
    }
  }
}

/// Parameters for the UpdateDownloadMetadata use case
class UpdateDownloadMetadataParams {
  final String downloadId;
  final Map<String, dynamic> metadata;

  const UpdateDownloadMetadataParams({
    required this.downloadId,
    required this.metadata,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateDownloadMetadataParams &&
        other.downloadId == downloadId &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => downloadId.hashCode ^ metadata.hashCode;

  @override
  String toString() {
    return 'UpdateDownloadMetadataParams(downloadId: $downloadId, metadata: $metadata)';
  }
}