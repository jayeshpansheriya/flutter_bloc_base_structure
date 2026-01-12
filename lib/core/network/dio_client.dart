import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:contribution/core/constants/api_constants.dart';
import 'package:contribution/core/network/interceptors/auth_interceptor.dart';
import 'package:contribution/core/network/interceptors/logging_interceptor.dart';
import 'package:contribution/core/storage/secure_storage_service.dart';

/// Dio Client - Provides configured Dio instance for Retrofit services
///
/// This class sets up Dio with:
/// - Base URL and timeouts from ApiConstants
/// - Authentication interceptor with token caching for optimal performance
/// - Logging interceptor for debugging (only in debug mode)
///
/// Token Management:
/// - Tokens are cached in memory for fast access (no storage read on every request)
/// - Tokens are persisted in secure storage for app restarts
/// - First request lazy-loads tokens from storage into cache
///
/// Usage:
/// 1. Inject DioClient via GetIt
/// 2. Pass dioClient.dio to your Retrofit service constructors
/// 3. Use setTokens/clearTokens for authentication
class DioClient {
  late final Dio _dio;
  late final Dio _dioForRefresh;
  late final AuthInterceptor _authInterceptor;
  final SecureStorageService _secureStorage;

  /// Creates DioClient with secure storage and token caching
  ///
  /// [secureStorage]: Service for secure token storage
  /// [refreshTokenEndpoint]: Optional endpoint for token refresh (e.g., '/auth/refresh')
  /// [onRefreshToken]: Optional custom token refresh callback
  DioClient({
    required SecureStorageService secureStorage,
    String? refreshTokenEndpoint,
    Future<Map<String, String>> Function(String refreshToken)? onRefreshToken,
  }) : _secureStorage = secureStorage {
    // Main Dio instance
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl + ApiConstants.apiVersion,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
        },
      ),
    );

    // Separate Dio instance for token refresh to avoid interceptor loops
    _dioForRefresh = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl + ApiConstants.apiVersion,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
        },
      ),
    );

    // Create auth interceptor with token caching
    _authInterceptor = AuthInterceptor(
      secureStorage: _secureStorage,
      dio: _dioForRefresh,
      refreshTokenEndpoint: refreshTokenEndpoint,
      onRefreshToken: onRefreshToken,
    );

    // Add interceptors
    _dio.interceptors.add(_authInterceptor);

    // Only add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LoggingInterceptor(
          logRequestHeaders: true,
          logResponseHeaders: true,
          logRequestTimeout: false,
        ),
      );
    }
  }

  /// Get Dio instance for Retrofit services
  Dio get dio => _dio;

  /// Set authentication tokens (updates cache and storage)
  /// Call this after successful login
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _authInterceptor.setTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Set only access token (updates cache and storage)
  Future<void> setAccessToken(String token) async {
    await _authInterceptor.setAccessToken(token);
  }

  /// Set only refresh token (updates cache and storage)
  Future<void> setRefreshToken(String token) async {
    await _authInterceptor.setRefreshToken(token);
  }

  /// Clear authentication tokens (clears cache and storage)
  /// Call this on logout
  Future<void> clearTokens() async {
    await _authInterceptor.clearTokens();
  }

  /// Get current access token from cache (fast, no storage read!)
  String? getAccessToken() {
    return _authInterceptor.getAccessToken();
  }

  /// Get current refresh token from cache (fast, no storage read!)
  String? getRefreshToken() {
    return _authInterceptor.getRefreshToken();
  }

  /// Check if user is authenticated (has cached token or token in storage)
  Future<bool> isAuthenticated() async {
    // First check cache (fast)
    if (_authInterceptor.hasTokensInCache()) {
      return true;
    }

    // If not in cache, check storage (slower, but only on app start)
    return await _secureStorage.hasAccessToken();
  }
}
