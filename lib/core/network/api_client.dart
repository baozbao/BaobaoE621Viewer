import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../services/log_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final settings = ref.watch(settingsProvider);
  
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://${settings.siteHost}',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'User-Agent': 'E621Mobile/1.0 (by Baozbao)',
      },
    ),
  );

  final logNotifier = ref.read(logProvider.notifier);

  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        logNotifier.addLog(
          LogEntry(
            timestamp: DateTime.now(),
            url: response.requestOptions.uri.toString(),
            method: response.requestOptions.method,
            statusCode: response.statusCode,
            type: LogType.api,
          ),
        );
        handler.next(response);
      },
      onError: (DioException e, handler) {
        logNotifier.addLog(
          LogEntry(
            timestamp: DateTime.now(),
            url: e.requestOptions.uri.toString(),
            method: e.requestOptions.method,
            statusCode: e.response?.statusCode,
            errorMessage: e.message,
            type: LogType.api,
          ),
        );
        handler.next(e);
      },
    ),
  );
  
  return dio;
});
