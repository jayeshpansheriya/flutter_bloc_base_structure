import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/localization/l10n/app_localizations.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/cubit/language_cubit.dart';
import 'core/localization/cubit/language_state.dart';
import 'di/service_locator.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<LanguageCubit>(),
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, languageState) {
          return MaterialApp.router(
            title: 'Contribution',
            theme: AppTheme.lightTheme,
            routerConfig: appRouter,

            // Localization configuration
            locale: languageState.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
