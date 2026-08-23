import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_e621_viewer/features/home/widgets/search_bar_widget.dart';
import 'package:flutter_e621_viewer/features/posts/providers/post_list_provider.dart';
import 'package:flutter_e621_viewer/features/settings/providers/settings_provider.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpSearchBar(WidgetTester tester) async {
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

  testWidgets('空提交后输入框回填当前搜索条件，不会卡在空白无法刷新', (tester) async {
    await pumpSearchBar(tester);

    final field = find.byType(TextField).first;

    // 初始应显示 provider 里生效的标签（含默认排序）。
    expect(
      tester.widget<TextField>(field).controller?.text,
      'female order:score',
      reason: '初始输入框应反映 displayTags',
    );

    // 模拟冒烟测试：清空后提交空串。
    await tester.enterText(field, '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // 修复前这里是空串，导致之后每次提交都被拦掉、界面刷不出来。
    expect(
      tester.widget<TextField>(field).controller?.text,
      'female order:score',
      reason: '空提交被拒后应回填 displayTags，保持 UI 与 provider 同步',
    );
  });

  testWidgets('点击 X 清除按钮会真正清空搜索条件并刷新', (tester) async {
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(
              home: Scaffold(
                body: SearchBarWidget<PostListState>(
                  stateProvider: postListProvider,
                  displayTagsOf: (s) => s.displayTags,
                  onSearch: (ref, q) =>
                      ref.read(postListProvider.notifier).search(q),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 模拟从详情页加 tag 后回到主页：provider 里已有 FNAF。
    container.read(postListProvider.notifier).search('fnaf');
    await tester.pumpAndSettle();

    expect(
      container.read(postListProvider).currentTags,
      'fnaf',
      reason: '前置：搜索条件应为 fnaf',
    );

    // 点 X。
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(
      container.read(postListProvider).currentTags,
      '',
      reason: '点 X 后实际请求的 tag 应被清空',
    );
  });

  testWidgets('空提交不改变 provider 里的搜索条件', (tester) async {
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(
              home: Scaffold(
                body: SearchBarWidget<PostListState>(
                  stateProvider: postListProvider,
                  displayTagsOf: (s) => s.displayTags,
                  onSearch: (ref, q) =>
                      ref.read(postListProvider.notifier).search(q),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final before = container.read(postListProvider).currentTags;

    await tester.enterText(find.byType(TextField).first, '');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(
      container.read(postListProvider).currentTags,
      before,
      reason: '空输入不应把搜索条件重置掉',
    );
  });
}
