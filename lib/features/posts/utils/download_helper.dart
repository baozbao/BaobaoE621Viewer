import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/e621_post.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/strings.dart';
import '../../../core/services/log_service.dart';
import '../../../core/utils/error_messages.dart';
import '../../../core/utils/post_format.dart';

/// 下载工具（B5）：走全局 [dioProvider]（带 UA / 日志拦截器），
/// 带进度反馈、画质选择、完成/失败提示。
class DownloadHelper {
  const DownloadHelper._();

  /// 弹出画质选择底部弹层：原图 / 采样图（带各自体积）。
  static void showDownloadSheet(
    BuildContext context,
    WidgetRef ref,
    E621Post post,
  ) {
    if (post.file.url == null) return;

    final originalUrl = post.file.url!;
    final sampleUrl = post.preview.url; // 采样/预览图（体积小）

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                Strings.downloadChooseQuality,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.high_quality),
              title: const Text(Strings.downloadOriginal),
              subtitle: Text(
                '${post.file.ext.toUpperCase()} · ${PostFormat.fileSize(post.file.size)}',
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _startDownload(
                  context,
                  ref,
                  originalUrl,
                  '${post.id}.${post.file.ext}',
                  isVideo: _isVideoExt(post.file.ext),
                );
              },
            ),
            if (sampleUrl != null)
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text(Strings.downloadSample),
                subtitle: Text('${post.preview.width}x${post.preview.height}'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  // 采样图恒为静态图，即使原帖是视频也一样。
                  _startDownload(
                    context,
                    ref,
                    sampleUrl,
                    '${post.id}_sample.jpg',
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// e621 的动态内容格式。相册（Android MediaStore / iOS Photos）按图片与
  /// 视频分表存放，存错表会直接抛异常，所以下载前必须按扩展名分流。
  static bool _isVideoExt(String ext) {
    const videoExts = {'webm', 'mp4'};
    return videoExts.contains(ext.toLowerCase());
  }

  static Future<void> _startDownload(
    BuildContext context,
    WidgetRef ref,
    String url,
    String filename, {
    bool isVideo = false,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    if (kIsWeb) {
      _snack(messenger, Strings.downloadWebDisabled);
      return;
    }

    try {
      if (!await Gal.hasAccess()) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          _snack(messenger, Strings.permissionDenied);
          return;
        }
      }

      // 进度用一个可刷新的 SnackBar 表达。
      final progress = ValueNotifier<double>(0);
      final controller = messenger.showSnackBar(
        SnackBar(
          duration: const Duration(minutes: 5),
          content: ValueListenableBuilder<double>(
            valueListenable: progress,
            builder: (context, value, child) => Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: value > 0 ? value : null,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${Strings.downloading} ${(value * 100).toStringAsFixed(0)}%',
                ),
              ],
            ),
          ),
        ),
      );

      final dio = ref.read(dioProvider);
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/$filename';

      await dio.download(
        url,
        savePath,
        // 在日志里和普通查询区分开：下载动辄几十 MB，混在 API 请求里
        // 会把真正要看的查询记录淹掉。
        options: Options(extra: {AppLogInterceptor.typeKey: LogType.download}),
        onReceiveProgress: (received, total) {
          if (total > 0) progress.value = received / total;
        },
      );
      // 视频必须走 putVideo：Gal.putImage 在 Android 上会把文件写进
      // MediaStore 的图片表，webm/mp4 因类型不匹配被拒，报 unexpectedError。
      if (isVideo) {
        await Gal.putVideo(savePath);
      } else {
        await Gal.putImage(savePath);
      }

      controller.close();
      progress.dispose();
      _snack(messenger, Strings.downloadSaved);
    } catch (e) {
      messenger.hideCurrentSnackBar();
      _snack(messenger, '${Strings.downloadFailed}: ${humanizeError(e)}');
    }
  }

  static void _snack(ScaffoldMessengerState messenger, String msg) {
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }
}
