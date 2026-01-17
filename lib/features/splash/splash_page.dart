import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:contribution/core/network/cubit/connectivity_cubit.dart';
import 'package:contribution/core/network/cubit/connectivity_state.dart';
import 'package:contribution/routes/app_router.dart';
import 'package:contribution/generated/l10n/app_localizations.dart';

/// Splash screen that checks internet connectivity before navigation
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkConnectivityAndNavigate();
  }

  Future<void> _checkConnectivityAndNavigate() async {
    // Wait a bit for splash screen to be visible
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check connectivity state
    final connectivityState = context.read<ConnectivityCubit>().state;

    if (connectivityState is ConnectivityOnline) {
      // Navigate to home if online
      context.go(AppRoutes.home);
    } else {
      // Navigate to no internet screen if offline
      context.go(AppRoutes.noInternet);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.alphaPercent(50),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Icon(Icons.flutter_dash, size: 120, color: Colors.white),
              const SizedBox(height: 24),

              // App Title
              Text(
                l10n.splashTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),

              // Checking Connection Text
              Text(
                l10n.checkingConnection,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
