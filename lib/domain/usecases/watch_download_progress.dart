import 'dart:async';
import '../entities/download.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

/// Use case for watching download progress
class WatchDownloadProgress extends UseCase<Stream<Result<Download>>, String> {
  final DownloadRepository repository;

  WatchDownloadProgress(this.repository);

  @override
  Future<Stream<Result<Download>>> call(String downloadId) async {
    if (downloadId.isEmpty) {
      return Stream.value(Error(ValidationFailure(message: 'Download ID cannot be empty')));
    }

    try {
      return repository.watchDownloadProgress(downloadId);
    } catch (e) {
      return Stream.value(Error(StorageFailure(
        message: 'Failed to watch download progress',
        details: {'error': e.toString(), 'download_id': downloadId},
      )));
    }
  }
}