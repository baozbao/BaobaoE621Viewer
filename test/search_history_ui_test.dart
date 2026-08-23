import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_e621_viewer/core/constants/pref_keys.dart';
import 'package:flutter_e621_viewer/core/constants/strings.dart';
import 'package:flutter_e621_viewer/features/home/widgets/search_bar_widget.dart';
import 'package:flutter_e621_viewer/features/posts/providers/post_list_provider.dart';
import 'package:flutter_e621_viewer/features/settings/providers/settings_provider.dart';

void main() {
  late SharedPreferences prefs;

  Future<void> pump(WidgetTester tester, List<String> history) async {
    SharedPreferences.setMockInitialValues({
      if (history.isNotEmpty) PrefKeys.searchHistory: history,
    });
    prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: Scaffold(
            body: SearchBarWidget<PostListState>(
              stateProvider: postListProvider,
              displayTagsOf: (s) => s.displayTags,
              onSearch: (ref, q) =>
                  ref.read(postListProvider.notifier).search(q),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// 点开搜索框，展开历史下拉。
  Future<void> openDropdown(WidgetTester tester) async {
    await tester.tap(find.byType(SearchBar));
    await tester.pumpAndSettle();
  }

  testWidgets('点击输入框即弹出历史，即使框里带着当前生效的标签', (tester) async {
    await pump(tester, ['cat female', 'dog']);

    // 输入框初始带着 displayTags（默认 female + 默认排序）。
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'female order:score',
    );

    await openDropdown(tester);

    // 关键：不能因为框里有内容就去走标签补全，用户要看的是历史。
    expect(find.text('cat female'), findsOneWidget);
    expect(find.text('dog'), findsOneWidget);
  });

  testWidgets('历史为空时显示占位文案', (tester) async {
    await pump(tester, []);
    await openDropdown(tester);

    expect(find.text(Strings.noSearchHistory), findsOneWidget);
  });

  testWidgets('每条历史右侧有 x 删除按钮，带 tooltip', (tester) async {
    await pump(tester, ['cat female', 'dog']);
    await openDropdown(tester);

    // 用 tooltip 定位，别用 Icons.close —— 搜索视图自带的清除按钮也是这个图标。
    expect(find.byTooltip(Strings.removeSearchHistoryItem), findsNWidgets(2));
  });

  testWidgets('点 x 只删这条，下拉保持打开且不触发搜索', (tester) async {
    await pump(tester, ['cat female', 'dog']);
    await openDropdown(tester);

    final deleteButtons = find.byTooltip(Strings.removeSearchHistoryItem);
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // 就地刷新：不关掉重开也能看到变化。
    expect(find.text('cat female'), findsNothing);
    expect(find.text('dog'), findsOneWidget, reason: '其余条目不受影响');

    // 下拉仍开着（还能看到剩下那条的删除按钮）。
    expect(find.byTooltip(Strings.removeSearchHistoryItem), findsOneWidget);
    expect(prefs.getStringList(PrefKeys.searchHistory), ['dog']);
  });

  testWidgets('删到最后一条后显示空占位', (tester) async {
    await pump(tester, ['only']);
    await openDropdown(tester);

    await tester.tap(find.byTooltip(Strings.removeSearchHistoryItem));
    await tester.pumpAndSettle();

    expect(find.text(Strings.noSearchHistory), findsOneWidget);
  });

  testWidgets('点历史条目会触发搜索并写回输入框', (tester) async {
    await pump(tester, ['cat female']);
    await openDropdown(tester);

    await tester.tap(find.text('cat female'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'cat female order:score',
    );
  });

  testWidgets('历史列表有自己的滚动视图，条数多时可独立滚动', (tester) async {
    await pump(tester, List.generate(30, (i) => 'tag$i'));
    await openDropdown(tester);

    expect(find.byType(ListView), findsWidgets);

    // 滚它一段，确认列表自己动了（首项滚出视图）。
    await tester.drag(find.text('tag0'), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('在历史下拉里滑动不会带动下层的可滚动内容', (tester) async {
    SharedPreferences.setMockInitialValues({
      PrefKeys.searchHistory: List.generate(30, (i) => 'tag$i'),
    });
    prefs = await SharedPreferences.getInstance();

    // 下层放一个长列表，模拟首页的图片网格。
    final outerScroll = ScrollController();
    addTearDown(outerScroll.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: outerScroll,
              slivers: [
                SliverToBoxAdapter(
                  child: SearchBarWidget<PostListState>(
                    stateProvider: postListProvider,
                    displayTagsOf: (s) => s.displayTags,
                    onSearch: (ref, q) =>
                        ref.read(postListProvider.notifier).search(q),
                  ),
                ),
                SliverList.builder(
                  itemCount: 100,
                  itemBuilder: (c, i) =>
                      SizedBox(height: 80, child: Text('row$i')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await openDropdown(tester);
    final before = outerScroll.offset;

    // 在历史列表上滑动。
    await tester.drag(find.text('tag0'), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(outerScroll.offset, before, reason: '下层 CustomScrollView 不应跟着滚动');
  });

  testWidgets('下拉视图不铺满全屏，高度约为屏高 35%', (tester) async {
    await pump(tester, List.generate(30, (i) => 'tag$i'));

    final anchor = tester.widget<SearchAnchor>(find.byType(SearchAnchor));
    expect(anchor.isFullScreen, isFalse, reason: '窄屏默认全屏，必须显式关掉');

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(
      anchor.viewConstraints?.maxHeight,
      closeTo(screenHeight * 0.35, 1.0),
    );
  });

  testWidgets('下拉视图有不透明背景，底层内容不会透上来', (tester) async {
    await pump(tester, ['cat female']);

    final anchor = tester.widget<SearchAnchor>(find.byType(SearchAnchor));
    expect(anchor.viewBackgroundColor, isNotNull);
    expect(anchor.viewBackgroundColor!.a, 1.0, reason: '必须完全不透明');
  });

  testWidgets('长标签串截断而不溢出', (tester) async {
    await pump(tester, ['a' * 200]);
    await openDropdown(tester);

    final text = tester.widget<Text>(find.text('a' * 200));
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.maxLines, 1);
    expect(tester.takeException(), isNull, reason: '不应有 overflow 报错');
  });

  testWidgets('历史文字左对齐', (tester) async {
    await pump(tester, ['cat female']);
    await openDropdown(tester);

    final align = tester.widget<Align>(
      find
          .ancestor(of: find.text('cat female'), matching: find.byType(Align))
          .first,
    );
    expect(align.alignment, Alignment.centerLeft);
  });

  testWidgets('旧数据里的同集合重复项在打开时已收敛为一条', (tester) async {
    await pump(tester, ['female cat', 'cat female', 'dog']);
    await openDropdown(tester);

    expect(find.text('female cat'), findsOneWidget);
    expect(find.text('cat female'), findsNothing);
    expect(find.text('dog'), findsOneWidget);
  });
}
