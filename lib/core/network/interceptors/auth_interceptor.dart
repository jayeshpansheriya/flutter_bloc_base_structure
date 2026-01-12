import 'package:dio/dio.dart';

/// Authentication interceptor to add auth tokens to requests
class AuthInterceptor extends Interceptor {
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? getToken() => _token;

  void clearToken() {
    _token = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null && _token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - token expired or invalid
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic or redirect to login
      clearToken();
    }
    super.onError(err, handler);
  }
}
