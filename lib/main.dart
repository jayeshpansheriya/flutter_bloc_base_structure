import 'package:flutter/material.dart';
import 'app.dart';
import 'di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator
  initServiceLocator();

  // Wait for async singletons to be ready (e.g., SharedPreferences)
  await sl.allReady();

  runApp(const MyApp());
}
