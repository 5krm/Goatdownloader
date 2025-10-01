import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for network connectivity checking
/// 
/// This abstraction allows for easy testing and mocking
/// of network connectivity functionality.
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<ConnectivityResult> get connectivityStream;
  Future<ConnectivityResult> get connectivityResult;
}

/// Concrete implementation of NetworkInfo using connectivity_plus package
/// 
/// This class provides real network connectivity information
/// and can detect changes in network status.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Stream<ConnectivityResult> get connectivityStream {
    return connectivity.onConnectivityChanged;
  }

  @override
  Future<ConnectivityResult> get connectivityResult {
    return connectivity.checkConnectivity();
  }
}

/// Network connection types for better handling
enum NetworkType {
  wifi,
  mobile,
  ethernet,
  bluetooth,
  vpn,
  none,
  other,
}

/// Extension to convert ConnectivityResult to NetworkType
extension ConnectivityResultExtension on ConnectivityResult {
  NetworkType get networkType {
    switch (this) {
      case ConnectivityResult.wifi:
        return NetworkType.wifi;
      case ConnectivityResult.mobile:
        return NetworkType.mobile;
      case ConnectivityResult.ethernet:
        return NetworkType.ethernet;
      case ConnectivityResult.bluetooth:
        return NetworkType.bluetooth;
      case ConnectivityResult.vpn:
        return NetworkType.vpn;
      case ConnectivityResult.none:
        return NetworkType.none;
      case ConnectivityResult.other:
        return NetworkType.other;
    }
  }

  bool get isConnected => this != ConnectivityResult.none;
  
  bool get isWifi => this == ConnectivityResult.wifi;
  
  bool get isMobile => this == ConnectivityResult.mobile;
  
  bool get isHighSpeed => isWifi || this == ConnectivityResult.ethernet;
}

/// Network quality assessment
class NetworkQuality {
  final NetworkType type;
  final bool isHighSpeed;
  final bool isMetered;
  final DateTime timestamp;

  const NetworkQuality({
    required this.type,
    required this.isHighSpeed,
    required this.isMetered,
    required this.timestamp,
  });

  /// Determines if the network is suitable for video downloads
  bool get isSuitableForDownload {
    return type != NetworkType.none && 
           (isHighSpeed || !isMetered);
  }

  /// Determines if the network is suitable for HD video downloads
  bool get isSuitableForHDDownload {
    return isHighSpeed && type != NetworkType.none;
  }

  /// Gets recommended download quality based on network
  String get recommendedQuality {
    if (!isSuitableForDownload) return 'none';
    if (isHighSpeed) return '1080p';
    if (type == NetworkType.wifi) return '720p';
    if (type == NetworkType.mobile && !isMetered) return '480p';
    return '360p';
  }
}

/// Enhanced network info with quality assessment
class EnhancedNetworkInfo extends NetworkInfoImpl {
  EnhancedNetworkInfo(super.connectivity);

  /// Gets current network quality information
  Future<NetworkQuality> getNetworkQuality() async {
    final result = await connectivityResult;
    final type = result.networkType;
    
    return NetworkQuality(
      type: type,
      isHighSpeed: result.isHighSpeed,
      isMetered: _isMeteredConnection(type),
      timestamp: DateTime.now(),
    );
  }

  /// Determines if the connection is metered (has data limits)
  bool _isMeteredConnection(NetworkType type) {
    switch (type) {
      case NetworkType.mobile:
        return true; // Assume mobile connections are metered
      case NetworkType.wifi:
      case NetworkType.ethernet:
        return false; // Assume WiFi and Ethernet are not metered
      case NetworkType.bluetooth:
      case NetworkType.vpn:
      case NetworkType.other:
        return true; // Conservative approach for unknown types
      case NetworkType.none:
        return false;
    }
  }

  /// Stream of network quality changes
  Stream<NetworkQuality> get networkQualityStream {
    return connectivityStream.asyncMap((result) async {
      final type = result.networkType;
      return NetworkQuality(
        type: type,
        isHighSpeed: result.isHighSpeed,
        isMetered: _isMeteredConnection(type),
        timestamp: DateTime.now(),
      );
    });
  }
}