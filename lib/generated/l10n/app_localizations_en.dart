// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Contribution';

  @override
  String get welcome => 'Welcome';

  @override
  String get splashTitle => 'Welcome to Contribution';

  @override
  String get checkingConnection => 'Checking connection...';

  @override
  String get noInternetTitle => 'No Internet Connection';

  @override
  String get noInternetMessage =>
      'Please check your internet connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get connectionRestored => 'Connection restored!';
}
