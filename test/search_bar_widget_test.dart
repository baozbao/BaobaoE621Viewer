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
        child: const MaterialApp(home: Scaffold(body: SearchBarWidget())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('空提交后输入框回填当前搜索条件，不会卡在空白无法刷新', (tester) async {
    await pumpSearchBar(tester);

    final field = find.byType(TextField).first;

    // 初始应显示 provider 里生效的标签。
    expect(
      tester.widget<TextField>(field).controller?.text,
      'female',
      reason: '初始输入框应反映 currentTags',
    );

    // 模拟冒烟测试：清空后提交空串。
    await tester.enterText(field, '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // 修复前这里是空串，导致之后每次提交都被拦掉、界面刷不出来。
    expect(
      tester.widget<TextField>(field).controller?.text,
      'female',
      reason: '空提交被拒后应回填 currentTags，保持 UI 与 provider 同步',
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
            return const MaterialApp(home: Scaffold(body: SearchBarWidget()));
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
