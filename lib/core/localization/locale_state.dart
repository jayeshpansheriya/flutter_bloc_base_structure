import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// State class for locale management
class LocaleState extends Equatable {
  final Locale locale;

  const LocaleState(this.locale);

  @override
  List<Object?> get props => [locale];

  @override
  String toString() => 'LocaleState(locale: ${locale.languageCode})';
}
