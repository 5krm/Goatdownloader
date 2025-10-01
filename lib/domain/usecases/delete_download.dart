import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for deleting a download
class DeleteDownload extends UseCase<Result<bool>, DeleteDownloadParams> {
  final DownloadRepository repository;

  DeleteDownload(this.repository);

  @override
  Future<Result<bool>> call(DeleteDownloadParams params) async {
    if (params.downloadId.isEmpty) {
      return Error(ValidationFailure(message: 'Download ID cannot be empty'));
    }

    try {
      return await repository.deleteDownload(
        downloadId: params.downloadId,
        deleteFile: params.deleteFile,
      );
    } catch (e) {
      return Error(StorageFailure(
        message: 'Failed to delete download',
        details: {
          'error': e.toString(),
          'download_id': params.downloadId,
          'delete_file': params.deleteFile,
        },
      ));
    }
  }
}

/// Parameters for the DeleteDownload use case
class DeleteDownloadParams {
  final String downloadId;
  final bool deleteFile;

  const DeleteDownloadParams({
    required this.downloadId,
    this.deleteFile = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteDownloadParams &&
        other.downloadId == downloadId &&
        other.deleteFile == deleteFile;
  }

  @override
  int get hashCode => downloadId.hashCode ^ deleteFile.hashCode;

  @override
  String toString() {
    return 'DeleteDownloadParams(downloadId: $downloadId, deleteFile: $deleteFile)';
  }
}