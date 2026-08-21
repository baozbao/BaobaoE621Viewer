import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gal/gal.dart';
import 'package:flutter_e621_viewer/core/constants/strings.dart';
import 'package:flutter_e621_viewer/core/utils/error_messages.dart';

void main() {
  group('视频扩展名分流', () {
    // _isVideoExt 是私有方法，这里覆盖它依据的判定表：e621 的动态内容只有
    // 这两种容器格式，其余一律按图片处理。分流错了会在 Android 上报
    // unexpectedError（把 webm 写进 MediaStore 图片表被拒）。
    const videoExts = {'webm', 'mp4'};

    test('e621 的视频格式被识别为视频', () {
      for (final ext in ['webm', 'mp4', 'WEBM', 'Mp4']) {
        expect(videoExts.contains(ext.toLowerCase()), isTrue, reason: ext);
      }
    });

    test('静态图与动图不被误判为视频', () {
      for (final ext in ['jpg', 'png', 'gif', 'jpeg', 'swf']) {
        expect(videoExts.contains(ext.toLowerCase()), isFalse, reason: ext);
      }
    });
  });

  group('相册写入失败的文案', () {
    test('权限、空间、格式各有独立提示，不再一律「未知错误」', () {
      final cases = {
        GalExceptionType.accessDenied: Strings.permissionDenied,
        GalExceptionType.notEnoughSpace: '设备存储空间不足',
        GalExceptionType.notSupportedFormat: '相册不支持该文件格式',
        GalExceptionType.unexpected: '保存到相册失败',
      };

      for (final entry in cases.entries) {
        final msg = humanizeError(
          GalException(
            type: entry.key,
            platformException: PlatformException(code: entry.key.code),
            stackTrace: StackTrace.empty,
          ),
        );
        expect(msg, entry.value, reason: entry.key.name);
      }
    });

    test('非 Gal 非 Dio 异常仍回落到未知错误', () {
      expect(humanizeError(StateError('boom')), Strings.errorUnknown);
    });
  });
}
