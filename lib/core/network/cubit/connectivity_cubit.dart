import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contribution/core/network/connectivity_service.dart';
import 'package:contribution/core/network/cubit/connectivity_state.dart';

/// Cubit to manage connectivity state
///
/// Listens to ConnectivityService and emits appropriate states
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;

  ConnectivityCubit(this._connectivityService)
    : super(const ConnectivityInitial()) {
    _init();
  }

  /// Initialize connectivity monitoring
  void _init() {
    // Check initial connectivity status
    _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen((
      isConnected,
    ) {
      if (isConnected) {
        emit(const ConnectivityOnline());
      } else {
        emit(const ConnectivityOffline());
      }
    });
  }

  /// Manually check connectivity status
  Future<void> checkConnectivity() async {
    await _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (isConnected) {
      emit(const ConnectivityOnline());
    } else {
      emit(const ConnectivityOffline());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    return super.close();
  }
}
