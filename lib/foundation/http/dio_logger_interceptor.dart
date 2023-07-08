// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    required this.logger,
    required this.booruConfig,
  });

  final LoggerService logger;
  final BooruConfig booruConfig;
  final Map<String, DateTime> requestTimeLogs = <String, DateTime>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.logI('Network', 'Sending ${options.method} to ${options.uri}');
    requestTimeLogs[options.uri.toString()] = DateTime.now();
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final duration = getRequestDuration(response.requestOptions);
    logger.logI('Network',
        'Completed ${response.requestOptions.method} to ${response.requestOptions.uri} with status: ${response.statusCodeOrZero} and took ${duration}ms');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final duration = getRequestDuration(response?.requestOptions);

    if (response != null) {
      logger.logI('Network',
          'Completed ${response.requestOptions.method} to ${response.requestOptions.uri} with status: ${response.statusCodeOrZero}, body ${response.data} and took ${duration}ms');

      if (response.statusCode == 401) {
        logger.logE('Network',
            'Unauthorized using login: ${booruConfig.login} and api key: ${booruConfig.apiKey}');
      }
    } else {
      logger.logE('Network', 'Completed with error: ${err.message}');
    }
    super.onError(err, handler);
  }

  String? getRequestDuration(RequestOptions? requestOptions) {
    if (requestOptions == null) return null;
    final startTime = requestTimeLogs.remove(requestOptions.uri.toString());
    final requestDuration =
        DateTime.now().difference(startTime ?? DateTime.now()).inMilliseconds;
    return requestDuration.toString();
  }
}