import 'package:equatable/equatable.dart';

/// Base class for connectivity states
abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object?> get props => [];
}

/// Initial state before connectivity check
class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial();
}

/// State when device is connected to internet
class ConnectivityOnline extends ConnectivityState {
  const ConnectivityOnline();
}

/// State when device is not connected to internet
class ConnectivityOffline extends ConnectivityState {
  const ConnectivityOffline();
}
