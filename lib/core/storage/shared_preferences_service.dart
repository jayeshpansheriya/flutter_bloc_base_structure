import 'package:shared_preferences/shared_preferences.dart';

/// Shared preferences service for managing non-sensitive app data
///
/// Use this for:
/// - User preferences (theme, language, etc.)
/// - App settings
/// - Cache data
/// - Non-sensitive user data
///
/// For sensitive data (tokens, passwords), use SecureStorageService instead.
class SharedPreferencesService {
  late final SharedPreferences _prefs;
  bool _isInitialized = false;

  /// Initialize shared preferences
  /// Call this once during app startup
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Ensure preferences are initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'SharedPreferencesService not initialized. Call init() first.',
      );
    }
  }

  // ==================== String Operations ====================

  /// Save a string value
  Future<bool> setString(String key, String value) async {
    _ensureInitialized();
    return await _prefs.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    _ensureInitialized();
    return _prefs.getString(key);
  }

  // ==================== Int Operations ====================

  /// Save an integer value
  Future<bool> setInt(String key, int value) async {
    _ensureInitialized();
    return await _prefs.setInt(key, value);
  }

  /// Get an integer value
  int? getInt(String key) {
    _ensureInitialized();
    return _prefs.getInt(key);
  }

  // ==================== Double Operations ====================

  /// Save a double value
  Future<bool> setDouble(String key, double value) async {
    _ensureInitialized();
    return await _prefs.setDouble(key, value);
  }

  /// Get a double value
  double? getDouble(String key) {
    _ensureInitialized();
    return _prefs.getDouble(key);
  }

  // ==================== Bool Operations ====================

  /// Save a boolean value
  Future<bool> setBool(String key, bool value) async {
    _ensureInitialized();
    return await _prefs.setBool(key, value);
  }

  /// Get a boolean value
  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs.getBool(key);
  }

  // ==================== List<String> Operations ====================

  /// Save a list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    _ensureInitialized();
    return await _prefs.setStringList(key, value);
  }

  /// Get a list of strings
  List<String>? getStringList(String key) {
    _ensureInitialized();
    return _prefs.getStringList(key);
  }

  // ==================== Check & Remove Operations ====================

  /// Check if a key exists
  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs.containsKey(key);
  }

  /// Remove a specific key
  Future<bool> remove(String key) async {
    _ensureInitialized();
    return await _prefs.remove(key);
  }

  /// Clear all preferences
  Future<bool> clear() async {
    _ensureInitialized();
    return await _prefs.clear();
  }

  /// Get all keys
  Set<String> getKeys() {
    _ensureInitialized();
    return _prefs.getKeys();
  }

  // ==================== Common Use Cases ====================

  /// Save user theme preference
  Future<bool> setThemeMode(String mode) async {
    return await setString('theme_mode', mode);
  }

  /// Get user theme preference
  String? getThemeMode() {
    return getString('theme_mode');
  }

  /// Save user language preference
  Future<bool> setLanguage(String languageCode) async {
    return await setString('language', languageCode);
  }

  /// Get user language preference
  String? getLanguage() {
    return getString('language');
  }

  /// Save onboarding completion status
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await setBool('onboarding_completed', completed);
  }

  /// Check if onboarding is completed
  bool isOnboardingCompleted() {
    return getBool('onboarding_completed') ?? false;
  }

  /// Save first launch flag
  Future<bool> setFirstLaunch(bool isFirst) async {
    return await setBool('is_first_launch', isFirst);
  }

  /// Check if this is first launch
  bool isFirstLaunch() {
    return getBool('is_first_launch') ?? true;
  }
}
