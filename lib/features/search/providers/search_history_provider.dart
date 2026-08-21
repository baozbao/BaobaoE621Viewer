import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/pref_keys.dart';
import '../../settings/providers/settings_provider.dart';

/// 把查询串规范化成「标签集合」身份（PRD-028）。
///
/// e621 的标签顺序不影响搜索结果，大小写也不敏感 —— `female cat`、
/// `cat female`、`Female Cat` 搜出来是同一批图，历史里就该只占一条。
/// 拆分 → 小写 → 去重 → 排序 → 重连，得到可直接比对的 key。
///
/// 只用于比对，不用于显示：展示保留用户最后一次输入的原文，因为
/// `order:score female` 比字母序的 `female order:score` 更贴近他的心智。
String normalizeQuery(String query) {
  final tokens =
      query
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty)
          .map((t) => t.toLowerCase())
          .toSet()
          .toList()
        ..sort();
  return tokens.join(' ');
}

class SearchHistoryNotifier extends Notifier<List<String>> {
  static const _maxEntries = 30;

  @override
  List<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getStringList(PrefKeys.searchHistory) ?? [];

    // 旧数据可能含同集合不同顺序的重复项（老版本按精确字符串去重），
    // 也可能超出当前上限。加载时收敛一次并回写，否则这些条目会一直留着。
    final cleaned = _dedupe(stored);
    if (cleaned.length != stored.length || !_sameOrder(cleaned, stored)) {
      prefs.setStringList(PrefKeys.searchHistory, cleaned);
    }
    return cleaned;
  }

  /// 按规范化 key 去重，保留每个 key 首次出现的那条（即最近使用的），
  /// 并裁到上限。
  static List<String> _dedupe(List<String> items) {
    final seen = <String>{};
    final out = <String>[];
    for (final item in items) {
      if (item.trim().isEmpty) continue;
      if (seen.add(normalizeQuery(item))) out.add(item);
    }
    return out.length > _maxEntries ? out.sublist(0, _maxEntries) : out;
  }

  static bool _sameOrder(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void addSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final key = normalizeQuery(trimmed);

    // 移除所有同集合的旧条目再插队首。用 removeWhere 而非 remove：
    // 后者只删第一个匹配，同集合的其他写法会残留。
    final next = List<String>.from(state)
      ..removeWhere((e) => normalizeQuery(e) == key)
      ..insert(0, trimmed);

    // 一次裁到位。原先只 removeLast() 一次，历史超限不止一条时砍不回来。
    state = next.length > _maxEntries ? next.sublist(0, _maxEntries) : next;
    _persist();
  }

  /// 删除单条。按规范化 key 匹配，保证「显示的这条」一定被删掉，
  /// 即使调用方传来的大小写或顺序与存储的不完全一致。
  void removeSearch(String query) {
    final key = normalizeQuery(query);
    state = List<String>.from(state)
      ..removeWhere((e) => normalizeQuery(e) == key);
    _persist();
  }

  void clearHistory() {
    state = [];
    ref.read(sharedPreferencesProvider).remove(PrefKeys.searchHistory);
  }

  void _persist() {
    ref
        .read(sharedPreferencesProvider)
        .setStringList(PrefKeys.searchHistory, state);
  }
}

final searchHistoryProvider =
    NotifierProvider<SearchHistoryNotifier, List<String>>(() {
      return SearchHistoryNotifier();
    });
