import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
    // Add other common theme properties here
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
