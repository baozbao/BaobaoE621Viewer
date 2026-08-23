import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/pref_keys.dart';
import '../../posts/models/e621_post.dart';
import '../../settings/providers/settings_provider.dart';

/// 本地收藏（B4）：无需登录，把 post JSON 存进 shared_preferences。
/// 数据量大（几百条以上）时应迁移到 sqflite/hive，这里作为起步足够。
class FavoritesNotifier extends Notifier<List<E621Post>> {
  @override
  List<E621Post> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getStringList(PrefKeys.favorites) ?? [];
    final result = <E621Post>[];
    for (final s in raw) {
      try {
        result.add(E621Post.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        // 跳过损坏项
      }
    }
    return result;
  }

  bool isFavorited(int id) => state.any((p) => p.id == id);

  void toggle(E621Post post) {
    if (isFavorited(post.id)) {
      remove(post.id);
    } else {
      add(post);
    }
  }

  void add(E621Post post) {
    if (isFavorited(post.id)) return;
    state = [post, ...state];
    _persist();
  }

  void remove(int id) {
    state = state.where((p) => p.id != id).toList();
    _persist();
  }

  void _persist() {
    final raw = state.map((p) => jsonEncode(p.toJson())).toList();
    ref.read(sharedPreferencesProvider).setStringList(PrefKeys.favorites, raw);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<E621Post>>(
  () {
    return FavoritesNotifier();
  },
);
