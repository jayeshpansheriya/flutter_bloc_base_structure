import 'package:dio/dio.dart';

/// Custom API Error class for handling different error types
class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final ApiErrorType type;

  ApiError({
    required this.message,
    this.statusCode,
    this.data,
    required this.type,
  });

  factory ApiError.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          message: 'Connection timeout. Please check your internet connection.',
          type: ApiErrorType.timeout,
        );

      case DioExceptionType.badResponse:
        return ApiError(
          message: _parseErrorMessage(error.response),
          statusCode: error.response?.statusCode,
          data: error.response?.data,
          type: ApiErrorType.response,
        );

      case DioExceptionType.cancel:
        return ApiError(
          message: 'Request was cancelled',
          type: ApiErrorType.cancel,
        );

      case DioExceptionType.connectionError:
        return ApiError(
          message: 'No internet connection',
          type: ApiErrorType.network,
        );

      case DioExceptionType.badCertificate:
        return ApiError(
          message: 'Certificate verification failed',
          type: ApiErrorType.network,
        );

      case DioExceptionType.unknown:
        return ApiError(
          message: error.message ?? 'An unexpected error occurred',
          type: ApiErrorType.unknown,
        );
    }
  }

  static String _parseErrorMessage(Response? response) {
    if (response?.data is Map) {
      final data = response!.data as Map<String, dynamic>;
      return data['message'] ??
          data['error'] ??
          data['detail'] ??
          'An error occurred';
    }
    return 'An error occurred';
  }

  @override
  String toString() => message;
}

enum ApiErrorType { network, timeout, response, cancel, unknown }
