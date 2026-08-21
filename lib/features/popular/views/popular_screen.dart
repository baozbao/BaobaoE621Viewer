import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../providers/popular_provider.dart';
import '../../posts/views/post_detail_screen.dart';
import '../../home/widgets/post_card.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/empty_state_view.dart';

/// 热门页（E2）：日/周/月三榜，复用现有网格与 PostCard。
class PopularScreen extends ConsumerStatefulWidget {
  const PopularScreen({super.key});

  @override
  ConsumerState<PopularScreen> createState() => _PopularScreenState();
}

class _PopularScreenState extends ConsumerState<PopularScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  static const _scales = [
    PopularScale.day,
    PopularScale.week,
    PopularScale.month,
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _scales.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.popularTitle),
        centerTitle: true,
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: Strings.popularDay),
            Tab(text: Strings.popularWeek),
            Tab(text: Strings.popularMonth),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [for (final scale in _scales) _PopularTab(scale: scale)],
      ),
    );
  }
}

class _PopularTab extends ConsumerWidget {
  final PopularScale scale;
  const _PopularTab({required this.scale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(popularPostsProvider(scale));
    final settings = ref.watch(settingsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyStateView(
        icon: Icons.cloud_off,
        title: e.toString(),
        actionLabel: Strings.retry,
        onAction: () => ref.invalidate(popularPostsProvider(scale)),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return const EmptyStateView(
            icon: Icons.local_fire_department_outlined,
            title: Strings.emptyResultTitle,
          );
        }
        final masonry = settings.layoutMode == LayoutMode.masonry;
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(popularPostsProvider(scale)),
          child: masonry
              ? MasonryGridView.count(
                  padding: const EdgeInsets.all(8),
                  crossAxisCount: settings.worksPerRow,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: posts.length,
                  itemBuilder: (context, index) => PostCard(
                    post: posts[index],
                    index: index,
                    fixedHeight: false,
                    onTap: () => context.push(
                      '/post',
                      extra: PostDetailArgs(
                        index: index,
                        source: PostDetailSource.popular,
                        scale: scale,
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: settings.worksPerRow,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 100 / settings.previewHeight,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) => PostCard(
                    post: posts[index],
                    index: index,
                    fixedHeight: true,
                    onTap: () => context.push(
                      '/post',
                      extra: PostDetailArgs(
                        index: index,
                        source: PostDetailSource.popular,
                        scale: scale,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
