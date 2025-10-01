import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';

/// Base class for all settings states
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when settings BLoC is first created
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// State when settings are loading
class SettingsLoading extends SettingsState {
  final String? message;

  const SettingsLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// State when all settings are loaded
class SettingsLoaded extends SettingsState {
  final Map<String, dynamic> downloadSettings;
  final Map<String, dynamic> videoPlayerSettings;
  final Map<String, dynamic> appSettings;
  final Map<String, dynamic> privacySettings;
  final Map<String, dynamic> networkSettings;
  final Map<String, dynamic> securitySettings;

  const SettingsLoaded({
    required this.downloadSettings,
    required this.videoPlayerSettings,
    required this.appSettings,
    required this.privacySettings,
    required this.networkSettings,
    required this.securitySettings,
  });

  @override
  List<Object?> get props => [
        downloadSettings,
        videoPlayerSettings,
        appSettings,
        privacySettings,
        networkSettings,
        securitySettings,
      ];

  SettingsLoaded copyWith({
    Map<String, dynamic>? downloadSettings,
    Map<String, dynamic>? videoPlayerSettings,
    Map<String, dynamic>? appSettings,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? networkSettings,
    Map<String, dynamic>? securitySettings,
  }) {
    return SettingsLoaded(
      downloadSettings: downloadSettings ?? this.downloadSettings,
      videoPlayerSettings: videoPlayerSettings ?? this.videoPlayerSettings,
      appSettings: appSettings ?? this.appSettings,
      privacySettings: privacySettings ?? this.privacySettings,
      networkSettings: networkSettings ?? this.networkSettings,
      securitySettings: securitySettings ?? this.securitySettings,
    );
  }
}

/// State when download settings are updated
class DownloadSettingsUpdated extends SettingsState {
  final Map<String, dynamic> settings;

  const DownloadSettingsUpdated({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// State when video player settings are updated
class VideoPlayerSettingsUpdated extends SettingsState {
  final Map<String, dynamic> settings;

  const VideoPlayerSettingsUpdated({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// State when app settings are updated
class AppSettingsUpdated extends SettingsState {
  final Map<String, dynamic> settings;

  const AppSettingsUpdated({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// State when privacy settings are updated
class PrivacySettingsUpdated extends SettingsState {
  final Map<String, dynamic> settings;

  const PrivacySettingsUpdated({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// State when network settings are updated
class NetworkSettingsUpdated extends SettingsState {
  final Map<String, dynamic> settings;

  const NetworkSettingsUpdated({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// State when security settings are updated
class SecuritySettingsUpdated extends SettingsState {
  final Map<String, dynamic> settings;

  const SecuritySettingsUpdated({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// State when settings are reset
class SettingsReset extends SettingsState {
  final String category;

  const SettingsReset({required this.category});

  @override
  List<Object?> get props => [category];
}

/// State when settings are exported
class SettingsExported extends SettingsState {
  final String exportPath;

  const SettingsExported({required this.exportPath});

  @override
  List<Object?> get props => [exportPath];
}

/// State when settings are imported
class SettingsImported extends SettingsState {
  final String importPath;
  final int importedCount;

  const SettingsImported({
    required this.importPath,
    required this.importedCount,
  });

  @override
  List<Object?> get props => [importPath, importedCount];
}

/// State when cache is cleared
class CacheCleared extends SettingsState {
  final String cacheType;
  final int clearedSize;

  const CacheCleared({
    required this.cacheType,
    required this.clearedSize,
  });

  @override
  List<Object?> get props => [cacheType, clearedSize];
}

/// State when history is cleared
class HistoryCleared extends SettingsState {
  final String historyType;
  final int clearedCount;

  const HistoryCleared({
    required this.historyType,
    required this.clearedCount,
  });

  @override
  List<Object?> get props => [historyType, clearedCount];
}

/// State when data is backed up
class DataBackedUp extends SettingsState {
  final String backupPath;
  final List<String> backedUpTypes;

  const DataBackedUp({
    required this.backupPath,
    required this.backedUpTypes,
  });

  @override
  List<Object?> get props => [backupPath, backedUpTypes];
}

/// State when data is restored
class DataRestored extends SettingsState {
  final String backupPath;
  final int restoredCount;

  const DataRestored({
    required this.backupPath,
    required this.restoredCount,
  });

  @override
  List<Object?> get props => [backupPath, restoredCount];
}

/// State when checking for updates
class CheckingForUpdates extends SettingsState {
  const CheckingForUpdates();
}

/// State when update is available
class UpdateAvailable extends SettingsState {
  final String currentVersion;
  final String latestVersion;
  final String updateUrl;
  final String releaseNotes;

  const UpdateAvailable({
    required this.currentVersion,
    required this.latestVersion,
    required this.updateUrl,
    required this.releaseNotes,
  });

  @override
  List<Object?> get props => [
        currentVersion,
        latestVersion,
        updateUrl,
        releaseNotes,
      ];
}

/// State when no update is available
class NoUpdateAvailable extends SettingsState {
  final String currentVersion;

  const NoUpdateAvailable({required this.currentVersion});

  @override
  List<Object?> get props => [currentVersion];
}

/// State when downloading update
class DownloadingUpdate extends SettingsState {
  final String version;
  final double progress;

  const DownloadingUpdate({
    required this.version,
    required this.progress,
  });

  @override
  List<Object?> get props => [version, progress];
}

/// State when update is downloaded
class UpdateDownloaded extends SettingsState {
  final String version;
  final String filePath;

  const UpdateDownloaded({
    required this.version,
    required this.filePath,
  });

  @override
  List<Object?> get props => [version, filePath];
}

/// State when app info is loaded
class AppInfoLoaded extends SettingsState {
  final String appName;
  final String version;
  final String buildNumber;
  final String packageName;
  final DateTime buildDate;
  final String platform;

  const AppInfoLoaded({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.packageName,
    required this.buildDate,
    required this.platform,
  });

  @override
  List<Object?> get props => [
        appName,
        version,
        buildNumber,
        packageName,
        buildDate,
        platform,
      ];
}

/// State when storage info is loaded
class StorageInfoLoaded extends SettingsState {
  final int totalSpace;
  final int freeSpace;
  final int usedSpace;
  final Map<String, int> usageByCategory;

  const StorageInfoLoaded({
    required this.totalSpace,
    required this.freeSpace,
    required this.usedSpace,
    required this.usageByCategory,
  });

  @override
  List<Object?> get props => [
        totalSpace,
        freeSpace,
        usedSpace,
        usageByCategory,
      ];
}

/// State when system info is loaded
class SystemInfoLoaded extends SettingsState {
  final String operatingSystem;
  final String deviceModel;
  final String architecture;
  final int totalMemory;
  final int availableMemory;
  final int processorCount;
  final String locale;
  final String timezone;

  const SystemInfoLoaded({
    required this.operatingSystem,
    required this.deviceModel,
    required this.architecture,
    required this.totalMemory,
    required this.availableMemory,
    required this.processorCount,
    required this.locale,
    required this.timezone,
  });

  @override
  List<Object?> get props => [
        operatingSystem,
        deviceModel,
        architecture,
        totalMemory,
        availableMemory,
        processorCount,
        locale,
        timezone,
      ];
}

/// State when settings are validated
class SettingsValidated extends SettingsState {
  final bool isValid;
  final List<String> validationErrors;

  const SettingsValidated({
    required this.isValid,
    required this.validationErrors,
  });

  @override
  List<Object?> get props => [isValid, validationErrors];
}

/// State when performance is optimized
class PerformanceOptimized extends SettingsState {
  final List<String> optimizations;

  const PerformanceOptimized({required this.optimizations});

  @override
  List<Object?> get props => [optimizations];
}

/// State when diagnostics are completed
class DiagnosticsCompleted extends SettingsState {
  final Map<String, dynamic> diagnosticResults;

  const DiagnosticsCompleted({required this.diagnosticResults});

  @override
  List<Object?> get props => [diagnosticResults];
}

/// State when feedback is sent
class FeedbackSent extends SettingsState {
  final String feedbackId;

  const FeedbackSent({required this.feedbackId});

  @override
  List<Object?> get props => [feedbackId];
}

/// State when bug report is sent
class BugReportSent extends SettingsState {
  final String reportId;

  const BugReportSent({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

/// State when an error occurs
class SettingsError extends SettingsState {
  final Failure failure;
  final String message;

  const SettingsError({
    required this.failure,
    required this.message,
  });

  @override
  List<Object?> get props => [failure, message];
}

/// State for handling multiple concurrent settings operations
class SettingsMultipleOperations extends SettingsState {
  final Map<String, SettingsState> operations;

  const SettingsMultipleOperations({required this.operations});

  @override
  List<Object?> get props => [operations];

  SettingsMultipleOperations copyWith({
    Map<String, SettingsState>? operations,
  }) {
    return SettingsMultipleOperations(
      operations: operations ?? this.operations,
    );
  }

  SettingsMultipleOperations addOperation(String key, SettingsState state) {
    final newOperations = Map<String, SettingsState>.from(operations);
    newOperations[key] = state;
    return copyWith(operations: newOperations);
  }

  SettingsMultipleOperations removeOperation(String key) {
    final newOperations = Map<String, SettingsState>.from(operations);
    newOperations.remove(key);
    return copyWith(operations: newOperations);
  }
}