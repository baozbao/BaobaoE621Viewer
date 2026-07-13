// 核心格式化 / 错误映射的单元测试。
// 说明：整机启动冒烟测试会触发首页 loadPosts()，而沙箱内无网络时
// Dio 的连接超时 Timer 会残留，导致 '!timersPending' 断言失败；
// 需要整机测试时应对 dioProvider / repository 做 mock 覆盖后再 pump。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_e621_viewer/core/utils/post_format.dart';
import 'package:flutter_e621_viewer/core/utils/error_messages.dart';
import 'package:flutter_e621_viewer/core/constants/strings.dart';

void main() {
  group('PostFormat.compactCount', () {
    test('小于 1000 原样返回', () {
      expect(PostFormat.compactCount(0), '0');
      expect(PostFormat.compactCount(999), '999');
    });
    test('千位缩写为 k', () {
      expect(PostFormat.compactCount(1200), '1.2k');
      expect(PostFormat.compactCount(12000), '12.0k');
    });
    test('百万位缩写为 m', () {
      expect(PostFormat.compactCount(1200000), '1.2m');
    });
  });

  group('PostFormat.ratingColor', () {
    test('s/q/e 各有其色，未知走灰色', () {
      expect(PostFormat.ratingColor('s'), const Color(0xFF41C47D));
      expect(PostFormat.ratingColor('q'), const Color(0xFFFFB340));
      expect(PostFormat.ratingColor('e'), const Color(0xFFFF5D5D));
      expect(PostFormat.ratingColor('x'), Colors.grey);
    });
  });

  group('PostFormat.typeBadge', () {
    test('视频/GIF 有徽标，普通图片无', () {
      expect(PostFormat.typeBadge('webm'), '▶ WEBM');
      expect(PostFormat.typeBadge('gif'), 'GIF');
      expect(PostFormat.typeBadge('jpg'), isNull);
      expect(PostFormat.typeBadge('png'), isNull);
    });
  });

  group('humanizeError', () {
    test('超时映射为超时文案', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.receiveTimeout,
      );
      expect(humanizeError(e), Strings.errorTimeout);
    });
    test('连接错误映射为网络文案', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      );
      expect(humanizeError(e), Strings.errorNetwork);
    });
    test('5xx 映射为服务器文案', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: RequestOptions(path: '/'), statusCode: 503),
      );
      expect(humanizeError(e), Strings.errorServer);
    });
    test('非 Dio 异常走未知文案', () {
      expect(humanizeError(Exception('boom')), Strings.errorUnknown);
    });
  });
}
