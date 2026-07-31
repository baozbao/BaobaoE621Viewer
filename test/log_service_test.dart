import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_e621_viewer/core/services/log_service.dart';

void main() {
  late ProviderContainer container;
  late LogNotifier notifier;

  setUp(() {
    container = ProviderContainer();
    notifier = container.read(logProvider.notifier);
  });

  tearDown(() => container.dispose());

  LogEntry entry(int id, {LogType type = LogType.api}) => LogEntry(
    requestId: id,
    timestamp: DateTime.now(),
    url: 'https://e621.net/posts.json?page=$id',
    type: type,
  );

  group('请求配对合并', () {
    test('响应回来时补全同一条记录，不新增条目', () {
      notifier.logRequest(entry(1));
      expect(container.read(logProvider).single.status, LogStatus.pending);

      notifier.completeRequest(
        requestId: 1,
        status: LogStatus.success,
        statusCode: 200,
      );

      final logs = container.read(logProvider);
      expect(logs.length, 1, reason: '配对成功不应产生第二条');
      expect(logs.single.status, LogStatus.success);
      expect(logs.single.statusCode, 200);
      expect(logs.single.duration, isNotNull, reason: '完成时应算出耗时');
    });

    test('失败请求带上错误信息与 isError 标记', () {
      notifier.logRequest(entry(7));
      notifier.completeRequest(
        requestId: 7,
        status: LogStatus.failure,
        errorMessage: 'connection errored',
      );

      final log = container.read(logProvider).single;
      expect(log.status, LogStatus.failure);
      expect(log.errorMessage, 'connection errored');
      expect(log.isError, isTrue);
    });

    test('未完成的请求停在 pending，便于发现卡住的调用', () {
      notifier.logRequest(entry(1));
      notifier.logRequest(entry(2));
      notifier.completeRequest(requestId: 2, status: LogStatus.success, statusCode: 200);

      final pending =
          container.read(logProvider).where((e) => e.status == LogStatus.pending);
      expect(pending.length, 1);
      expect(pending.single.requestId, 1);
    });

    test('找不到配对时用 fallback 补记，不静默丢弃响应', () {
      notifier.completeRequest(
        requestId: 99,
        status: LogStatus.success,
        statusCode: 200,
        fallback: entry(99),
      );

      expect(container.read(logProvider).length, 1);
    });

    test('没有 fallback 且配不上时不产生空记录', () {
      notifier.completeRequest(requestId: 99, status: LogStatus.success);
      expect(container.read(logProvider), isEmpty);
    });
  });

  group('容量与分类', () {
    test('超过上限后丢最旧的，保留最新 500 条', () {
      for (var i = 1; i <= 520; i++) {
        notifier.logRequest(entry(i));
      }

      final logs = container.read(logProvider);
      expect(logs.length, 500);
      expect(logs.first.requestId, 520, reason: '最新的在最前');
      expect(logs.last.requestId, 21, reason: '最旧的 20 条被丢弃');
    });

    test('不同类型各自保留，可用于筛选', () {
      notifier.logRequest(entry(1, type: LogType.api));
      notifier.logRequest(entry(2, type: LogType.download));
      notifier.logRequest(entry(3, type: LogType.autocomplete));

      final logs = container.read(logProvider);
      expect(logs.where((e) => e.type == LogType.download).length, 1);
      expect(logs.where((e) => e.type == LogType.autocomplete).length, 1);
      expect(logs.where((e) => e.type == LogType.api).length, 1);
    });

    test('清空后列表为空', () {
      notifier.logRequest(entry(1));
      notifier.clearLogs();
      expect(container.read(logProvider), isEmpty);
    });
  });
}
