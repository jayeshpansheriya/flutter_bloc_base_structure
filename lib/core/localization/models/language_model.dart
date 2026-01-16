import 'package:flutter/material.dart';

/// Model representing a supported language in the application
class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final Locale locale;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
  });

  /// List of all supported languages
  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      locale: Locale('en'),
    ),
    LanguageModel(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      locale: Locale('hi'),
    ),
  ];

  /// Find a language by its code
  /// Returns null if language is not found
  static LanguageModel? findByCode(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Get list of supported locale codes
  static List<String> get supportedLocaleCodes {
    return supportedLanguages.map((lang) => lang.code).toList();
  }

  /// Get list of supported locales
  static List<Locale> get supportedLocales {
    return supportedLanguages.map((lang) => lang.locale).toList();
  }

  @override
  String toString() => 'LanguageModel(code: $code, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageModel && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}
