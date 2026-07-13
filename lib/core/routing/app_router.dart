import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/settings/views/preview_settings_screen.dart';
import '../../features/settings/views/logs_screen.dart';
import '../../features/settings/views/blacklist_screen.dart';
import '../../features/posts/views/post_detail_screen.dart';
import '../../features/posts/models/e621_post.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
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
        ],
      ),
      GoRoute(
        path: '/post',
        builder: (context, state) {
          final post = state.extra as E621Post;
          return PostDetailScreen(post: post);
        },
      ),
    ],
  );
});
