// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'योगदान';

  @override
  String get welcome => 'स्वागत है';

  @override
  String get splashTitle => 'योगदान में आपका स्वागत है';

  @override
  String get checkingConnection => 'कनेक्शन जांचा जा रहा है...';

  @override
  String get noInternetTitle => 'इंटरनेट कनेक्शन नहीं है';

  @override
  String get noInternetMessage =>
      'कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get connectionRestored => 'कनेक्शन बहाल हो गया!';
}
