import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_e621_viewer/core/network/api_client.dart';
import 'package:flutter_e621_viewer/core/services/log_service.dart';

/// 用假的 adapter 截住网络层，让请求走完整的拦截器链但不真的发包。
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.statusCode = 200, this.throwError = false});

  final int statusCode;
  final bool throwError;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? stream,
    Future<void>? cancelFuture,
  ) async {
    if (throwError) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'boom',
      );
    }
    return ResponseBody.fromString(
      '[]',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late ProviderContainer container;
  late LogNotifier notifier;
  late Dio dio;

  void setUpDio({bool throwError = false, int statusCode = 200}) {
    container = ProviderContainer();
    notifier = container.read(logProvider.notifier);
    dio = Dio(BaseOptions(baseUrl: 'https://e621.net'))
      ..httpClientAdapter = _FakeAdapter(
        statusCode: statusCode,
        throwError: throwError,
      )
      ..interceptors.add(AppLogInterceptor(notifier));
  }

  tearDown(() => container.dispose());

  test('成功请求只留一条记录，含状态码与耗时', () async {
    setUpDio();
    await dio.get('/posts.json');

    final logs = container.read(logProvider);
    expect(logs.length, 1, reason: 'onRequest 与 onResponse 应合并成一条');
    expect(logs.single.status, LogStatus.success);
    expect(logs.single.statusCode, 200);
    expect(logs.single.duration, isNotNull);
    expect(logs.single.url, contains('/posts.json'));
  });

  test('失败请求也合并成一条，带错误信息', () async {
    setUpDio(throwError: true);
    await expectLater(dio.get('/posts.json'), throwsA(isA<DioException>()));

    final logs = container.read(logProvider);
    expect(logs.length, 1);
    expect(logs.single.status, LogStatus.failure);
    expect(logs.single.isError, isTrue);
  });

  test('4xx 被判为错误', () async {
    setUpDio(statusCode: 422);
    await expectLater(dio.get('/posts.json'), throwsA(isA<DioException>()));

    expect(container.read(logProvider).single.isError, isTrue);
  });

  test('未标记的请求归为查询类', () async {
    setUpDio();
    await dio.get('/posts.json');

    expect(container.read(logProvider).single.type, LogType.api);
  });

  test('extra 里标记的类型被采纳（下载 / 补全各自归类）', () async {
    setUpDio();

    await dio.get(
      '/file.webm',
      options: Options(extra: {AppLogInterceptor.typeKey: LogType.download}),
    );
    await dio.get(
      '/tags/autocomplete.json',
      options: Options(
        extra: {AppLogInterceptor.typeKey: LogType.autocomplete},
      ),
    );

    final logs = container.read(logProvider);
    expect(logs.where((e) => e.type == LogType.download).length, 1);
    expect(logs.where((e) => e.type == LogType.autocomplete).length, 1);
    expect(logs.where((e) => e.type == LogType.api), isEmpty);
  });

  test('多个并发请求各自配对，不会串号', () async {
    setUpDio();
    await Future.wait([
      dio.get('/a.json'),
      dio.get('/b.json'),
      dio.get('/c.json'),
    ]);

    final logs = container.read(logProvider);
    expect(logs.length, 3, reason: '三个请求应是三条记录，不多不少');
    expect(logs.every((e) => e.status == LogStatus.success), isTrue);
    expect(logs.map((e) => e.requestId).toSet().length, 3, reason: 'id 不应重复');
  });
}
