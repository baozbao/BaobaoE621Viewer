import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/popular/views/popular_screen.dart';
import '../../features/favorites/views/favorites_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/settings/views/preview_settings_screen.dart';
import '../../features/settings/views/logs_screen.dart';
import '../../features/settings/views/blacklist_screen.dart';
import '../../features/history/views/history_screen.dart';
import '../../features/posts/views/post_detail_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/browse',
    routes: [
      // 一级导航壳：4 个 tab 各自独立导航栈（E1）。
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/browse',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/popular',
                builder: (context, state) => const PopularScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'preview',
                    builder: (context, state) => const PreviewSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'logs',
                    builder: (context, state) => const LogsScreen(),
                  ),
                  GoRoute(
                    path: 'blacklist',
                    builder: (context, state) => const BlacklistScreen(),
                  ),
                  GoRoute(
                    path: 'history',
                    builder: (context, state) => const HistoryScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // 详情页在根导航栈上打开，覆盖底部导航（全屏画廊）。
      GoRoute(
        path: '/post',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final args = state.extra as PostDetailArgs;
          return PostDetailScreen(args: args);
        },
      ),
    ],
  );
});
