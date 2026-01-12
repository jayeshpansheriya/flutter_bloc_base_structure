import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

enum _BodyType { formData, file, json }

/// ANSI color codes for colorful console output
class _AnsiColors {
  static const String reset = '\x1B[0m';
  static const String bold = '\x1B[1m';

  // Bright colors
  static const String brightRed = '\x1B[91m';
  static const String brightGreen = '\x1B[92m';
  static const String brightYellow = '\x1B[93m';
}

/// A beautiful dio log interceptor with colorful output and JSON formatting
/// for better readability during development.
///
/// Features:
/// - Colorful console output with ANSI colors
/// - Pretty-printed JSON formatting
/// - Request/Response/Error logging with emojis
/// - Configurable logging options
/// - Support for FormData, Files, and JSON bodies
class LoggingInterceptor implements Interceptor {
  /// Creates a colorful dio logging interceptor
  ///
  /// [logRequestHeaders]: Whether to log request headers (default: true)
  /// [logResponseHeaders]: Whether to log response headers (default: true)
  /// [logRequestTimeout]: Whether to log timeout info (default: false)
  /// [logger]: Custom logger function (default: dart:developer log)
  ///
  /// Example:
  /// ```dart
  /// dio.interceptors.add(
  ///   LoggingInterceptor(
  ///     logRequestHeaders: true,
  ///     logResponseHeaders: true,
  ///     logRequestTimeout: false,
  ///   ),
  /// );
  /// ```
  LoggingInterceptor({
    bool logRequestHeaders = true,
    bool logResponseHeaders = true,
    bool logRequestTimeout = false,
    void Function(String log)? logger,
  }) : _jsonEncoder = const JsonEncoder.withIndent('  '),
       _logRequestHeaders = logRequestHeaders,
       _logResponseHeaders = logResponseHeaders,
       _logRequestTimeout = logRequestTimeout,
       _logger = logger ?? log;

  late final JsonEncoder _jsonEncoder;
  late final bool _logRequestHeaders;
  late final bool _logResponseHeaders;
  late final bool _logRequestTimeout;
  late final void Function(String log) _logger;

  void _log({
    required String key,
    required String value,
    String color = '',
    bool bold = false,
  }) {
    final colorPrefix = color.isNotEmpty ? color : '';
    final boldPrefix = bold ? _AnsiColors.bold : '';
    final resetSuffix = (color.isNotEmpty || bold) ? _AnsiColors.reset : '';

    _logger('$colorPrefix$boldPrefix$key$value$resetSuffix');
  }

  void _logJson({
    required String key,
    dynamic value,
    bool isResponse = false,
    String color = '',
  }) {
    String encodedJson = '';
    final type = _bodyType(value);
    final isValueNull = value == null;

    switch (type) {
      case _BodyType.formData:
        encodedJson = _jsonEncoder.convert(
          Map.fromEntries((value as FormData).fields),
        );
        break;
      case _BodyType.file:
        encodedJson = 'File: ${value.runtimeType.toString()}';
        break;
      case _BodyType.json:
        encodedJson = _jsonEncoder.convert(isValueNull ? 'null' : value);
        break;
    }

    _log(
      key: switch (type) {
        _BodyType.formData when !isResponse => '[FormData.fields] $key',
        _BodyType.file when !isResponse => '[File] $key',
        _BodyType.json when !isValueNull && !isResponse => '[Json] $key',
        _ => key,
      },
      value: encodedJson,
      color: color,
    );

    if (type == _BodyType.formData && !isResponse) {
      final files = (value as FormData).files
          .map((e) => e.value.filename ?? 'Null or Empty filename')
          .toList();
      if (files.isNotEmpty) {
        final encodedJson = _jsonEncoder.convert(files);
        _log(
          key: '[FormData.files] Request Body:\n',
          value: encodedJson,
          color: color,
        );
      }
    }
  }

  void _logHeaders({required Map headers, String color = ''}) {
    _log(key: 'Headers:', value: '', color: color);
    headers.forEach((key, value) {
      _log(
        key: '\t$key: ',
        value: (value is List && value.length == 1)
            ? '[${value.join(', ')}]'
            : value.toString(),
        color: color,
      );
    });
  }

  void _logNewLine() => _log(key: '', value: '');

  void _logSeparator({String color = '', String char = '─'}) {
    final separator = char * 80;
    _log(key: '', value: separator, color: color);
  }

  void _logRequest(RequestOptions options) {
    const requestColor = _AnsiColors.brightYellow;

    _log(
      key: '🚀 [REQUEST] -> ',
      value: '${options.method} ${options.uri}',
      color: requestColor,
      bold: true,
    );
    _log(key: 'Uri: ', value: options.uri.toString(), color: requestColor);
    _log(key: 'Method: ', value: options.method, color: requestColor);
    _log(
      key: 'Response Type: ',
      value: options.responseType.toString(),
      color: requestColor,
    );
    _log(
      key: 'Follow Redirects: ',
      value: options.followRedirects.toString(),
      color: requestColor,
    );

    if (_logRequestTimeout) {
      _log(
        key: 'Connection Timeout: ',
        value: options.connectTimeout.toString(),
        color: requestColor,
      );
      _log(
        key: 'Send Timeout: ',
        value: options.sendTimeout.toString(),
        color: requestColor,
      );
      _log(
        key: 'Receive Timeout: ',
        value: options.receiveTimeout.toString(),
        color: requestColor,
      );
    }

    _log(
      key: 'Receive Data When Status Error: ',
      value: options.receiveDataWhenStatusError.toString(),
      color: requestColor,
    );
    _log(key: 'Extra: ', value: options.extra.toString(), color: requestColor);

    if (_logRequestHeaders) {
      _logHeaders(headers: options.headers, color: requestColor);
    }

    _logJson(key: 'Request Body:\n', value: options.data, color: requestColor);
  }

  void _logResponse(Response response, {bool error = false}) {
    final responseColor = error
        ? _AnsiColors.brightRed
        : _AnsiColors.brightGreen;
    final statusCode = response.statusCode ?? 0;
    final emoji = error ? '❌' : '✅';
    final statusText = error ? 'ERROR RESPONSE' : 'SUCCESS RESPONSE';

    _log(
      key: '$emoji [$statusText] -> ',
      value:
          '${response.requestOptions.method} ${response.realUri} ($statusCode)',
      color: responseColor,
      bold: true,
    );

    _log(
      key: 'Uri: ',
      value: response.realUri.toString(),
      color: responseColor,
    );
    _log(
      key: 'Request Method: ',
      value: response.requestOptions.method,
      color: responseColor,
    );
    _log(
      key: 'Status Code: ',
      value: '${response.statusCode}',
      color: responseColor,
    );

    if (_logResponseHeaders) {
      _logHeaders(headers: response.headers.map, color: responseColor);
    }

    _logJson(
      key: 'Response Body:\n',
      value: response.data,
      isResponse: true,
      color: responseColor,
    );
  }

  void _logError(DioException err) {
    const errorColor = _AnsiColors.brightRed;

    _log(
      key: '💥 [ERROR] -> ',
      value: '${err.requestOptions.method} ${err.requestOptions.uri}',
      color: errorColor,
      bold: true,
    );
    _log(
      key: 'Uri: ',
      value: err.requestOptions.uri.toString(),
      color: errorColor,
    );
    _log(
      key: 'Request Method: ',
      value: err.requestOptions.method,
      color: errorColor,
    );
    _log(key: 'Error Type: ', value: err.type.toString(), color: errorColor);
    _log(
      key: 'Error Message: ',
      value: err.message ?? 'Unknown error',
      color: errorColor,
    );
  }

  Future<void> _delay() async =>
      await Future.delayed(const Duration(milliseconds: 200));

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logSeparator(color: _AnsiColors.brightRed, char: '═');
    _logError(err);
    if (err.response != null) {
      _logResponse(err.response!, error: true);
    }
    _logSeparator(color: _AnsiColors.brightRed, char: '═');
    _logNewLine();

    _delay();

    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logSeparator(color: _AnsiColors.brightYellow);
    _logRequest(options);
    _logSeparator(color: _AnsiColors.brightYellow);
    _logNewLine();

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logSeparator(color: _AnsiColors.brightGreen);
    _logResponse(response);
    _logSeparator(color: _AnsiColors.brightGreen);
    _logNewLine();

    handler.next(response);
  }

  _BodyType _bodyType(dynamic value) {
    if (value.runtimeType == FormData) {
      return _BodyType.formData;
    } else if (value.runtimeType == ResponseBody) {
      return _BodyType.file;
    } else {
      return _BodyType.json;
    }
  }
}
