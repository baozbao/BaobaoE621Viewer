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
      headers: {'User-Agent': 'E621Mobile/1.0 (by Baozbao)'},
    ),
  );

  dio.interceptors.add(AppLogInterceptor(ref.read(logProvider.notifier)));

  return dio;
});

/// 记录所有经过 [dioProvider] 的请求（查询、下载，以后的认证请求同理）。
///
/// 发起时先落一条 pending，响应回来后原地补全状态码与耗时。这样卡住的请求
/// 会明显停在 pending，而不是等 15 秒超时才在日志里冒出来。
///
/// 名字刻意避开 dio 自带的 `LogInterceptor`（那个只往控制台打印），
/// 否则同时 import dio 和本文件的地方会撞名。
class AppLogInterceptor extends Interceptor {
  AppLogInterceptor(this._log);

  final LogNotifier _log;

  /// dio 不给请求分配 id，这里自增一个，用 extra 挂在 RequestOptions 上
  /// 带到响应阶段做配对。
  static int _seq = 0;
  static const _idKey = 'logRequestId';

  /// 调用方可在 options.extra 里放这个键来标注用途（见 [LogType]）。
  /// 不标就按普通 API 查询算。
  static const typeKey = 'logType';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final id = ++_seq;
    options.extra[_idKey] = id;

    _log.logRequest(
      LogEntry(
        requestId: id,
        timestamp: DateTime.now(),
        url: options.uri.toString(),
        method: options.method,
        type: _typeOf(options),
      ),
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _complete(
      response.requestOptions,
      status: LogStatus.success,
      statusCode: response.statusCode,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _complete(
      err.requestOptions,
      status: LogStatus.failure,
      statusCode: err.response?.statusCode,
      errorMessage: err.message,
    );
    handler.next(err);
  }

  void _complete(
    RequestOptions options, {
    required LogStatus status,
    int? statusCode,
    String? errorMessage,
  }) {
    final id = options.extra[_idKey] as int?;
    final entry = LogEntry(
      requestId: id ?? ++_seq,
      timestamp: DateTime.now(),
      url: options.uri.toString(),
      method: options.method,
      statusCode: statusCode,
      errorMessage: errorMessage,
      type: _typeOf(options),
      status: status,
    );

    if (id == null) {
      // 没有 id 说明请求发起于本拦截器之外（或日志已被清空），补记一条。
      _log.logRequest(entry);
      return;
    }

    _log.completeRequest(
      requestId: id,
      status: status,
      statusCode: statusCode,
      errorMessage: errorMessage,
      fallback: entry,
    );
  }

  LogType _typeOf(RequestOptions options) {
    final tagged = options.extra[typeKey];
    return tagged is LogType ? tagged : LogType.api;
  }
}
