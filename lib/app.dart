import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contribution/generated/l10n/app_localizations.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/locale_cubit.dart';
import 'core/localization/locale_state.dart';
import 'core/network/cubit/connectivity_cubit.dart';
import 'di/service_locator.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<LocaleCubit>()),
        BlocProvider.value(value: sl<ConnectivityCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return MaterialApp.router(
            title: 'Contribution',
            theme: AppTheme.lightTheme,
            routerConfig: appRouter,

            // Localization configuration
            locale: localeState.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
