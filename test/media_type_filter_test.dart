import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_e621_viewer/features/download/providers/download_list_provider.dart';

void main() {
  test('媒体类型过滤：空与双选不过滤', () {
    expect(mediaTypeFilterTags({}), isEmpty);
    expect(mediaTypeFilterTags({MediaType.image, MediaType.video}), isEmpty);
  });

  test('媒体类型过滤：仅图片 = 排除两种视频（gif 按图片保留）', () {
    expect(mediaTypeFilterTags({MediaType.image}), ['-type:webm', '-type:mp4']);
  });

  test('媒体类型过滤：仅视频 = 官方 OR 分组（~ 前缀贴在每个 metatag 上）', () {
    // 回归锁：写成 '( type:webm ~ type:mp4 )' 时 API 静默返回空。
    expect(mediaTypeFilterTags({MediaType.video}), [
      '( ~type:webm ~type:mp4 )',
    ]);
  });
}
