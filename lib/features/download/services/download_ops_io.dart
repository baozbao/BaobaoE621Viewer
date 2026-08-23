import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/log_service.dart';

/// 移动端（Android/iOS）：批量存相册。

Future<void> ensureAccess() async {
  if (!await Gal.hasAccess()) {
    final granted = await Gal.requestAccess();
    if (!granted) {
      throw Exception('storage permission denied');
    }
  }
}

bool _isVideo(String filename) {
  final lower = filename.toLowerCase();
  return lower.endsWith('.webm') || lower.endsWith('.mp4');
}

/// 下载单个文件到临时目录，再按类型写入相册指定 album，
/// 完成后清理临时文件。
Future<void> downloadOne(
  Dio dio,
  String url,
  String filename,
  String? album,
) async {
  final tempDir = await getTemporaryDirectory();
  final savePath = '${tempDir.path}/$filename';

  await dio.download(
    url,
    savePath,
    options: Options(extra: {AppLogInterceptor.typeKey: LogType.download}),
  );

  if (_isVideo(filename)) {
    await Gal.putVideo(savePath, album: album);
  } else {
    await Gal.putImage(savePath, album: album);
  }

  try {
    await File(savePath).delete();
  } catch (_) {
    // 临时文件清理失败不影响结果。
  }
}
