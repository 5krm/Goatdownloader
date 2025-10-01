import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Core
import '../database/database_helper.dart';
import '../storage/hive_helper.dart';
import '../network/network_info.dart';

// Data sources
import '../../data/datasources/video_remote_data_source.dart';
import '../../data/datasources/video_local_data_source.dart';
import '../../data/datasources/download_remote_data_source.dart';
import '../../data/datasources/download_local_data_source.dart';

// Repositories
import '../../domain/repositories/video_repository.dart';
import '../../domain/repositories/download_repository.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../data/repositories/download_repository_impl.dart';

// Use cases - Video
import '../../domain/usecases/get_video_info.dart';
import '../../domain/usecases/search_videos.dart'; // Contains SearchVideos, GetTrendingVideos, ValidateVideoUrl
import '../../domain/usecases/download_video.dart'; // Contains all download-related use cases

// BLoCs
import '../../presentation/blocs/video/video_bloc.dart';
import '../../presentation/blocs/search/search_bloc.dart';
import '../../presentation/blocs/download/download_bloc.dart';
import '../../presentation/blocs/settings/settings_bloc.dart';
import '../../presentation/blocs/theme/theme_bloc.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initializes all dependencies
Future<void> init() async {
  //! Features - Video
  _initVideoFeature();

  //! Features - Download
  _initDownloadFeature();

  //! Features - Search
  _initSearchFeature();

  //! Features - Settings
  _initSettingsFeature();

  //! Features - Theme
  _initThemeFeature();

  //! Core
  await _initCore();

  //! External
  await _initExternal();
}

/// Initializes video feature dependencies
void _initVideoFeature() {
  // BLoC
  sl.registerFactory(
    () => VideoBloc(
      getVideoInfo: sl(),
      validateVideoUrl: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetVideoInfo(sl()));

  // Repository
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Register data sources
  sl.registerLazySingleton<VideoRemoteDataSource>(
    () => VideoRemoteDataSourceImpl(
      dio: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<VideoLocalDataSource>(
    () => VideoLocalDataSourceImpl(
      database: sl(),
    ),
  );
}

/// Initializes download feature dependencies
void _initDownloadFeature() {
  // BLoC
  sl.registerFactory(
    () => DownloadBloc(
      startDownload: sl(),
      pauseDownload: sl(),
      resumeDownload: sl(),
      cancelDownload: sl(),
      retryDownload: sl(),
      getAllDownloads: sl(),
      getActiveDownloads: sl(),
      getCompletedDownloads: sl(),
      getDownloadById: sl(),
      deleteDownload: sl(),
      watchDownloadProgress: sl(),
      updateDownloadMetadata: sl(),
      getDownloadStatistics: sl(),
      clearCompletedDownloads: sl(),
      setMaxConcurrentDownloads: sl(),
      getDownloadQueue: sl(),
      reorderDownloadQueue: sl(),
      hiveHelper: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => DownloadVideo(sl()));
  sl.registerLazySingleton(() => PauseDownload(sl()));
  sl.registerLazySingleton(() => ResumeDownload(sl()));
  sl.registerLazySingleton(() => CancelDownload(sl()));
  sl.registerLazySingleton(() => RetryDownload(sl()));
  sl.registerLazySingleton(() => GetAllDownloads(sl()));
  sl.registerLazySingleton(() => GetActiveDownloads(sl()));
  sl.registerLazySingleton(() => GetCompletedDownloads(sl()));
  sl.registerLazySingleton(() => DeleteDownload(sl()));

  // Repository
  sl.registerLazySingleton<DownloadRepository>(
    () => DownloadRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<DownloadRemoteDataSource>(
    () => DownloadRemoteDataSourceImpl(
      dio: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<DownloadLocalDataSource>(
    () => DownloadLocalDataSourceImpl(
      database: sl(),
    ),
  );
}

/// Initializes search feature dependencies
void _initSearchFeature() {
  // BLoC
  sl.registerFactory(
    () => SearchBloc(
      searchVideos: sl(),
      getTrendingVideos: sl<GetTrendingVideos>(),
      hiveHelper: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SearchVideos(sl()));
  sl.registerLazySingleton(() => GetTrendingVideos(sl()));
  sl.registerLazySingleton(() => ValidateVideoUrl(sl()));
}

/// Initializes settings feature dependencies
void _initSettingsFeature() {
  // BLoC
  sl.registerFactory(
    () => SettingsBloc(
      hiveHelper: sl(),
    ),
  );
}

/// Initializes theme feature dependencies
void _initThemeFeature() {
  // BLoC
  sl.registerFactory(
    () => ThemeBloc(
      hiveHelper: sl(),
    ),
  );
}

/// Initializes core dependencies
Future<void> _initCore() async {
  // Database
  sl.registerLazySingleton(() => DatabaseHelper());

  // Hive storage
  final hiveHelper = HiveHelper();
  await hiveHelper.init();
  sl.registerLazySingleton(() => hiveHelper);

  // Network info
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );
}

/// Initializes external dependencies
Future<void> _initExternal() async {
  // Dio
  sl.registerLazySingleton(() => Dio());

  // Connectivity
  sl.registerLazySingleton(() => Connectivity());
}

/// Resets all dependencies (useful for testing)
Future<void> reset() async {
  await sl.reset();
}

/// Registers a factory dependency
void registerFactory<T extends Object>(T Function() factoryFunc) {
  sl.registerFactory<T>(factoryFunc);
}

/// Registers a lazy singleton dependency
void registerLazySingleton<T extends Object>(T Function() factoryFunc) {
  sl.registerLazySingleton<T>(factoryFunc);
}

/// Registers a singleton dependency
void registerSingleton<T extends Object>(T instance) {
  sl.registerSingleton<T>(instance);
}

/// Gets a dependency
T get<T extends Object>() {
  return sl.get<T>();
}

/// Checks if a dependency is registered
bool isRegistered<T extends Object>() {
  return sl.isRegistered<T>();
}

/// Unregisters a dependency
Future<void> unregister<T extends Object>() async {
  if (isRegistered<T>()) {
    await sl.unregister<T>();
  }
}

/// Gets all registered dependencies info
Map<String, String> getRegisteredDependencies() {
  final dependencies = <String, String>{};
  
  // Core dependencies
  dependencies['DatabaseHelper'] = isRegistered<DatabaseHelper>() ? 'Registered' : 'Not Registered';
  dependencies['HiveHelper'] = isRegistered<HiveHelper>() ? 'Registered' : 'Not Registered';
  dependencies['NetworkInfo'] = isRegistered<NetworkInfo>() ? 'Registered' : 'Not Registered';
  dependencies['Dio'] = isRegistered<Dio>() ? 'Registered' : 'Not Registered';
  dependencies['Connectivity'] = isRegistered<Connectivity>() ? 'Registered' : 'Not Registered';

  // Data sources
  dependencies['VideoRemoteDataSource'] = isRegistered<VideoRemoteDataSource>() ? 'Registered' : 'Not Registered';
  dependencies['VideoLocalDataSource'] = isRegistered<VideoLocalDataSource>() ? 'Registered' : 'Not Registered';
  dependencies['DownloadRemoteDataSource'] = isRegistered<DownloadRemoteDataSource>() ? 'Registered' : 'Not Registered';
  dependencies['DownloadLocalDataSource'] = isRegistered<DownloadLocalDataSource>() ? 'Registered' : 'Not Registered';

  // Repositories
  dependencies['VideoRepository'] = isRegistered<VideoRepository>() ? 'Registered' : 'Not Registered';
  dependencies['DownloadRepository'] = isRegistered<DownloadRepository>() ? 'Registered' : 'Not Registered';

  // Use cases
  dependencies['GetVideoInfo'] = isRegistered<GetVideoInfo>() ? 'Registered' : 'Not Registered';
  dependencies['ValidateVideoUrl'] = isRegistered<ValidateVideoUrl>() ? 'Registered' : 'Not Registered';
  dependencies['SearchVideos'] = isRegistered<SearchVideos>() ? 'Registered' : 'Not Registered';
  dependencies['GetTrendingVideos'] = isRegistered<GetTrendingVideos>() ? 'Registered' : 'Not Registered';
  dependencies['DownloadVideo'] = isRegistered<DownloadVideo>() ? 'Registered' : 'Not Registered';
  dependencies['PauseDownload'] = isRegistered<PauseDownload>() ? 'Registered' : 'Not Registered';
  dependencies['ResumeDownload'] = isRegistered<ResumeDownload>() ? 'Registered' : 'Not Registered';
  dependencies['CancelDownload'] = isRegistered<CancelDownload>() ? 'Registered' : 'Not Registered';
  dependencies['RetryDownload'] = isRegistered<RetryDownload>() ? 'Registered' : 'Not Registered';
  dependencies['GetAllDownloads'] = isRegistered<GetAllDownloads>() ? 'Registered' : 'Not Registered';
  dependencies['GetActiveDownloads'] = isRegistered<GetActiveDownloads>() ? 'Registered' : 'Not Registered';
  dependencies['GetCompletedDownloads'] = isRegistered<GetCompletedDownloads>() ? 'Registered' : 'Not Registered';
  dependencies['DeleteDownload'] = isRegistered<DeleteDownload>() ? 'Registered' : 'Not Registered';

  return dependencies;
}

/// Initializes dependencies for testing
Future<void> initForTesting() async {
  // Reset existing dependencies
  await reset();

  // Initialize core dependencies for testing
  await _initCore();
  await _initExternal();

  // Initialize feature dependencies
  _initVideoFeature();
  _initDownloadFeature();
  _initSearchFeature();
  _initSettingsFeature();
  _initThemeFeature();
}

/// Disposes all resources
Future<void> dispose() async {
  try {
    // Close database
    if (isRegistered<DatabaseHelper>()) {
      await get<DatabaseHelper>().close();
    }

    // Close Hive
    if (isRegistered<HiveHelper>()) {
      await get<HiveHelper>().close();
    }



    // Reset service locator
    await reset();
  } catch (e) {
    // Log error but don't throw to prevent app crashes during disposal
    print('Error disposing dependencies: $e');
  }
}

/// Health check for all dependencies
Map<String, bool> healthCheck() {
  final health = <String, bool>{};

  try {
    // Check core dependencies
    health['DatabaseHelper'] = isRegistered<DatabaseHelper>();
    health['HiveHelper'] = isRegistered<HiveHelper>();
    health['NetworkInfo'] = isRegistered<NetworkInfo>();

    // Check data sources
    health['VideoRemoteDataSource'] = isRegistered<VideoRemoteDataSource>();
    health['VideoLocalDataSource'] = isRegistered<VideoLocalDataSource>();
    health['DownloadRemoteDataSource'] = isRegistered<DownloadRemoteDataSource>();
    health['DownloadLocalDataSource'] = isRegistered<DownloadLocalDataSource>();

    // Check repositories
    health['VideoRepository'] = isRegistered<VideoRepository>();
    health['DownloadRepository'] = isRegistered<DownloadRepository>();

    // Check use cases
    health['GetVideoInfo'] = isRegistered<GetVideoInfo>();
    health['SearchVideos'] = isRegistered<SearchVideos>();
    health['DownloadVideo'] = isRegistered<DownloadVideo>();

    // Check external dependencies
    health['Dio'] = isRegistered<Dio>();
    health['Connectivity'] = isRegistered<Connectivity>();

    return health;
  } catch (e) {
    return {'error': false};
  }
}