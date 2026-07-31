import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 根因修复：Web/桌面默认 highlightStrategy=automatic，检测到鼠标后切到
  // traditional 模式，会给每个获焦/悬停的控件画一层来自 colorScheme.primary
  // 的状态层（在亮蓝 primary 下就是刺眼的蓝光）。强制 alwaysTouch 让 Web
  // 表现得和手机一样——不画任何焦点/悬停高亮，从源头消除蓝光。
  FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'E621 Viewer',
      theme: AppTheme.of(settings.themeVariant),
      // 主题切换瞬时完成：默认 AnimatedTheme 会用 200ms 对整棵树做颜色插值，
      // 切主题时全屏渐变重建（Web 上平台视图图片还会跟着重建），就是那股延迟感。
      // 归零后切换干脆利落，没有中间过渡色。
      themeAnimationDuration: Duration.zero,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

