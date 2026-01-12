import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for managing authentication tokens
///
/// Uses flutter_secure_storage to securely store access and refresh tokens
/// in the device's keychain (iOS) or keystore (Android).
class SecureStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  SecureStorageService()
    : _storage = const FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  /// Save access token securely
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Save both access and refresh tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Check if access token exists
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if refresh token exists
  Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }

  /// Delete access token
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Delete all tokens (logout)
  Future<void> deleteAllTokens() async {
    await Future.wait([deleteAccessToken(), deleteRefreshToken()]);
  }

  /// Clear all secure storage data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
