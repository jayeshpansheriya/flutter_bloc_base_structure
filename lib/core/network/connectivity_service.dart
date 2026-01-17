import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor internet connectivity status
///
/// This service provides:
/// - Stream of connectivity changes
/// - Current connectivity status check
/// - Proper resource cleanup
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Stream of connectivity status changes
  ///
  /// Emits `true` when connected (WiFi or Mobile), `false` when disconnected
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((results) {
      return _isConnected(results);
    });
  }

  /// Check current connectivity status
  ///
  /// Returns `true` if connected to WiFi or Mobile data, `false` otherwise
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  /// Helper method to determine if device is connected
  bool _isConnected(List<ConnectivityResult> results) {
    // Check if any result indicates connectivity
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet,
    );
  }

  /// Dispose of resources
  void dispose() {
    _subscription?.cancel();
  }
}
