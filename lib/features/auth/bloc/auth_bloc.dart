import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) {
      // TODO: implement logic
    });
  }
}
