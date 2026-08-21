import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_e621_viewer/core/constants/pref_keys.dart';
import 'package:flutter_e621_viewer/features/search/providers/search_history_provider.dart';
import 'package:flutter_e621_viewer/features/settings/providers/settings_provider.dart';

void main() {
  Future<ProviderContainer> containerWith(List<String> stored) async {
    SharedPreferences.setMockInitialValues({
      if (stored.isNotEmpty) PrefKeys.searchHistory: stored,
    });
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  group('normalizeQuery', () {
    test('顺序不同的标签得到同一个 key', () {
      expect(normalizeQuery('female cat'), normalizeQuery('cat female'));
    });

    test('大小写不同得到同一个 key（e621 标签大小写不敏感）', () {
      expect(normalizeQuery('Female'), normalizeQuery('female'));
      expect(normalizeQuery('Female CAT'), normalizeQuery('cat female'));
    });

    test('多余空白被忽略', () {
      expect(normalizeQuery('  female   cat  '), normalizeQuery('cat female'));
    });

    test('标签不同则 key 不同', () {
      expect(normalizeQuery('female cat'), isNot(normalizeQuery('female dog')));
    });

    test('重复标签折叠，不影响身份', () {
      expect(normalizeQuery('female female cat'), normalizeQuery('cat female'));
    });
  });

  group('addSearch', () {
    test('同集合不同顺序只保留一条，且显示最后输入的原文', () async {
      final c = await containerWith([]);
      final n = c.read(searchHistoryProvider.notifier);

      n.addSearch('female cat');
      n.addSearch('cat female');

      final history = c.read(searchHistoryProvider);
      expect(history.length, 1);
      expect(history.single, 'cat female', reason: '保留用户最后一次的写法');
      c.dispose();
    });

    test('同集合不同大小写只保留一条', () async {
      final c = await containerWith([]);
      final n = c.read(searchHistoryProvider.notifier);

      n.addSearch('Female');
      n.addSearch('female');

      expect(c.read(searchHistoryProvider).length, 1);
      c.dispose();
    });

    test('最近使用的排最前', () async {
      final c = await containerWith([]);
      final n = c.read(searchHistoryProvider.notifier);

      n.addSearch('a');
      n.addSearch('b');
      n.addSearch('c');

      expect(c.read(searchHistoryProvider), ['c', 'b', 'a']);
      c.dispose();
    });

    test('重新搜索旧条目会把它提到最前', () async {
      final c = await containerWith([]);
      final n = c.read(searchHistoryProvider.notifier);

      n.addSearch('a');
      n.addSearch('b');
      n.addSearch('a');

      expect(c.read(searchHistoryProvider), ['a', 'b']);
      c.dispose();
    });

    test('上限 30：搜 35 次后只留最近 30 条', () async {
      final c = await containerWith([]);
      final n = c.read(searchHistoryProvider.notifier);

      for (var i = 1; i <= 35; i++) {
        n.addSearch('tag$i');
      }

      final history = c.read(searchHistoryProvider);
      expect(history.length, 30);
      expect(history.first, 'tag35');
      expect(history.last, 'tag6', reason: '最早的 5 条被丢弃');
      c.dispose();
    });

    test('空输入与纯空白不入历史', () async {
      final c = await containerWith([]);
      final n = c.read(searchHistoryProvider.notifier);

      n.addSearch('');
      n.addSearch('   ');

      expect(c.read(searchHistoryProvider), isEmpty);
      c.dispose();
    });

    test('存储的是去掉首尾空白的文本', () async {
      final c = await containerWith([]);
      c.read(searchHistoryProvider.notifier).addSearch('  female  ');

      expect(c.read(searchHistoryProvider).single, 'female');
      c.dispose();
    });
  });

  group('removeSearch', () {
    test('删掉指定条目，其余不动', () async {
      final c = await containerWith([]);
      final n = c.read(searchHistoryProvider.notifier);
      n.addSearch('a');
      n.addSearch('b');
      n.addSearch('c');

      n.removeSearch('b');

      expect(c.read(searchHistoryProvider), ['c', 'a']);
      c.dispose();
    });

    test('按集合匹配：传入不同顺序也能删掉', () async {
      final c = await containerWith([]);
      final n = c.read(searchHistoryProvider.notifier);
      n.addSearch('female cat');

      n.removeSearch('cat female');

      expect(c.read(searchHistoryProvider), isEmpty);
      c.dispose();
    });
  });

  group('旧数据收敛', () {
    test('加载时把同集合的历史重复项合并为一条', () async {
      final c = await containerWith(['female cat', 'cat female', 'dog']);

      final history = c.read(searchHistoryProvider);
      expect(history, ['female cat', 'dog'], reason: '保留先出现的（更近的）');
      c.dispose();
    });

    test('加载时把超出上限的旧数据裁到 30 条', () async {
      final stored = List.generate(40, (i) => 'tag$i');
      final c = await containerWith(stored);

      expect(c.read(searchHistoryProvider).length, 30);
      c.dispose();
    });

    test('收敛结果会回写，不是每次加载都重算', () async {
      SharedPreferences.setMockInitialValues({
        PrefKeys.searchHistory: ['female cat', 'cat female'],
      });
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      c.read(searchHistoryProvider); // 触发 build

      expect(prefs.getStringList(PrefKeys.searchHistory), ['female cat']);
      c.dispose();
    });

    test('干净的数据不触发无谓回写', () async {
      final c = await containerWith(['a', 'b']);
      expect(c.read(searchHistoryProvider), ['a', 'b']);
      c.dispose();
    });
  });

  group('clearHistory', () {
    test('清空后列表为空且存储被移除', () async {
      final c = await containerWith(['a', 'b']);
      c.read(searchHistoryProvider.notifier).clearHistory();

      expect(c.read(searchHistoryProvider), isEmpty);
      c.dispose();
    });
  });
}
