import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// State class for language management
class LanguageState extends Equatable {
  final Locale locale;

  const LanguageState(this.locale);

  @override
  List<Object?> get props => [locale];

  @override
  String toString() => 'LanguageState(locale: ${locale.languageCode})';
}
