import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_e621_viewer/core/routing/app_router.dart';
import 'package:flutter_e621_viewer/core/widgets/scaffold_with_nav_bar.dart';
import 'package:flutter_e621_viewer/features/settings/providers/settings_provider.dart';

/// 设置 tab 是配置入口，每次进入都该落在设置首页，而不是上次停留的子页。
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('从别的 tab 切回设置时回到设置首页，而不是上次的子页', (tester) async {
    final router = await pumpApp(tester);

    // 进设置 → 深入子页 → 切走 → 再切回。
    router.go('/settings');
    await tester.pumpAndSettle();
    router.go('/settings/logs');
    await tester.pumpAndSettle();
    expect(currentPath(router), '/settings/logs');

    // 用底栏切到浏览，再切回设置（走的是 _onTap → goBranch 这条真实路径）。
    await tapBranch(tester, 0);
    await tapBranch(tester, 3);

    expect(
      currentPath(router),
      '/settings',
      reason: '切回设置 tab 后仍停在子页，应该重置到设置首页',
    );
  });

  test('只有设置分支强制回根，其他分支保留自己的栈', () {
    // 直接验证 _onTap 传给 goBranch 的 initialLocation 决策，不渲染整页。
    // 渲染路径下 flutter test 的 Ahem 字体会把中文按方块排版，
    // 空态提示折成十几行撑出竖向溢出，与导航逻辑无关。
    final resets = ScaffoldWithNavBar.shouldResetBranch;

    expect(resets(3, 0), isTrue, reason: '从浏览切到设置应重置到设置首页');
    expect(resets(3, 3), isTrue, reason: '重复点设置应回设置首页');
    expect(resets(0, 3), isFalse, reason: '切到浏览应保留浏览自己的栈');
    expect(resets(1, 0), isFalse, reason: '切到热门应保留热门自己的栈');
    expect(resets(2, 1), isFalse, reason: '切到收藏应保留收藏自己的栈');
    expect(resets(0, 0), isTrue, reason: '重复点当前 tab 应回该分支根路由');
  });

  testWidgets('设置分支下标常量与底栏中设置项的实际位置一致', (tester) async {
    // ScaffoldWithNavBar 里用了硬编码下标，分支顺序若变动必须在这里暴露出来。
    await pumpApp(tester);

    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    final settingsIndex = bar.destinations.indexWhere(
      (d) => d is NavigationDestination && d.label == '设置',
    );
    expect(settingsIndex, 3, reason: '设置不在下标 3，需同步更新重置逻辑里的常量');
  });
}

/// 挂载真实路由 + 底栏，返回 router 供断言当前位置。
///
/// 视口必须在第一帧之前设好：默认 800x600 装不下空态那一列内容，
/// 会冒出与导航无关的溢出告警，把 pumpAndSettle 的异常池搞脏。
Future<GoRouter> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  final router = container.read(routerProvider);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

String currentPath(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;

/// 点击底栏第 index 个 tab。
Future<void> tapBranch(WidgetTester tester, int index) async {
  final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
  bar.onDestinationSelected!(index);
  await tester.pumpAndSettle();
}
