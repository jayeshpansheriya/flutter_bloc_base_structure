# 📦 Shared Preferences Service Guide

## Overview

`SharedPreferencesService` provides a simple, type-safe way to store non-sensitive app data locally.

## 🎯 When to Use

### ✅ Use SharedPreferences For:

- User preferences (theme, language, font size)
- App settings (notifications enabled, auto-save)
- UI state (onboarding completed, tutorial shown)
- Cache data (last sync time, cached responses)
- Non-sensitive user data

### ❌ Don't Use SharedPreferences For:

- **Sensitive data** (tokens, passwords) → Use `SecureStorageService`
- **Large data** (images, files) → Use file storage
- **Complex data structures** → Use database (Hive, SQLite)
- **Relational data** → Use database

## 🚀 Setup

### 1. Already Configured!

The service is already set up in your project:

- ✅ Dependency added: `shared_preferences: ^2.3.4`
- ✅ Service created: `lib/core/storage/shared_preferences_service.dart`
- ✅ Registered in DI: `lib/di/service_locator.dart`

### 2. How It's Registered

```dart
// lib/di/service_locator.dart
void initServiceLocator() {
  // Async initialization using registerSingletonAsync
  sl.registerSingletonAsync<SharedPreferencesService>(() async {
    final service = SharedPreferencesService();
    await service.init();
    return service;
  });
}

// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initServiceLocator();

  // Wait for async singletons to be ready
  await sl.allReady();

  runApp(const MyApp());
}
```

## 📖 Usage Examples

### Basic Operations

```dart
// Get the service
final prefs = sl<SharedPreferencesService>();

// String
await prefs.setString('username', 'john_doe');
final username = prefs.getString('username'); // 'john_doe'

// Int
await prefs.setInt('age', 25);
final age = prefs.getInt('age'); // 25

// Double
await prefs.setDouble('rating', 4.5);
final rating = prefs.getDouble('rating'); // 4.5

// Bool
await prefs.setBool('notifications_enabled', true);
final enabled = prefs.getBool('notifications_enabled'); // true

// List<String>
await prefs.setStringList('favorites', ['item1', 'item2']);
final favorites = prefs.getStringList('favorites'); // ['item1', 'item2']
```

### Common Use Cases

```dart
final prefs = sl<SharedPreferencesService>();

// Theme preference
await prefs.setThemeMode('dark');
final theme = prefs.getThemeMode(); // 'dark'

// Language preference
await prefs.setLanguage('en');
final language = prefs.getLanguage(); // 'en'

// Onboarding status
await prefs.setOnboardingCompleted(true);
final completed = prefs.isOnboardingCompleted(); // true

// First launch check
final isFirst = prefs.isFirstLaunch(); // true on first launch
await prefs.setFirstLaunch(false);
```

### Check & Remove

```dart
final prefs = sl<SharedPreferencesService>();

// Check if key exists
if (prefs.containsKey('username')) {
  print('Username exists');
}

// Remove specific key
await prefs.remove('username');

// Get all keys
final keys = prefs.getKeys(); // Set<String>

// Clear all preferences
await prefs.clear();
```

## 🎨 Real-World Examples

### Example 1: Theme Management

```dart
class ThemeRepository {
  final SharedPreferencesService _prefs;

  ThemeRepository(this._prefs);

  Future<void> saveTheme(ThemeMode mode) async {
    await _prefs.setThemeMode(mode.name);
  }

  ThemeMode getTheme() {
    final themeName = _prefs.getThemeMode();
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == themeName,
      orElse: () => ThemeMode.system,
    );
  }
}
```

### Example 2: Onboarding Flow

```dart
class OnboardingCubit extends Cubit<OnboardingState> {
  final SharedPreferencesService _prefs;

  OnboardingCubit(this._prefs) : super(OnboardingInitial());

  void checkOnboarding() {
    if (_prefs.isOnboardingCompleted()) {
      emit(OnboardingCompleted());
    } else {
      emit(OnboardingRequired());
    }
  }

  Future<void> completeOnboarding() async {
    await _prefs.setOnboardingCompleted(true);
    emit(OnboardingCompleted());
  }
}
```

### Example 3: App Settings

```dart
class SettingsRepository {
  final SharedPreferencesService _prefs;

  SettingsRepository(this._prefs);

  // Notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool('notifications_enabled', enabled);
  }

  bool areNotificationsEnabled() {
    return _prefs.getBool('notifications_enabled') ?? true;
  }

  // Auto-save
  Future<void> setAutoSaveEnabled(bool enabled) async {
    await _prefs.setBool('auto_save', enabled);
  }

  bool isAutoSaveEnabled() {
    return _prefs.getBool('auto_save') ?? false;
  }

  // Font size
  Future<void> setFontSize(double size) async {
    await _prefs.setDouble('font_size', size);
  }

  double getFontSize() {
    return _prefs.getDouble('font_size') ?? 14.0;
  }
}
```

### Example 4: Cache Management

```dart
class CacheRepository {
  final SharedPreferencesService _prefs;

  CacheRepository(this._prefs);

  Future<void> cacheLastSyncTime() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs.setInt('last_sync_time', now);
  }

  DateTime? getLastSyncTime() {
    final timestamp = _prefs.getInt('last_sync_time');
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  bool shouldSync() {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return true;

    final difference = DateTime.now().difference(lastSync);
    return difference.inHours >= 24;
  }
}
```

## 🔄 Migration from Direct SharedPreferences

### Before (Direct Usage)

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('key', 'value');
final value = prefs.getString('key');
```

### After (Using Service)

```dart
final prefs = sl<SharedPreferencesService>();
await prefs.setString('key', 'value');
final value = prefs.getString('key');
```

## 📊 Comparison: SharedPreferences vs SecureStorage

| Feature         | SharedPreferences                       | SecureStorage                      |
| --------------- | --------------------------------------- | ---------------------------------- |
| **Use Case**    | Non-sensitive data                      | Sensitive data (tokens, passwords) |
| **Performance** | Fast                                    | Slower (encryption overhead)       |
| **Security**    | Plain text                              | Encrypted                          |
| **Data Types**  | String, int, double, bool, List<String> | String only                        |
| **Platform**    | All platforms                           | iOS (Keychain), Android (Keystore) |
| **Example**     | Theme, language, settings               | Auth tokens, API keys              |

## 🎯 Best Practices

### DO:

- ✅ Use for user preferences and settings
- ✅ Use for non-sensitive cache data
- ✅ Use for UI state (onboarding, tutorials)
- ✅ Check for null values when reading
- ✅ Provide default values

### DON'T:

- ❌ Store sensitive data (use SecureStorage)
- ❌ Store large amounts of data
- ❌ Store complex objects directly (serialize to JSON string)
- ❌ Forget to handle null values
- ❌ Use for relational data

## 🔧 Advanced: Storing JSON Objects

```dart
import 'dart:convert';

class UserPreferences {
  final String name;
  final int age;

  UserPreferences({required this.name, required this.age});

  // To JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
  };

  // From JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      name: json['name'],
      age: json['age'],
    );
  }
}

// Save
final prefs = sl<SharedPreferencesService>();
final user = UserPreferences(name: 'John', age: 25);
await prefs.setString('user_prefs', jsonEncode(user.toJson()));

// Load
final jsonString = prefs.getString('user_prefs');
if (jsonString != null) {
  final user = UserPreferences.fromJson(jsonDecode(jsonString));
}
```

## 📱 Platform-Specific Notes

### iOS

- Stored in `NSUserDefaults`
- Survives app uninstall if device backup is restored
- Shared between app and extensions (if configured)

### Android

- Stored in XML files in app's data directory
- Cleared on app uninstall
- Can be backed up with Auto Backup

### Web

- Stored in browser's LocalStorage
- Cleared when browser cache is cleared
- Limited to ~5-10 MB

## 🐛 Troubleshooting

### Service Not Initialized

```dart
// Error: SharedPreferencesService not initialized
// Solution: Ensure sl.allReady() is called in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initServiceLocator();
  await sl.allReady(); // ← Don't forget this!
  runApp(const MyApp());
}
```

### Value Not Persisting

```dart
// Make sure to await the set operation
await prefs.setString('key', 'value'); // ✅ Correct
prefs.setString('key', 'value'); // ❌ Wrong (not awaited)
```

### Null Values

```dart
// Always provide defaults or check for null
final theme = prefs.getString('theme') ?? 'light'; // ✅ Good
final theme = prefs.getString('theme')!; // ❌ Risky (can crash)
```

## 📚 API Reference

### Write Operations

```dart
Future<bool> setString(String key, String value)
Future<bool> setInt(String key, int value)
Future<bool> setDouble(String key, double value)
Future<bool> setBool(String key, bool value)
Future<bool> setStringList(String key, List<String> value)
```

### Read Operations

```dart
String? getString(String key)
int? getInt(String key)
double? getDouble(String key)
bool? getBool(String key)
List<String>? getStringList(String key)
```

### Utility Operations

```dart
bool containsKey(String key)
Future<bool> remove(String key)
Future<bool> clear()
Set<String> getKeys()
```

### Common Use Cases

```dart
Future<bool> setThemeMode(String mode)
String? getThemeMode()
Future<bool> setLanguage(String languageCode)
String? getLanguage()
Future<bool> setOnboardingCompleted(bool completed)
bool isOnboardingCompleted()
Future<bool> setFirstLaunch(bool isFirst)
bool isFirstLaunch()
```

---

**Summary**: Use `SharedPreferencesService` for all non-sensitive app data. It's fast, simple, and perfect for user preferences and settings!
