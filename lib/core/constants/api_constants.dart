/// API Configuration Constants
class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String baseUrl =
      'https://api.example.com'; // TODO: Update with actual API URL
  static const String apiVersion = '/v1';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';

  // API Endpoints
  // Example: static const String login = '/auth/login';
  // Example: static const String register = '/auth/register';
}
