import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 日志分类。请求都走同一个 dio，靠调用方在 extra 里打标来区分用途，
/// 否则下载和普通查询在日志里长得一模一样，排查时分不开。
enum LogType { api, autocomplete, download, image, system }

extension LogTypeX on LogType {
  String get label => switch (this) {
    LogType.api => '查询',
    LogType.autocomplete => '补全',
    LogType.download => '下载',
    LogType.image => '图片',
    LogType.system => '系统',
  };
}

/// 请求生命周期。发起时先落 pending，收到响应/错误后原地补全 ——
/// 这样卡住的请求能一眼看出来（停在 pending），而不是等超时才出现。
enum LogStatus { pending, success, failure }

class LogEntry {
  /// 与 dio 的 RequestOptions 一一对应，用来把响应配回发起时那条记录。
  final int requestId;
  final DateTime timestamp;
  final String url;
  final String method;
  final int? statusCode;
  final String? errorMessage;
  final LogType type;
  final LogStatus status;

  /// 请求耗时。pending 期间为 null。
  final Duration? duration;

  LogEntry({
    required this.requestId,
    required this.timestamp,
    required this.url,
    this.method = 'GET',
    this.statusCode,
    this.errorMessage,
    required this.type,
    this.status = LogStatus.pending,
    this.duration,
  });

  LogEntry copyWith({
    int? statusCode,
    String? errorMessage,
    LogStatus? status,
    Duration? duration,
  }) {
    return LogEntry(
      requestId: requestId,
      timestamp: timestamp,
      url: url,
      method: method,
      statusCode: statusCode ?? this.statusCode,
      errorMessage: errorMessage ?? this.errorMessage,
      type: type,
      status: status ?? this.status,
      duration: duration ?? this.duration,
    );
  }

  bool get isError =>
      status == LogStatus.failure ||
      errorMessage != null ||
      (statusCode != null && statusCode! >= 400);
}

class LogNotifier extends Notifier<List<LogEntry>> {
  /// 只留最近这么多条。日志是排查用的临时视图，不是审计流水；
  /// 无上限的话长时间浏览会把内存和列表渲染都拖垮。
  static const _maxEntries = 500;

  @override
  List<LogEntry> build() => [];

  /// 记录一条发起中的请求。
  void logRequest(LogEntry entry) {
    final next = [entry, ...state];
    state = next.length > _maxEntries ? next.sublist(0, _maxEntries) : next;
  }

  /// 用响应结果补全对应的 pending 记录。
  ///
  /// 找不到配对时（例如该请求发起于上次清空日志之前）就补一条独立记录，
  /// 丢掉响应信息比留个来源不明的孤儿条目更糟。
  void completeRequest({
    required int requestId,
    required LogStatus status,
    int? statusCode,
    String? errorMessage,
    LogEntry? fallback,
  }) {
    final index = state.indexWhere((e) => e.requestId == requestId);
    if (index < 0) {
      if (fallback != null) logRequest(fallback);
      return;
    }

    final origin = state[index];
    final updated = origin.copyWith(
      status: status,
      statusCode: statusCode,
      errorMessage: errorMessage,
      duration: DateTime.now().difference(origin.timestamp),
    );

    state = [...state.sublist(0, index), updated, ...state.sublist(index + 1)];
  }

  void clearLogs() {
    state = [];
  }
}

final logProvider = NotifierProvider<LogNotifier, List<LogEntry>>(() {
  return LogNotifier();
});
