/// Core application constants for GoatDownloader
/// 
/// This file contains all the constant values used throughout the application
/// including API endpoints, configuration values, and app-wide settings.
class AppConstants {
  // App Information
  static const String appName = 'GoatDownloader';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Professional Video Downloader';
  
  // Database Configuration
  static const String databaseName = 'goat_downloader.db';
  static const int databaseVersion = 1;
  
  // Hive Box Names
  static const String settingsBox = 'settings';
  static const String downloadsBox = 'downloads';
  static const String historyBox = 'history';
  static const String videoCacheBox = 'video_cache';
  static const String searchCacheBox = 'search_cache';
  static const String trendingCacheBox = 'trending_cache';
  static const String recentlyViewedBox = 'recently_viewed';
  static const String favoritesBox = 'favorites';
  static const String watchHistoryBox = 'watch_history';
  
  // Network Configuration
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 60000; // 60 seconds
  static const int sendTimeout = 30000; // 30 seconds
  static const int maxRetries = 3;
  
  // Download Configuration
  static const int maxConcurrentDownloads = 3;
  static const int chunkSize = 1024 * 1024; // 1MB chunks
  static const String defaultDownloadPath = '/storage/emulated/0/Download/GoatDownloader';
  
  // Video Quality Options
  static const List<String> videoQualities = [
    '144p',
    '240p',
    '360p',
    '480p',
    '720p',
    '1080p',
    '1440p',
    '2160p'
  ];
  
  // Supported Platforms
  static const List<String> supportedPlatforms = [
    'youtube.com',
    'youtu.be',
    'facebook.com',
    'fb.watch',
    'instagram.com',
    'tiktok.com',
    'twitter.com',
    'x.com',
    'dailymotion.com',
    'vimeo.com'
  ];
  
  // File Extensions
  static const List<String> videoExtensions = [
    'mp4',
    'avi',
    'mkv',
    'mov',
    'wmv',
    'flv',
    'webm',
    'm4v'
  ];
  
  static const List<String> audioExtensions = [
    'mp3',
    'aac',
    'wav',
    'flac',
    'ogg',
    'm4a'
  ];
  
  // Notification Configuration
  static const String downloadChannelId = 'download_channel';
  static const String downloadChannelName = 'Download Progress';
  static const String downloadChannelDescription = 'Shows download progress notifications';
  
  // Theme Configuration
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';
  static const String systemTheme = 'system';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String permissionError = 'Storage permission required';
  static const String unsupportedUrlError = 'URL not supported';
  
  // Success Messages
  static const String downloadStarted = 'Download started successfully';
  static const String downloadCompleted = 'Download completed';
  static const String downloadPaused = 'Download paused';
  static const String downloadResumed = 'Download resumed';
  static const String downloadCancelled = 'Download cancelled';
  
  // Regex Patterns
  static const String youtubeUrlPattern = r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})';
  static const String facebookUrlPattern = r'(?:https?:\/\/)?(?:www\.)?facebook\.com\/.*\/videos\/(\d+)';
  static const String instagramUrlPattern = r'(?:https?:\/\/)?(?:www\.)?instagram\.com\/(?:p|reel)\/([A-Za-z0-9_-]+)';
  static const String tiktokUrlPattern = r'(?:https?:\/\/)?(?:www\.)?tiktok\.com\/@[\w.-]+\/video\/(\d+)';
  
  // API Rate Limits
  static const int apiRateLimit = 100; // requests per minute
  static const Duration rateLimitWindow = Duration(minutes: 1);
  
  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int cacheExpirationHours = 24;
  static const int searchCacheExpirationMinutes = 30;
  static const int trendingCacheExpirationHours = 6;
  static const int maxRecentlyViewed = 50;
  
  // Security
  static const String encryptionKey = 'goat_downloader_encryption_key_2024';
  static const String saltKey = 'goat_downloader_salt_key_2024';
}

/// API endpoints for different video platforms
class ApiEndpoints {
  // YouTube Data API (requires API key)
  static const String youtubeApiBase = 'https://www.googleapis.com/youtube/v3';
  static const String youtubeVideoInfo = '$youtubeApiBase/videos';
  static const String youtubeSearch = '$youtubeApiBase/search';
  
  // Alternative endpoints for video extraction
  static const String ytDlpApi = 'https://api.yt-dlp.org';
  static const String invidious = 'https://invidious.io/api/v1';
  
  // Social media APIs (when available)
  static const String facebookGraphApi = 'https://graph.facebook.com/v18.0';
  static const String instagramBasicApi = 'https://graph.instagram.com';
  
  // Backup extraction services
  static const String extractorService1 = 'https://api.cobalt.tools';
  static const String extractorService2 = 'https://api.savefrom.net';
}

/// Storage paths and directory names
class StoragePaths {
  static const String videosFolder = 'Videos';
  static const String audioFolder = 'Audio';
  static const String thumbnailsFolder = 'Thumbnails';
  static const String tempFolder = 'Temp';
  static const String cacheFolder = 'Cache';
  
  // File naming patterns
  static const String videoFilePattern = '{title}_{quality}_{id}.{ext}';
  static const String audioFilePattern = '{title}_{bitrate}_{id}.{ext}';
  static const String thumbnailFilePattern = '{id}_thumbnail.jpg';
}