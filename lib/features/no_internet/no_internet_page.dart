import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:contribution/core/network/cubit/connectivity_cubit.dart';
import 'package:contribution/core/network/cubit/connectivity_state.dart';
import 'package:contribution/routes/app_router.dart';
import 'package:contribution/generated/l10n/app_localizations.dart';

/// Screen displayed when there is no internet connection
///
/// Features:
/// - Shows user-friendly no internet message
/// - Provides retry button to manually check connectivity
/// - Automatically navigates to home when connection is restored
class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listener: (context, state) {
        // Auto-navigate to home when connection is restored
        if (state is ConnectivityOnline) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.connectionRestored),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate to home
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.go(AppRoutes.home);
            }
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // No Internet Icon
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 120,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    l10n.noInternetTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Message
                  Text(
                    l10n.noInternetMessage,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Retry Button
                  BlocBuilder<ConnectivityCubit, ConnectivityState>(
                    builder: (context, state) {
                      final isChecking = state is ConnectivityInitial;

                      return ElevatedButton.icon(
                        onPressed: isChecking
                            ? null
                            : () {
                                context
                                    .read<ConnectivityCubit>()
                                    .checkConnectivity();
                              },
                        icon: isChecking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
