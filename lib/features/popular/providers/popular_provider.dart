import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/models/e621_post.dart';
import '../../posts/repositories/post_repository.dart';

/// 热门榜单时间范围（E2）。
enum PopularScale { day, week, month }

extension PopularScaleX on PopularScale {
  String get param => switch (this) {
        PopularScale.day => 'day',
        PopularScale.week => 'week',
        PopularScale.month => 'month',
      };
}

/// 按时间范围拉取热门榜单。family 参数即 scale，切 Tab 各自缓存。
final popularPostsProvider =
    FutureProvider.family<List<E621Post>, PopularScale>((ref, scale) async {
  final repo = ref.watch(postRepositoryProvider);
  return repo.getPopular(scale: scale.param);
});
