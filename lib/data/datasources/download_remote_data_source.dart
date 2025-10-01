import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import '../models/download_model.dart';
import '../models/video_model.dart';
import '../../domain/entities/download.dart';
import '../../domain/entities/video.dart';
import '../../core/error/exceptions.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/network_info.dart';

/// Abstract interface for remote download operations
abstract class DownloadRemoteDataSource {
  /// Starts downloading a video
  Future<void> startDownload({
    required String downloadId,
    required VideoModel video,
    required VideoFormatModel format,
    required String savePath,
    required Function(double progress, int downloadedBytes, int totalBytes) onProgress,
    required Function(String error) onError,
    required Function() onComplete,
    CancelToken? cancelToken,
  });

  /// Pauses an active download
  Future<void> pauseDownload(String downloadId);

  /// Resumes a paused download
  Future<void> resumeDownload({
    required String downloadId,
    required VideoFormatModel format,
    required String savePath,
    required int resumeFrom,
    required Function(double progress, int downloadedBytes, int totalBytes) onProgress,
    required Function(String error) onError,
    required Function() onComplete,
    CancelToken? cancelToken,
  });

  /// Cancels an active download
  Future<void> cancelDownload(String downloadId);

  /// Gets download progress for a specific download
  Future<double> getDownloadProgress(String downloadId);

  /// Checks if URL supports resume
  Future<bool> supportsResume(String url);

  /// Gets file size from URL
  Future<int?> getRemoteFileSize(String url);

  /// Validates download URL
  Future<bool> validateDownloadUrl(String url);

  /// Downloads video thumbnail
  Future<Uint8List?> downloadThumbnail(String thumbnailUrl);

  /// Downloads video subtitles
  Future<String?> downloadSubtitles(String subtitleUrl, String savePath);

  /// Gets download speed for active downloads
  Future<double> getCurrentDownloadSpeed(String downloadId);

  /// Estimates remaining download time
  Future<Duration?> getEstimatedTimeRemaining(String downloadId);

  /// Retries failed download
  Future<void> retryDownload({
    required String downloadId,
    required VideoFormatModel format,
    required String savePath,
    required Function(double progress, int downloadedBytes, int totalBytes) onProgress,
    required Function(String error) onError,
    required Function() onComplete,
    CancelToken? cancelToken,
  });

  /// Checks network quality for download
  Future<NetworkQuality> checkNetworkQuality();

  /// Optimizes download based on network conditions
  Future<VideoFormatModel> optimizeFormatForNetwork(
    List<VideoFormatModel> formats,
    NetworkQuality networkQuality,
  );
}

/// Implementation of DownloadRemoteDataSource using Dio
class DownloadRemoteDataSourceImpl implements DownloadRemoteDataSource {
  final Dio dio;
  final NetworkInfo networkInfo;
  final Map<String, CancelToken> _activeCancelTokens = {};
  final Map<String, StreamSubscription> _activeDownloads = {};
  final Map<String, DownloadProgress> _downloadProgress = {};

  DownloadRemoteDataSourceImpl({
    required this.dio,
    required this.networkInfo,
  }) {
    _configureDio();
  }

  void _configureDio() {
    dio.options = BaseOptions(
      connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: AppConstants.sendTimeout),
      headers: {
        'User-Agent': '${AppConstants.appName}/${AppConstants.appVersion}',
      },
    );

    // Add interceptors for retry and logging
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );
  }

  @override
  Future<void> startDownload({
    required String downloadId,
    required VideoModel video,
    required VideoFormatModel format,
    required String savePath,
    required Function(double progress, int downloadedBytes, int totalBytes) onProgress,
    required Function(String error) onError,
    required Function() onComplete,
    CancelToken? cancelToken,
  }) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection available');
      }

      // Create cancel token if not provided
      final token = cancelToken ?? CancelToken();
      _activeCancelTokens[downloadId] = token;

      // Ensure directory exists
      final file = File(savePath);
      await file.parent.create(recursive: true);

      // Initialize progress tracking
      _downloadProgress[downloadId] = DownloadProgress(
        downloadId: downloadId,
        startTime: DateTime.now(),
        downloadedBytes: 0,
        totalBytes: format.fileSize ?? 0,
      );

      // Start download
      await _performDownload(
        downloadId: downloadId,
        url: format.url,
        savePath: savePath,
        onProgress: onProgress,
        onError: onError,
        onComplete: onComplete,
        cancelToken: token,
      );
    } catch (e) {
      _cleanupDownload(downloadId);
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Download was cancelled, don't report as error
        return;
      }
      onError('Failed to start download: $e');
    }
  }

  @override
  Future<void> pauseDownload(String downloadId) async {
    try {
      final cancelToken = _activeCancelTokens[downloadId];
      if (cancelToken != null && !cancelToken.isCancelled) {
        cancelToken.cancel('Download paused by user');
      }
      
      final subscription = _activeDownloads[downloadId];
      if (subscription != null) {
        await subscription.cancel();
        _activeDownloads.remove(downloadId);
      }
    } catch (e) {
      throw DownloadException(message: 'Failed to pause download: $e');
    }
  }

  @override
  Future<void> resumeDownload({
    required String downloadId,
    required VideoFormatModel format,
    required String savePath,
    required int resumeFrom,
    required Function(double progress, int downloadedBytes, int totalBytes) onProgress,
    required Function(String error) onError,
    required Function() onComplete,
    CancelToken? cancelToken,
  }) async {
    try {
      // Check if URL supports resume
      if (!await supportsResume(format.url)) {
        throw DownloadException(message: 'Server does not support resume for this file');
      }

      // Create new cancel token
      final token = cancelToken ?? CancelToken();
      _activeCancelTokens[downloadId] = token;

      // Update progress tracking
      final progress = _downloadProgress[downloadId];
      if (progress != null) {
        progress.downloadedBytes = resumeFrom;
        progress.startTime = DateTime.now();
      }

      // Resume download with range header
      await _performDownload(
        downloadId: downloadId,
        url: format.url,
        savePath: savePath,
        onProgress: onProgress,
        onError: onError,
        onComplete: onComplete,
        cancelToken: token,
        resumeFrom: resumeFrom,
      );
    } catch (e) {
      _cleanupDownload(downloadId);
      onError('Failed to resume download: $e');
    }
  }

  @override
  Future<void> cancelDownload(String downloadId) async {
    try {
      final cancelToken = _activeCancelTokens[downloadId];
      if (cancelToken != null && !cancelToken.isCancelled) {
        cancelToken.cancel('Download cancelled by user');
      }
      
      _activeCancelTokens.remove(downloadId);
    } catch (e) {
      throw DownloadException(message: 'Failed to cancel download: $e');
    }
  }

  @override
  Future<double> getDownloadProgress(String downloadId) async {
    final progress = _downloadProgress[downloadId];
    if (progress == null) return 0.0;
    
    if (progress.totalBytes <= 0) return 0.0;
    
    return (progress.downloadedBytes / progress.totalBytes).clamp(0.0, 1.0);
  }

  @override
  Future<bool> supportsResume(String url) async {
    try {
      final response = await dio.head(
        url,
        options: Options(
          headers: {'Range': 'bytes=0-1'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      return response.statusCode == 206 || 
             response.headers.value('accept-ranges')?.toLowerCase() == 'bytes';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int?> getRemoteFileSize(String url) async {
    try {
      final response = await dio.head(url);
      final contentLength = response.headers.value('content-length');
      return contentLength != null ? int.tryParse(contentLength) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> validateDownloadUrl(String url) async {
    try {
      final response = await dio.head(
        url,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      return response.statusCode == 200 || response.statusCode == 206;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Uint8List?> downloadThumbnail(String thumbnailUrl) async {
    try {
      final response = await dio.get<List<int>>(
        thumbnailUrl,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: Duration(seconds: 30),
        ),
      );
      
      return response.data != null ? Uint8List.fromList(response.data!) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> downloadSubtitles(String subtitleUrl, String savePath) async {
    try {
      final response = await dio.download(
        subtitleUrl,
        savePath,
        options: Options(
          receiveTimeout: Duration(seconds: 60),
        ),
      );
      
      return response.statusCode == 200 ? savePath : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<double> getCurrentDownloadSpeed(String downloadId) async {
    final progress = _downloadProgress[downloadId];
    if (progress == null) return 0.0;
    
    final elapsed = DateTime.now().difference(progress.startTime);
    if (elapsed.inSeconds <= 0) return 0.0;
    
    return progress.downloadedBytes / elapsed.inSeconds; // bytes per second
  }

  @override
  Future<Duration?> getEstimatedTimeRemaining(String downloadId) async {
    final progress = _downloadProgress[downloadId];
    if (progress == null || progress.totalBytes <= 0) return null;
    
    final speed = await getCurrentDownloadSpeed(downloadId);
    if (speed <= 0) return null;
    
    final remainingBytes = progress.totalBytes - progress.downloadedBytes;
    final remainingSeconds = remainingBytes / speed;
    
    return Duration(seconds: remainingSeconds.round());
  }

  @override
  Future<void> retryDownload({
    required String downloadId,
    required VideoFormatModel format,
    required String savePath,
    required Function(double progress, int downloadedBytes, int totalBytes) onProgress,
    required Function(String error) onError,
    required Function() onComplete,
    CancelToken? cancelToken,
  }) async {
    // Clean up any existing download state
    _cleanupDownload(downloadId);
    
    // Check if partial file exists for resume
    final file = File(savePath);
    int resumeFrom = 0;
    
    if (await file.exists()) {
      resumeFrom = await file.length();
      
      // If file is complete, just call onComplete
      if (format.fileSize != null && resumeFrom >= format.fileSize!) {
        onComplete();
        return;
      }
      
      // Try to resume if server supports it
      if (await supportsResume(format.url)) {
        await resumeDownload(
          downloadId: downloadId,
          format: format,
          savePath: savePath,
          resumeFrom: resumeFrom,
          onProgress: onProgress,
          onError: onError,
          onComplete: onComplete,
          cancelToken: cancelToken,
        );
        return;
      } else {
        // Delete partial file and start fresh
        await file.delete();
      }
    }
    
    // Start fresh download
    await startDownload(
      downloadId: downloadId,
      video: VideoModel(
        id: 'retry',
        title: 'Retry Download',
        description: '',
        thumbnailUrl: '',
        videoUrl: format.url,
        platform: 'unknown',
        duration: Duration.zero,
        uploader: '',
        viewCount: 0,
        availableFormats: [format],
        uploadDate: DateTime.now(),
        tags: [],
        category: VideoCategory.other,
        language: 'en',
        isLiveStream: false,
        isPrivate: false,
        hasSubtitles: false,
        ageRestricted: false,
        likes: 0,
        dislikes: 0,
      ),
      format: format,
      savePath: savePath,
      onProgress: onProgress,
      onError: onError,
      onComplete: onComplete,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<NetworkQuality> checkNetworkQuality() async {
    return await networkInfo.getNetworkQuality();
  }

  @override
  Future<VideoFormatModel> optimizeFormatForNetwork(
    List<VideoFormatModel> formats,
    NetworkQuality networkQuality,
  ) async {
    // Sort formats by quality (highest first)
    final sortedFormats = List<VideoFormatModel>.from(formats)
      ..sort((a, b) => (b.quality ?? '').compareTo(a.quality ?? ''));

    switch (networkQuality) {
      case NetworkQuality.excellent:
        // Return highest quality available
        return sortedFormats.first;
      
      case NetworkQuality.good:
        // Return medium-high quality (720p or lower)
        final goodFormat = sortedFormats.where((f) {
          final quality = f.quality?.toLowerCase() ?? '';
          return quality.contains('720') || 
                 quality.contains('480') || 
                 quality.contains('medium');
        }).firstOrNull;
        return goodFormat ?? sortedFormats.last;
      
      case NetworkQuality.fair:
        // Return medium quality (480p or lower)
        final fairFormat = sortedFormats.where((f) {
          final quality = f.quality?.toLowerCase() ?? '';
          return quality.contains('480') || 
                 quality.contains('360') || 
                 quality.contains('low');
        }).firstOrNull;
        return fairFormat ?? sortedFormats.last;
      
      case NetworkQuality.poor:
        // Return lowest quality available
        return sortedFormats.last;
    }
  }

  /// Performs the actual download operation
  Future<void> _performDownload({
    required String downloadId,
    required String url,
    required String savePath,
    required Function(double progress, int downloadedBytes, int totalBytes) onProgress,
    required Function(String error) onError,
    required Function() onComplete,
    required CancelToken cancelToken,
    int resumeFrom = 0,
  }) async {
    try {
      final file = File(savePath);
      RandomAccessFile? raf;
      
      try {
        // Open file for writing
        raf = await file.open(mode: FileMode.writeOnlyAppend);
        if (resumeFrom > 0) {
          await raf.setPosition(resumeFrom);
        }

        // Prepare headers for resume
        final headers = <String, dynamic>{};
        if (resumeFrom > 0) {
          headers['Range'] = 'bytes=$resumeFrom-';
        }

        // Start download with streaming
        final response = await dio.get<ResponseBody>(
          url,
          options: Options(
            responseType: ResponseType.stream,
            headers: headers,
            validateStatus: (status) {
              return status != null && (status == 200 || status == 206);
            },
          ),
          cancelToken: cancelToken,
        );

        final stream = response.data!.stream;
        final totalBytes = _getTotalBytes(response, resumeFrom);
        int downloadedBytes = resumeFrom;

        // Update progress tracking
        final progress = _downloadProgress[downloadId];
        if (progress != null) {
          progress.totalBytes = totalBytes;
          progress.downloadedBytes = downloadedBytes;
        }

        // Listen to stream and write to file
        final subscription = stream.listen(
          (chunk) async {
            try {
              await raf!.writeFrom(chunk);
              downloadedBytes += chunk.length;
              
              // Update progress tracking
              final progress = _downloadProgress[downloadId];
              if (progress != null) {
                progress.downloadedBytes = downloadedBytes;
              }
              
              // Calculate progress percentage
              final progressPercent = totalBytes > 0 
                  ? (downloadedBytes / totalBytes).clamp(0.0, 1.0)
                  : 0.0;
              
              // Call progress callback
              onProgress(progressPercent, downloadedBytes, totalBytes);
            } catch (e) {
              onError('Error writing to file: $e');
            }
          },
          onError: (error) {
            onError('Download stream error: $error');
          },
          onDone: () async {
            try {
              await raf?.flush();
              await raf?.close();
              raf = null;
              
              _cleanupDownload(downloadId);
              onComplete();
            } catch (e) {
              onError('Error completing download: $e');
            }
          },
          cancelOnError: true,
        );

        _activeDownloads[downloadId] = subscription;
        
      } finally {
        await raf?.close();
      }
      
    } catch (e) {
      _cleanupDownload(downloadId);
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Download was cancelled, don't report as error
        return;
      }
      onError('Download failed: $e');
    }
  }

  /// Gets total bytes from response headers
  int _getTotalBytes(Response<ResponseBody> response, int resumeFrom) {
    final contentLength = response.headers.value('content-length');
    if (contentLength != null) {
      final length = int.tryParse(contentLength) ?? 0;
      return resumeFrom + length;
    }
    
    final contentRange = response.headers.value('content-range');
    if (contentRange != null) {
      final match = RegExp(r'bytes \d+-\d+/(\d+)').firstMatch(contentRange);
      if (match != null) {
        return int.tryParse(match.group(1)!) ?? 0;
      }
    }
    
    return 0;
  }

  /// Cleans up download resources
  void _cleanupDownload(String downloadId) {
    _activeCancelTokens.remove(downloadId);
    _activeDownloads.remove(downloadId);
    _downloadProgress.remove(downloadId);
  }

  /// Disposes all resources
  void dispose() {
    for (final token in _activeCancelTokens.values) {
      if (!token.isCancelled) {
        token.cancel('Disposing download service');
      }
    }
    
    for (final subscription in _activeDownloads.values) {
      subscription.cancel();
    }
    
    _activeCancelTokens.clear();
    _activeDownloads.clear();
    _downloadProgress.clear();
  }
}

/// Helper class to track download progress
class DownloadProgress {
  final String downloadId;
  DateTime startTime;
  int downloadedBytes;
  int totalBytes;

  DownloadProgress({
    required this.downloadId,
    required this.startTime,
    required this.downloadedBytes,
    required this.totalBytes,
  });
}

/// Retry interceptor for Dio
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  final void Function(String message)? logPrint;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
    this.logPrint,
  });

  @override
  Future<Response> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 0;
    }

    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
    
    if (retryCount < retries && _shouldRetry(err)) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      
      final delay = retryDelays.length > retryCount 
          ? retryDelays[retryCount] 
          : retryDelays.last;
      
      logPrint?.call('Retrying request (${retryCount + 1}/$retries) after ${delay.inSeconds}s');
      
      await Future.delayed(delay);
      
      try {
        final response = await dio.fetch(err.requestOptions);
        return response;
      } catch (e) {
        if (e is DioException) {
          return onError(e, handler);
        }
        rethrow;
      }
    }
    
    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           (err.type == DioExceptionType.badResponse && 
            err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}

extension on Iterable<VideoFormatModel> {
  VideoFormatModel? get firstOrNull {
    return isEmpty ? null : first;
  }
}