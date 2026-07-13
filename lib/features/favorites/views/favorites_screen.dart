import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/favorites_provider.dart';
import '../../posts/views/post_detail_screen.dart';
import '../../home/widgets/post_card.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/empty_state_view.dart';

/// 收藏页（B4）：离线展示已收藏作品，点击进详情（画廊源 = favorites）。
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.favoritesTitle)),
      body: favorites.isEmpty
          ? const EmptyStateView(
              icon: Icons.favorite_border,
              title: Strings.favoritesEmpty,
              hint: Strings.favoritesEmptyHint,
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: settings.worksPerRow,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 100 / settings.previewHeight,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) => PostCard(
                post: favorites[index],
                index: index,
                fixedHeight: true,
                onTap: () => context.push(
                  '/post',
                  extra: PostDetailArgs(index: index, source: PostDetailSource.favorites),
                ),
              ),
            ),
    );
  }
}
