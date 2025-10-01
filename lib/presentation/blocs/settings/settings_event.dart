import 'package:equatable/equatable.dart';

/// Base class for all settings events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all settings
class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

/// Event to update download settings
class UpdateDownloadSettingsEvent extends SettingsEvent {
  final String? defaultDownloadPath;
  final String? defaultQuality;
  final bool? wifiOnlyDownloads;
  final bool? allowMobileDataDownloads;
  final int? maxConcurrentDownloads;
  final bool? autoRetryFailedDownloads;
  final int? maxRetryAttempts;
  final bool? showDownloadNotifications;
  final bool? autoDeleteAfterDays;
  final int? deleteAfterDays;

  const UpdateDownloadSettingsEvent({
    this.defaultDownloadPath,
    this.defaultQuality,
    this.wifiOnlyDownloads,
    this.allowMobileDataDownloads,
    this.maxConcurrentDownloads,
    this.autoRetryFailedDownloads,
    this.maxRetryAttempts,
    this.showDownloadNotifications,
    this.autoDeleteAfterDays,
    this.deleteAfterDays,
  });

  @override
  List<Object?> get props => [
        defaultDownloadPath,
        defaultQuality,
        wifiOnlyDownloads,
        allowMobileDataDownloads,
        maxConcurrentDownloads,
        autoRetryFailedDownloads,
        maxRetryAttempts,
        showDownloadNotifications,
        autoDeleteAfterDays,
        deleteAfterDays,
      ];
}

/// Event to update video player settings
class UpdateVideoPlayerSettingsEvent extends SettingsEvent {
  final String? defaultVideoQuality;
  final bool? autoPlay;
  final bool? loopVideos;
  final double? playbackSpeed;
  final bool? showSubtitles;
  final String? subtitleLanguage;
  final double? subtitleSize;
  final String? subtitleColor;
  final bool? hardwareAcceleration;
  final bool? backgroundPlayback;

  const UpdateVideoPlayerSettingsEvent({
    this.defaultVideoQuality,
    this.autoPlay,
    this.loopVideos,
    this.playbackSpeed,
    this.showSubtitles,
    this.subtitleLanguage,
    this.subtitleSize,
    this.subtitleColor,
    this.hardwareAcceleration,
    this.backgroundPlayback,
  });

  @override
  List<Object?> get props => [
        defaultVideoQuality,
        autoPlay,
        loopVideos,
        playbackSpeed,
        showSubtitles,
        subtitleLanguage,
        subtitleSize,
        subtitleColor,
        hardwareAcceleration,
        backgroundPlayback,
      ];
}

/// Event to update app settings
class UpdateAppSettingsEvent extends SettingsEvent {
  final String? language;
  final bool? darkMode;
  final String? accentColor;
  final bool? showThumbnails;
  final bool? enableAnalytics;
  final bool? crashReporting;
  final bool? autoCheckUpdates;
  final bool? betaUpdates;
  final int? cacheSize;
  final bool? clearCacheOnExit;

  const UpdateAppSettingsEvent({
    this.language,
    this.darkMode,
    this.accentColor,
    this.showThumbnails,
    this.enableAnalytics,
    this.crashReporting,
    this.autoCheckUpdates,
    this.betaUpdates,
    this.cacheSize,
    this.clearCacheOnExit,
  });

  @override
  List<Object?> get props => [
        language,
        darkMode,
        accentColor,
        showThumbnails,
        enableAnalytics,
        crashReporting,
        autoCheckUpdates,
        betaUpdates,
        cacheSize,
        clearCacheOnExit,
      ];
}

/// Event to update privacy settings
class UpdatePrivacySettingsEvent extends SettingsEvent {
  final bool? saveSearchHistory;
  final bool? saveWatchHistory;
  final bool? allowCookies;
  final bool? sendUsageData;
  final bool? personalizedAds;
  final bool? locationAccess;
  final bool? cameraAccess;
  final bool? microphoneAccess;
  final bool? storageAccess;

  const UpdatePrivacySettingsEvent({
    this.saveSearchHistory,
    this.saveWatchHistory,
    this.allowCookies,
    this.sendUsageData,
    this.personalizedAds,
    this.locationAccess,
    this.cameraAccess,
    this.microphoneAccess,
    this.storageAccess,
  });

  @override
  List<Object?> get props => [
        saveSearchHistory,
        saveWatchHistory,
        allowCookies,
        sendUsageData,
        personalizedAds,
        locationAccess,
        cameraAccess,
        microphoneAccess,
        storageAccess,
      ];
}

/// Event to update network settings
class UpdateNetworkSettingsEvent extends SettingsEvent {
  final bool? useProxy;
  final String? proxyHost;
  final int? proxyPort;
  final String? proxyUsername;
  final String? proxyPassword;
  final int? connectionTimeout;
  final int? readTimeout;
  final int? maxRetries;
  final bool? enableIPv6;
  final String? userAgent;

  const UpdateNetworkSettingsEvent({
    this.useProxy,
    this.proxyHost,
    this.proxyPort,
    this.proxyUsername,
    this.proxyPassword,
    this.connectionTimeout,
    this.readTimeout,
    this.maxRetries,
    this.enableIPv6,
    this.userAgent,
  });

  @override
  List<Object?> get props => [
        useProxy,
        proxyHost,
        proxyPort,
        proxyUsername,
        proxyPassword,
        connectionTimeout,
        readTimeout,
        maxRetries,
        enableIPv6,
        userAgent,
      ];
}

/// Event to update security settings
class UpdateSecuritySettingsEvent extends SettingsEvent {
  final bool? requirePinForDownloads;
  final String? pinCode;
  final bool? biometricAuth;
  final bool? encryptDownloads;
  final String? encryptionKey;
  final bool? secureMode;
  final bool? preventScreenshots;
  final int? autoLockTimeout;

  const UpdateSecuritySettingsEvent({
    this.requirePinForDownloads,
    this.pinCode,
    this.biometricAuth,
    this.encryptDownloads,
    this.encryptionKey,
    this.secureMode,
    this.preventScreenshots,
    this.autoLockTimeout,
  });

  @override
  List<Object?> get props => [
        requirePinForDownloads,
        pinCode,
        biometricAuth,
        encryptDownloads,
        encryptionKey,
        secureMode,
        preventScreenshots,
        autoLockTimeout,
      ];
}

/// Event to reset settings to default
class ResetSettingsEvent extends SettingsEvent {
  final String category; // 'all', 'download', 'player', 'app', 'privacy', 'network', 'security'

  const ResetSettingsEvent({required this.category});

  @override
  List<Object?> get props => [category];
}

/// Event to export settings
class ExportSettingsEvent extends SettingsEvent {
  final String exportPath;

  const ExportSettingsEvent({required this.exportPath});

  @override
  List<Object?> get props => [exportPath];
}

/// Event to import settings
class ImportSettingsEvent extends SettingsEvent {
  final String importPath;

  const ImportSettingsEvent({required this.importPath});

  @override
  List<Object?> get props => [importPath];
}

/// Event to clear cache
class ClearCacheEvent extends SettingsEvent {
  final String cacheType; // 'all', 'video', 'search', 'thumbnails', 'downloads'

  const ClearCacheEvent({required this.cacheType});

  @override
  List<Object?> get props => [cacheType];
}

/// Event to clear history
class ClearHistoryEvent extends SettingsEvent {
  final String historyType; // 'all', 'search', 'watch', 'download'

  const ClearHistoryEvent({required this.historyType});

  @override
  List<Object?> get props => [historyType];
}

/// Event to backup data
class BackupDataEvent extends SettingsEvent {
  final String backupPath;
  final List<String> dataTypes; // 'settings', 'downloads', 'history', 'favorites'

  const BackupDataEvent({
    required this.backupPath,
    required this.dataTypes,
  });

  @override
  List<Object?> get props => [backupPath, dataTypes];
}

/// Event to restore data
class RestoreDataEvent extends SettingsEvent {
  final String backupPath;

  const RestoreDataEvent({required this.backupPath});

  @override
  List<Object?> get props => [backupPath];
}

/// Event to check for app updates
class CheckForUpdatesEvent extends SettingsEvent {
  const CheckForUpdatesEvent();
}

/// Event to download and install update
class DownloadUpdateEvent extends SettingsEvent {
  final String updateUrl;
  final String version;

  const DownloadUpdateEvent({
    required this.updateUrl,
    required this.version,
  });

  @override
  List<Object?> get props => [updateUrl, version];
}

/// Event to get app info
class GetAppInfoEvent extends SettingsEvent {
  const GetAppInfoEvent();
}

/// Event to get storage info
class GetStorageInfoEvent extends SettingsEvent {
  const GetStorageInfoEvent();
}

/// Event to get system info
class GetSystemInfoEvent extends SettingsEvent {
  const GetSystemInfoEvent();
}

/// Event to validate settings
class ValidateSettingsEvent extends SettingsEvent {
  const ValidateSettingsEvent();
}

/// Event to optimize app performance
class OptimizePerformanceEvent extends SettingsEvent {
  const OptimizePerformanceEvent();
}

/// Event to run diagnostics
class RunDiagnosticsEvent extends SettingsEvent {
  const RunDiagnosticsEvent();
}

/// Event to send feedback
class SendFeedbackEvent extends SettingsEvent {
  final String feedback;
  final String category;
  final bool includeLogs;

  const SendFeedbackEvent({
    required this.feedback,
    required this.category,
    this.includeLogs = false,
  });

  @override
  List<Object?> get props => [feedback, category, includeLogs];
}

/// Event to report bug
class ReportBugEvent extends SettingsEvent {
  final String description;
  final String stepsToReproduce;
  final bool includeLogs;
  final bool includeScreenshot;

  const ReportBugEvent({
    required this.description,
    required this.stepsToReproduce,
    this.includeLogs = true,
    this.includeScreenshot = false,
  });

  @override
  List<Object?> get props => [
        description,
        stepsToReproduce,
        includeLogs,
        includeScreenshot,
      ];
}

/// Event to reset settings state
class ResetSettingsStateEvent extends SettingsEvent {
  const ResetSettingsStateEvent();
}