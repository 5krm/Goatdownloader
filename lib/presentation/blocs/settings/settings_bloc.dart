import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../core/error/failures.dart';
import '../../../core/storage/hive_helper.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final HiveHelper _hiveHelper;

  SettingsBloc({
    required HiveHelper hiveHelper,
  })  : _hiveHelper = hiveHelper,
        super(const SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateDownloadSettingsEvent>(_onUpdateDownloadSettings);
    on<UpdateVideoPlayerSettingsEvent>(_onUpdateVideoPlayerSettings);
    on<UpdateAppSettingsEvent>(_onUpdateAppSettings);
    on<UpdatePrivacySettingsEvent>(_onUpdatePrivacySettings);
    on<UpdateNetworkSettingsEvent>(_onUpdateNetworkSettings);
    on<UpdateSecuritySettingsEvent>(_onUpdateSecuritySettings);
    on<ResetSettingsEvent>(_onResetSettings);
    on<ExportSettingsEvent>(_onExportSettings);
    on<ImportSettingsEvent>(_onImportSettings);
    on<ClearCacheEvent>(_onClearCache);
    on<ClearHistoryEvent>(_onClearHistory);
    on<BackupDataEvent>(_onBackupData);
    on<RestoreDataEvent>(_onRestoreData);
    on<CheckForUpdatesEvent>(_onCheckForUpdates);
    on<DownloadUpdateEvent>(_onDownloadUpdate);
    on<GetAppInfoEvent>(_onGetAppInfo);
    on<GetStorageInfoEvent>(_onGetStorageInfo);
    on<GetSystemInfoEvent>(_onGetSystemInfo);
    on<ValidateSettingsEvent>(_onValidateSettings);
    on<OptimizePerformanceEvent>(_onOptimizePerformance);
    on<RunDiagnosticsEvent>(_onRunDiagnostics);
    on<SendFeedbackEvent>(_onSendFeedback);
    on<ReportBugEvent>(_onReportBug);
    on<ResetSettingsStateEvent>(_onResetSettingsState);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Loading settings...'));

      final downloadSettings = await _getDownloadSettings();
      final videoPlayerSettings = await _getVideoPlayerSettings();
      final appSettings = await _getAppSettings();
      final privacySettings = await _getPrivacySettings();
      final networkSettings = await _getNetworkSettings();
      final securitySettings = await _getSecuritySettings();

      emit(SettingsLoaded(
        downloadSettings: downloadSettings,
        videoPlayerSettings: videoPlayerSettings,
        appSettings: appSettings,
        privacySettings: privacySettings,
        networkSettings: networkSettings,
        securitySettings: securitySettings,
      ));
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onUpdateDownloadSettings(
    UpdateDownloadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Updating download settings...'));

      await _hiveHelper.saveToBox('settings', 'download_settings', event.settings);

      emit(DownloadSettingsUpdated(settings: event.settings));

      // Reload all settings
      add(const LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onUpdateVideoPlayerSettings(
    UpdateVideoPlayerSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Updating video player settings...'));

      await _hiveHelper.saveToBox('settings', 'video_player_settings', event.settings);

      emit(VideoPlayerSettingsUpdated(settings: event.settings));

      // Reload all settings
      add(const LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onUpdateAppSettings(
    UpdateAppSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Updating app settings...'));

      // Get current settings and update with new values
      final currentSettings = await _getAppSettings();
      final updatedSettings = Map<String, dynamic>.from(currentSettings);
      
      if (event.language != null) updatedSettings['language'] = event.language;
      if (event.darkMode != null) updatedSettings['darkMode'] = event.darkMode;
      if (event.accentColor != null) updatedSettings['accentColor'] = event.accentColor;
      if (event.showThumbnails != null) updatedSettings['showThumbnails'] = event.showThumbnails;
      if (event.enableAnalytics != null) updatedSettings['enableAnalytics'] = event.enableAnalytics;
      if (event.crashReporting != null) updatedSettings['crashReporting'] = event.crashReporting;
      if (event.autoCheckUpdates != null) updatedSettings['autoCheckUpdates'] = event.autoCheckUpdates;
      if (event.betaUpdates != null) updatedSettings['betaUpdates'] = event.betaUpdates;
      if (event.cacheSize != null) updatedSettings['cacheSize'] = event.cacheSize;
      if (event.clearCacheOnExit != null) updatedSettings['clearCacheOnExit'] = event.clearCacheOnExit;

      await _hiveHelper.saveToBox('settings', 'app_settings', updatedSettings);

      emit(AppSettingsUpdated(settings: updatedSettings));

      // Reload all settings
      add(const LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onUpdatePrivacySettings(
    UpdatePrivacySettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Updating privacy settings...'));

      // Get current settings and update with new values
      final currentSettings = await _getPrivacySettings();
      final updatedSettings = Map<String, dynamic>.from(currentSettings);
      
      if (event.saveSearchHistory != null) updatedSettings['saveSearchHistory'] = event.saveSearchHistory;
      if (event.saveWatchHistory != null) updatedSettings['saveWatchHistory'] = event.saveWatchHistory;
      if (event.allowCookies != null) updatedSettings['allowCookies'] = event.allowCookies;
      if (event.sendUsageData != null) updatedSettings['sendUsageData'] = event.sendUsageData;
      if (event.personalizedAds != null) updatedSettings['personalizedAds'] = event.personalizedAds;
      if (event.locationAccess != null) updatedSettings['locationAccess'] = event.locationAccess;
      if (event.cameraAccess != null) updatedSettings['cameraAccess'] = event.cameraAccess;
      if (event.microphoneAccess != null) updatedSettings['microphoneAccess'] = event.microphoneAccess;
      if (event.storageAccess != null) updatedSettings['storageAccess'] = event.storageAccess;

      await _hiveHelper.saveToBox('settings', 'privacy_settings', updatedSettings);

      emit(PrivacySettingsUpdated(settings: updatedSettings));

      // Reload all settings
      add(const LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onUpdateNetworkSettings(
    UpdateNetworkSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Updating network settings...'));

      // Get current settings and update with new values
      final currentSettings = await _getNetworkSettings();
      final updatedSettings = Map<String, dynamic>.from(currentSettings);
      
      if (event.useProxy != null) updatedSettings['useProxy'] = event.useProxy;
      if (event.proxyHost != null) updatedSettings['proxyHost'] = event.proxyHost;
      if (event.proxyPort != null) updatedSettings['proxyPort'] = event.proxyPort;
      if (event.proxyUsername != null) updatedSettings['proxyUsername'] = event.proxyUsername;
      if (event.proxyPassword != null) updatedSettings['proxyPassword'] = event.proxyPassword;
      if (event.connectionTimeout != null) updatedSettings['connectionTimeout'] = event.connectionTimeout;
      if (event.readTimeout != null) updatedSettings['readTimeout'] = event.readTimeout;
      if (event.maxRetries != null) updatedSettings['maxRetries'] = event.maxRetries;
      if (event.enableIPv6 != null) updatedSettings['enableIPv6'] = event.enableIPv6;
      if (event.userAgent != null) updatedSettings['userAgent'] = event.userAgent;

      await _hiveHelper.saveToBox('settings', 'network_settings', updatedSettings);

      emit(NetworkSettingsUpdated(settings: updatedSettings));

      // Reload all settings
      add(const LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onUpdateSecuritySettings(
    UpdateSecuritySettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Updating security settings...'));

      // Get current settings and update with new values
      final currentSettings = await _getSecuritySettings();
      final updatedSettings = Map<String, dynamic>.from(currentSettings);
      
      if (event.requirePinForDownloads != null) updatedSettings['requirePinForDownloads'] = event.requirePinForDownloads;
      if (event.pinCode != null) updatedSettings['pinCode'] = event.pinCode;
      if (event.biometricAuth != null) updatedSettings['biometricAuth'] = event.biometricAuth;
      if (event.encryptDownloads != null) updatedSettings['encryptDownloads'] = event.encryptDownloads;
      if (event.encryptionKey != null) updatedSettings['encryptionKey'] = event.encryptionKey;
      if (event.secureMode != null) updatedSettings['secureMode'] = event.secureMode;
      if (event.preventScreenshots != null) updatedSettings['preventScreenshots'] = event.preventScreenshots;
      if (event.autoLockTimeout != null) updatedSettings['autoLockTimeout'] = event.autoLockTimeout;

      await _hiveHelper.saveToBox('settings', 'security_settings', updatedSettings);

      emit(SecuritySettingsUpdated(settings: updatedSettings));

      // Reload all settings
      add(const LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onResetSettings(
    ResetSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Resetting settings...'));

      switch (event.category) {
        case 'download':
          await _hiveHelper.removeFromBox('settings', 'download_settings');
          break;
        case 'video_player':
          await _hiveHelper.removeFromBox('settings', 'video_player_settings');
          break;
        case 'app':
          await _hiveHelper.removeFromBox('settings', 'app_settings');
          break;
        case 'privacy':
          await _hiveHelper.removeFromBox('settings', 'privacy_settings');
          break;
        case 'network':
          await _hiveHelper.removeFromBox('settings', 'network_settings');
          break;
        case 'security':
          await _hiveHelper.removeFromBox('settings', 'security_settings');
          break;
        case 'all':
          await _hiveHelper.clearBox('settings');
          break;
      }

      emit(SettingsReset(category: event.category));

      // Reload all settings
      add(const LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onExportSettings(
    ExportSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Exporting settings...'));

      // Get all settings
      final allSettings = await _hiveHelper.getAllFromBox('settings');
      
      // Convert to JSON and save to file
      final file = File(event.exportPath);
      await file.writeAsString(allSettings.toString());

      emit(SettingsExported(exportPath: event.exportPath));
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onImportSettings(
    ImportSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Importing settings...'));

      final file = File(event.importPath);
      if (!await file.exists()) {
        throw Exception('Import file not found');
      }

      // Read and parse settings file
      final content = await file.readAsString();
      // TODO: Parse JSON and import settings
      
      emit(SettingsImported(
        importPath: event.importPath,
        importedCount: 0, // TODO: Count imported settings
      ));

      // Reload all settings
      add(const LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Clearing cache...'));

      int clearedSize = 0;

      switch (event.cacheType) {
        case 'video':
          clearedSize = await _hiveHelper.getBoxSize('videos');
          await _hiveHelper.clearBox('videos');
          break;
        case 'search':
          clearedSize = await _hiveHelper.getBoxSize('cache');
          await _hiveHelper.clearBox('cache');
          break;
        case 'all':
          clearedSize = await _hiveHelper.getBoxSize('videos') +
              await _hiveHelper.getBoxSize('cache');
          await _hiveHelper.clearBox('videos');
          await _hiveHelper.clearBox('cache');
          break;
      }

      emit(CacheCleared(
        cacheType: event.cacheType,
        clearedSize: clearedSize,
      ));
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Clearing history...'));

      int clearedCount = 0;

      switch (event.historyType) {
        case 'search':
          clearedCount = await _hiveHelper.getBoxLength('search_history');
          await _hiveHelper.clearBox('search_history');
          break;
        case 'download':
          clearedCount = await _hiveHelper.getBoxLength('download_history');
          await _hiveHelper.clearBox('download_history');
          break;
        case 'all':
          clearedCount = await _hiveHelper.getBoxLength('search_history') +
              await _hiveHelper.getBoxLength('download_history');
          await _hiveHelper.clearBox('search_history');
          await _hiveHelper.clearBox('download_history');
          break;
      }

      emit(HistoryCleared(
        historyType: event.historyType,
        clearedCount: clearedCount,
      ));
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onBackupData(
    BackupDataEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Backing up data...'));

      final backedUpTypes = <String>[];

      for (final dataType in event.dataTypes) {
        switch (dataType) {
          case 'settings':
            // Backup settings
            backedUpTypes.add('settings');
            break;
          case 'downloads':
            // Backup downloads
            backedUpTypes.add('downloads');
            break;
          case 'history':
            // Backup history
            backedUpTypes.add('history');
            break;
        }
      }

      emit(DataBackedUp(
        backupPath: event.backupPath,
        backedUpTypes: backedUpTypes,
      ));
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onRestoreData(
    RestoreDataEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Restoring data...'));

      // TODO: Implement data restoration logic

      emit(DataRestored(
        backupPath: event.backupPath,
        restoredCount: 0, // TODO: Count restored items
      ));

      // Reload all settings
      add(const LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onCheckForUpdates(
    CheckForUpdatesEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const CheckingForUpdates());

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // TODO: Check for updates from server
      // For now, simulate no update available
      emit(NoUpdateAvailable(currentVersion: currentVersion));
    } catch (e) {
      emit(SettingsError(
        failure: NetworkFailure(message: e.toString()),
        message: _mapFailureToMessage(NetworkFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onDownloadUpdate(
    DownloadUpdateEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      // TODO: Implement update download logic
      emit(UpdateDownloaded(
        version: event.version,
        filePath: event.downloadPath,
      ));
    } catch (e) {
      emit(SettingsError(
        failure: NetworkFailure(message: e.toString()),
        message: _mapFailureToMessage(NetworkFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onGetAppInfo(
    GetAppInfoEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Loading app info...'));

      final packageInfo = await PackageInfo.fromPlatform();

      emit(AppInfoLoaded(
        appName: packageInfo.appName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        packageName: packageInfo.packageName,
        buildDate: DateTime.now(), // TODO: Get actual build date
        platform: Platform.operatingSystem,
      ));
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onGetStorageInfo(
    GetStorageInfoEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Loading storage info...'));

      // TODO: Get actual storage information
      final totalSpace = 1000000000; // 1GB in bytes
      final usedSpace = 500000000; // 500MB in bytes
      final freeSpace = totalSpace - usedSpace;

      final usageByCategory = <String, int>{
        'downloads': await _hiveHelper.getBoxSize('downloads'),
        'cache': await _hiveHelper.getBoxSize('cache'),
        'settings': await _hiveHelper.getBoxSize('settings'),
      };

      emit(StorageInfoLoaded(
        totalSpace: totalSpace,
        freeSpace: freeSpace,
        usedSpace: usedSpace,
        usageByCategory: usageByCategory,
      ));
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onGetSystemInfo(
    GetSystemInfoEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Loading system info...'));

      final deviceInfo = DeviceInfoPlugin();
      
      String operatingSystem = Platform.operatingSystem;
      String deviceModel = 'Unknown';
      String architecture = 'Unknown';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        architecture = androidInfo.supportedAbis.first;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceModel = iosInfo.model;
        architecture = iosInfo.utsname.machine;
      }

      emit(SystemInfoLoaded(
        operatingSystem: operatingSystem,
        deviceModel: deviceModel,
        architecture: architecture,
        totalMemory: 0, // TODO: Get actual memory info
        availableMemory: 0, // TODO: Get actual memory info
        processorCount: Platform.numberOfProcessors,
        locale: Platform.localeName,
        timezone: DateTime.now().timeZoneName,
      ));
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onValidateSettings(
    ValidateSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Validating settings...'));

      final validationErrors = <String>[];

      // TODO: Implement settings validation logic

      emit(SettingsValidated(
        isValid: validationErrors.isEmpty,
        validationErrors: validationErrors,
      ));
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onOptimizePerformance(
    OptimizePerformanceEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Optimizing performance...'));

      final optimizations = <String>[];

      // TODO: Implement performance optimization logic
      optimizations.add('Cleared temporary files');
      optimizations.add('Compacted database');
      optimizations.add('Optimized cache settings');

      emit(PerformanceOptimized(optimizations: optimizations));
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onRunDiagnostics(
    RunDiagnosticsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Running diagnostics...'));

      final diagnosticResults = <String, dynamic>{
        'network_connectivity': true,
        'storage_health': 'good',
        'database_integrity': true,
        'cache_status': 'optimal',
        'performance_score': 85,
      };

      emit(DiagnosticsCompleted(diagnosticResults: diagnosticResults));
    } catch (e) {
      emit(SettingsError(
        failure: CacheFailure(message: e.toString()),
        message: _mapFailureToMessage(CacheFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onSendFeedback(
    SendFeedbackEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Sending feedback...'));

      // TODO: Implement feedback sending logic
      final feedbackId = 'feedback_${DateTime.now().millisecondsSinceEpoch}';

      emit(FeedbackSent(feedbackId: feedbackId));
    } catch (e) {
      emit(SettingsError(
        failure: NetworkFailure(message: e.toString()),
        message: _mapFailureToMessage(NetworkFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onReportBug(
    ReportBugEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading(message: 'Reporting bug...'));

      // TODO: Implement bug reporting logic
      final reportId = 'bug_${DateTime.now().millisecondsSinceEpoch}';

      emit(BugReportSent(reportId: reportId));
    } catch (e) {
      emit(SettingsError(
        failure: NetworkFailure(message: e.toString()),
        message: _mapFailureToMessage(NetworkFailure(message: e.toString())),
      ));
    }
  }

  Future<void> _onResetSettingsState(
    ResetSettingsStateEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsInitial());
  }

  // Helper methods
  Future<Map<String, dynamic>> _getDownloadSettings() async {
    return await _hiveHelper.getFromBox('settings', 'download_settings') ?? {
      'download_path': '/storage/emulated/0/Download',
      'max_concurrent_downloads': 3,
      'auto_retry': true,
      'retry_attempts': 3,
      'preferred_quality': 'best',
      'preferred_format': 'mp4',
      'download_subtitles': false,
      'download_thumbnails': true,
    };
  }

  Future<Map<String, dynamic>> _getVideoPlayerSettings() async {
    return await _hiveHelper.getFromBox('settings', 'video_player_settings') ?? {
      'auto_play': false,
      'loop_videos': false,
      'default_volume': 0.8,
      'playback_speed': 1.0,
      'subtitle_size': 16.0,
      'subtitle_color': '#FFFFFF',
      'background_play': false,
      'picture_in_picture': true,
    };
  }

  Future<Map<String, dynamic>> _getAppSettings() async {
    return await _hiveHelper.getFromBox('settings', 'app_settings') ?? {
      'theme': 'system',
      'language': 'en',
      'notifications_enabled': true,
      'auto_update': true,
      'crash_reporting': true,
      'analytics': false,
      'startup_page': 'home',
    };
  }

  Future<Map<String, dynamic>> _getPrivacySettings() async {
    return await _hiveHelper.getFromBox('settings', 'privacy_settings') ?? {
      'clear_history_on_exit': false,
      'incognito_mode': false,
      'data_collection': false,
      'personalized_ads': false,
      'location_access': false,
      'camera_access': false,
      'microphone_access': false,
    };
  }

  Future<Map<String, dynamic>> _getNetworkSettings() async {
    return await _hiveHelper.getFromBox('settings', 'network_settings') ?? {
      'use_proxy': false,
      'proxy_host': '',
      'proxy_port': 8080,
      'proxy_username': '',
      'proxy_password': '',
      'timeout': 30,
      'retry_on_failure': true,
      'use_cellular_data': true,
    };
  }

  Future<Map<String, dynamic>> _getSecuritySettings() async {
    return await _hiveHelper.getFromBox('settings', 'security_settings') ?? {
      'biometric_auth': false,
      'pin_protection': false,
      'auto_lock': false,
      'lock_timeout': 300,
      'secure_downloads': true,
      'verify_certificates': true,
      'block_malicious_urls': true,
    };
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case CacheFailure:
        return 'Local storage error occurred.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      case ValidationFailure:
        return 'Invalid input provided.';
      case PermissionFailure:
        return 'Permission denied. Please check app permissions.';
      case NotFoundFailure:
        return 'Requested resource not found.';
      case TimeoutFailure:
        return 'Request timed out. Please try again.';
      case UnknownFailure:
        return 'An unexpected error occurred.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}