import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/strings.dart';
import '../theme/app_theme.dart';

/// 底部一级导航容器（E1）。承载 浏览 / 热门 / 收藏 / 设置 四个 tab，
/// 每个 tab 有独立导航栈，切换不丢状态（由 StatefulShellRoute.indexedStack 提供）。
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  /// 设置分支的下标。设置是配置入口，不是浏览流，没有"上次看到哪"值得保留，
  /// 停在上次的子页（日志/黑名单/预览…）反而让人不知道自己在哪一层。
  static const settingsBranch = 3;

  /// 点 [target] 时是否重置该分支到根路由（当前在 [current]）。
  /// 重复点当前 tab 回根是常规行为；设置 tab 每次进入都回根。
  static bool shouldResetBranch(int target, int current) =>
      target == current || target == settingsBranch;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: shouldResetBranch(index, navigationShell.currentIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: navigationShell,
      // 顶部描边 + 上扬阴影：让底栏读起来是浮在内容之上的一层，
      // 而不是和最后一行卡片粘在一起。
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.surfaceBorder(light: light),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: light ? const Color(0x1F000000) : const Color(0x66000000),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          height: 58,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: Strings.browse,
            ),
            NavigationDestination(
              icon: Icon(Icons.local_fire_department_outlined),
              selectedIcon: Icon(Icons.local_fire_department),
              label: Strings.popular,
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: Strings.favorites,
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Strings.settings,
            ),
          ],
        ),
      ),
    );
  }
}
