import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:contribution/core/constants/api_constants.dart';
import 'package:contribution/core/network/interceptors/auth_interceptor.dart';
import 'package:contribution/core/network/interceptors/logging_interceptor.dart';

/// Dio Client - Provides configured Dio instance for Retrofit services
///
/// This class sets up Dio with:
/// - Base URL and timeouts from ApiConstants
/// - Authentication interceptor for token management
/// - Logging interceptor for debugging (only in debug mode)
///
/// Usage:
/// 1. Inject DioClient via GetIt
/// 2. Pass dioClient.dio to your Retrofit service constructors
/// 3. Use setAuthToken/clearAuthToken for authentication
class DioClient {
  late final Dio _dio;
  late final AuthInterceptor _authInterceptor;

  DioClient() {
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

    _authInterceptor = AuthInterceptor();

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

  /// Set authentication token (call after login)
  void setAuthToken(String token) => _authInterceptor.setToken(token);

  /// Clear authentication token (call on logout)
  void clearAuthToken() => _authInterceptor.clearToken();

  /// Get current authentication token
  String? getAuthToken() => _authInterceptor.getToken();
}
