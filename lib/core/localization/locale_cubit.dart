import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contribution/core/localization/locale_state.dart';
import 'package:contribution/core/localization/models/language_model.dart';
import 'package:contribution/core/storage/shared_preferences_service.dart';

/// Cubit for managing application locale
/// Handles language switching and persistence using SharedPreferencesService
class LocaleCubit extends Cubit<LocaleState> {
  final SharedPreferencesService _prefs;

  LocaleCubit(this._prefs) : super(LocaleState(_getInitialLocale(_prefs)));

  /// Get initial locale from saved preferences or default to English
  static Locale _getInitialLocale(SharedPreferencesService prefs) {
    final savedLocale = prefs.getLanguage();
    if (savedLocale != null) {
      final language = LanguageModel.findByCode(savedLocale);
      if (language != null) {
        return language.locale;
      }
    }
    // Default to English
    return const Locale('en');
  }

  /// Change app language
  /// @param languageCode - The language code to switch to (e.g., 'en', 'hi')
  Future<void> changeLanguage(String languageCode) async {
    final language = LanguageModel.findByCode(languageCode);
    if (language != null) {
      await _prefs.setLanguage(languageCode);
      emit(LocaleState(language.locale));
    }
  }

  /// Reset to system default language (English)
  Future<void> resetToSystemLanguage() async {
    await _prefs.remove('language');
    emit(const LocaleState(Locale('en')));
  }

  /// Get current language model
  LanguageModel get currentLanguage {
    return LanguageModel.findByCode(state.locale.languageCode) ??
        LanguageModel.supportedLanguages.first;
  }

  /// Get all supported languages
  List<LanguageModel> get supportedLanguages {
    return LanguageModel.supportedLanguages;
  }

  /// Check if a specific language is currently active
  bool isLanguageActive(String languageCode) {
    return state.locale.languageCode == languageCode;
  }
}
