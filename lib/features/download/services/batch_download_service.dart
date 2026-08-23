import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../posts/models/e621_post.dart';
import 'download_ops_io.dart'
    if (dart.library.js_interop) 'download_ops_web.dart'
    as ops;

/// 批量下载进度（可在对话框里监听）。
class BatchProgress extends ChangeNotifier {
  int done = 0;
  int total = 0;
  int failed = 0;
  bool cancelled = false;

  void reset(int totalCount) {
    done = 0;
    total = totalCount;
    failed = 0;
    cancelled = false;
    notifyListeners();
  }

  void mark({int? done, int? failed}) {
    if (done != null) this.done = done;
    if (failed != null) this.failed = failed;
    notifyListeners();
  }

  void cancel() {
    cancelled = true;
    notifyListeners();
  }
}

class BatchDownloadResult {
  const BatchDownloadResult({
    required this.done,
    required this.failed,
    required this.cancelled,
    this.accessDenied = false,
  });

  final int done;
  final int failed;
  final bool cancelled;
  final bool accessDenied;
}

/// 批量下载服务。
class BatchDownloadService {
  const BatchDownloadService._();

  /// 相册文件夹名：BaobaoFlutter/{前三个搜索标签}_{yyyy-MM-dd}。
  /// 标签取用户标签（不含 order:/rating:），不足 3 个全用，没有则 'all'。
  static String albumFolder(String currentTags, DateTime now) {
    final tags = currentTags
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .where((s) => !s.startsWith('order:') && !s.startsWith('rating:'))
        .take(3)
        .toList();
    final base = tags.isEmpty ? 'all' : tags.join('_');
    final safe = base.replaceAll(RegExp(r'[\\/:*?"<>|\s]'), '_');
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return 'BaobaoFlutter/${safe}_$date';
  }

  /// 决定单个帖子的下载地址与文件名（{id}.{ext}）。
  /// webmToMp4 开启时，视频走转码 mp4（无转码则回退原文件，扩展名随实际 URL）。
  static ({String url, String filename})? resolve(
    E621Post post,
    bool webmToMp4,
  ) {
    final ext = post.file.ext.toLowerCase();
    if (webmToMp4 && (ext == 'webm' || ext == 'mp4')) {
      final u = post.bestVideoUrl;
      if (u == null) return null;
      return (url: u, filename: '${post.id}.${_extFromUrl(u)}');
    }
    final u = post.file.url;
    if (u == null) return null;
    return (url: u, filename: '${post.id}.${post.file.ext}');
  }

  static String _extFromUrl(String url) {
    final clean = url.split('?').first;
    final dot = clean.lastIndexOf('.');
    if (dot < 0) return 'bin';
    return clean.substring(dot + 1).toLowerCase();
  }

  /// 顺序执行批量下载。[album] 仅移动端使用（Web 忽略）。
  static Future<BatchDownloadResult> run({
    required Dio dio,
    required List<E621Post> posts,
    required bool webmToMp4,
    String? album,
    required BatchProgress progress,
  }) async {
    progress.reset(posts.length);

    if (!kIsWeb) {
      try {
        await ops.ensureAccess();
      } catch (_) {
        return BatchDownloadResult(
          done: 0,
          failed: posts.length,
          cancelled: false,
          accessDenied: true,
        );
      }
    }

    for (final post in posts) {
      if (progress.cancelled) break;

      final dl = resolve(post, webmToMp4);
      if (dl == null) {
        progress.mark(failed: progress.failed + 1);
        continue;
      }

      try {
        await ops.downloadOne(dio, dl.url, dl.filename, album);
      } catch (_) {
        progress.mark(failed: progress.failed + 1);
      }
      progress.mark(done: progress.done + 1);
    }

    return BatchDownloadResult(
      done: progress.done,
      failed: progress.failed,
      cancelled: progress.cancelled,
    );
  }
}
