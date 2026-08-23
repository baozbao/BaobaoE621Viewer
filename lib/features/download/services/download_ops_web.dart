import 'dart:js_interop';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;

/// Web：逐个触发浏览器下载。

Future<void> ensureAccess() async {}

String _mime(String ext) {
  switch (ext) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'webm':
      return 'video/webm';
    case 'mp4':
      return 'video/mp4';
    default:
      return 'application/octet-stream';
  }
}

Future<void> downloadOne(
  Dio dio,
  String url,
  String filename,
  String? album,
) async {
  try {
    // 优先 fetch + blob：能指定下载文件名（跨域要求 CDN 带 CORS 头）。
    final resp = await dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(minutes: 10),
      ),
    );
    final bytes = Uint8List.fromList(resp.data ?? const []);
    final buf = bytes.buffer.toJS;
    final ext = filename.contains('.')
        ? filename.split('.').last.toLowerCase()
        : 'bin';
    final blob = web.Blob([buf].toJS, web.BlobPropertyBag(type: _mime(ext)));
    final objectUrl = web.URL.createObjectURL(blob);
    final a = web.HTMLAnchorElement()
      ..href = objectUrl
      ..download = filename
      ..style.display = 'none';
    web.document.body?.append(a);
    a.click();
    a.remove();
    Future.delayed(const Duration(seconds: 30), () {
      web.URL.revokeObjectURL(objectUrl);
    });
  } catch (_) {
    // CORS 失败等：退化为直接链接（文件名可能变成服务器返回的 md5 名）。
    final a = web.HTMLAnchorElement()
      ..href = url
      ..download = filename
      ..target = '_blank'
      ..style.display = 'none';
    web.document.body?.append(a);
    a.click();
    a.remove();
  }

  // 连续下载间隔，避免被浏览器判定为弹窗拦截。
  await Future<void>.delayed(const Duration(milliseconds: 600));
}
