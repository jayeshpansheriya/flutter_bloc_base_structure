import 'package:dio/dio.dart';
import 'package:contribution/core/storage/secure_storage_service.dart';

/// Authentication interceptor with token caching for optimal performance
///
/// Features:
/// - In-memory token caching (no storage read on every request)
/// - Automatically adds Authorization header with cached access token
/// - Handles 401 errors and attempts token refresh
/// - Retries failed requests after successful token refresh
/// - Lazy-loads tokens from storage only when needed
class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;
  final String? refreshTokenEndpoint;
  final Future<Map<String, String>> Function(String refreshToken)?
  onRefreshToken;

  // In-memory token cache for performance
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  bool _isInitialized = false;

  /// Creates an authentication interceptor with token caching
  ///
  /// [secureStorage]: Service for secure token storage
  /// [dio]: Dio instance for making refresh token requests
  /// [refreshTokenEndpoint]: API endpoint for token refresh (e.g., '/auth/refresh')
  /// [onRefreshToken]: Custom callback for token refresh logic
  ///
  /// Example:
  /// ```dart
  /// AuthInterceptor(
  ///   secureStorage: sl<SecureStorageService>(),
  ///   dio: Dio(), // Separate Dio instance to avoid interceptor loop
  ///   refreshTokenEndpoint: '/auth/refresh',
  /// )
  /// ```
  AuthInterceptor({
    required SecureStorageService secureStorage,
    required Dio dio,
    this.refreshTokenEndpoint,
    this.onRefreshToken,
  }) : _secureStorage = secureStorage,
       _dio = dio;

  /// Initialize tokens from secure storage (called once on first request)
  Future<void> _initializeTokens() async {
    if (_isInitialized) return;

    _cachedAccessToken = await _secureStorage.getAccessToken();
    _cachedRefreshToken = await _secureStorage.getRefreshToken();
    _isInitialized = true;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Lazy-load tokens from storage on first request
    if (!_isInitialized) {
      await _initializeTokens();
    }

    // Use cached token (no storage read!)
    if (_cachedAccessToken != null && _cachedAccessToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_cachedAccessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - token expired or invalid
    if (err.response?.statusCode == 401) {
      // Try to refresh the token
      final refreshed = await _refreshToken();

      if (refreshed) {
        // Retry the original request with new token
        try {
          final response = await _retry(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // If retry fails, continue with error
          handler.next(err);
          return;
        }
      } else {
        // Token refresh failed, clear tokens and continue with error
        await clearTokens();
        handler.next(err);
        return;
      }
    }

    handler.next(err);
  }

  /// Attempt to refresh the access token
  Future<bool> _refreshToken() async {
    try {
      // Use cached refresh token (no storage read!)
      if (_cachedRefreshToken == null || _cachedRefreshToken!.isEmpty) {
        return false;
      }

      // Use custom refresh logic if provided
      if (onRefreshToken != null) {
        final tokens = await onRefreshToken!(_cachedRefreshToken!);
        await _updateTokens(
          accessToken: tokens['access_token']!,
          refreshToken: tokens['refresh_token']!,
        );
        return true;
      }

      // Default refresh logic using refreshTokenEndpoint
      if (refreshTokenEndpoint != null) {
        final response = await _dio.post(
          refreshTokenEndpoint!,
          data: {'refresh_token': _cachedRefreshToken},
        );

        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await _updateTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          return true;
        }
      }

      return false;
    } catch (e) {
      // Token refresh failed
      return false;
    }
  }

  /// Update tokens in both cache and storage
  Future<void> _updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Update cache first (immediate effect)
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;

    // Then update storage (for persistence)
    await _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Retry the failed request with new token
  Future<Response> _retry(RequestOptions requestOptions) async {
    // Update authorization header with cached token
    if (_cachedAccessToken != null) {
      requestOptions.headers['Authorization'] = 'Bearer $_cachedAccessToken';
    }

    // Create new options without the interceptor to avoid infinite loop
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    // Retry the request
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Set access token (updates both cache and storage)
  Future<void> setAccessToken(String token) async {
    _cachedAccessToken = token;
    await _secureStorage.saveAccessToken(token);
  }

  /// Set refresh token (updates both cache and storage)
  Future<void> setRefreshToken(String token) async {
    _cachedRefreshToken = token;
    await _secureStorage.saveRefreshToken(token);
  }

  /// Set both tokens (updates both cache and storage)
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    _isInitialized = true;

    await _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Clear all tokens (clears both cache and storage)
  Future<void> clearTokens() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _isInitialized = false;

    await _secureStorage.deleteAllTokens();
  }

  /// Get current access token from cache (no storage read!)
  String? getAccessToken() => _cachedAccessToken;

  /// Get current refresh token from cache (no storage read!)
  String? getRefreshToken() => _cachedRefreshToken;

  /// Check if tokens are cached in memory
  bool hasTokensInCache() {
    return _cachedAccessToken != null && _cachedAccessToken!.isNotEmpty;
  }
}
