import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/post_card.dart';
import '../widgets/post_card_skeleton.dart';
import '../widgets/search_bar_widget.dart';
import '../../posts/providers/post_list_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/post_format.dart';
import '../../../core/widgets/empty_state_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scroll = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postListProvider.notifier).loadPosts(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 返回顶部 FAB：滚过约两屏后出现（A6）。
    final show = _scroll.offset > 1200;
    if (show != _showFab) setState(() => _showFab = show);

    // 无限滚动：距底 800px 触发追加（A3）。
    final mode = ref.read(settingsProvider).browseMode;
    if (mode == BrowseMode.infinite &&
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 800) {
      ref.read(postListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postListProvider);
    final settings = ref.watch(settingsProvider);
    final isPaged = settings.browseMode == BrowseMode.paged;

    return Scaffold(
      floatingActionButton: _showFab
          ? FloatingActionButton.small(
              tooltip: Strings.backToTop,
              onPressed: () => _scroll.animateTo(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              ),
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      bottomNavigationBar: isPaged ? _buildPaginationBar(postState, settings) : null,
      body: RefreshIndicator(
        onRefresh: () => ref.read(postListProvider.notifier).loadPosts(isRefresh: true),
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverAppBar(
              toolbarHeight: 40,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const SizedBox(width: 4),
                  const Text('E621 VIEWER',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('By Baozbao',
                      style: TextStyle(
                        fontSize: 10,
                        // A8:随主题走，不再硬编码白色。
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                      )),
                ],
              ),
              centerTitle: false,
              floating: true,
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SearchBarWidget(),
                  _buildSortRow(postState),
                  _buildRatingRow(postState),
                ],
              ),
            ),
            _buildContent(postState, settings),
            // 无限滚动底部加载指示（A3）。
            if (!isPaged && postState.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            if (!isPaged && postState.hasReachedEnd && postState.posts.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('已到底部', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortRow(PostListState postState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(Strings.sortLabel, style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(width: 8),
            _SortChip(label: Strings.sortScore, sortParam: 'order:score', current: postState.currentSort),
            const SizedBox(width: 4),
            _SortChip(label: Strings.sortFav, sortParam: 'order:favcount', current: postState.currentSort),
            const SizedBox(width: 4),
            _SortChip(label: Strings.sortNewest, sortParam: 'order:id', current: postState.currentSort),
            const SizedBox(width: 4),
            _SortChip(label: Strings.sortRank, sortParam: 'order:rank', current: postState.currentSort),
            const SizedBox(width: 4),
            _SortChip(label: Strings.sortRandom, sortParam: 'order:random', current: postState.currentSort),
          ],
        ),
      ),
    );
  }

  // 评级过滤 chips（A7）。
  Widget _buildRatingRow(PostListState postState) {
    final selected = postState.ratingFilters;
    Widget chip(String label, RatingFilter? r) {
      final isAll = r == null;
      final on = isAll ? selected.isEmpty : selected.contains(r);
      final color = r == null ? null : PostFormat.ratingColor(r.tag.split(':').last);
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: FilterChip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          selected: on,
          visualDensity: VisualDensity.compact,
          selectedColor: color?.withAlpha(60),
          checkmarkColor: color,
          onSelected: (_) {
            final notifier = ref.read(postListProvider.notifier);
            if (isAll) {
              notifier.clearRatingFilters();
            } else {
              notifier.toggleRating(r);
            }
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(Strings.ratingLabel, style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(width: 8),
            chip(Strings.ratingAll, null),
            chip(Strings.ratingSafe, RatingFilter.safe),
            chip(Strings.ratingQuestionable, RatingFilter.questionable),
            chip(Strings.ratingExplicit, RatingFilter.explicit),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(PostListState postState, AppSettings settings) {
    // 首次加载：骨架屏（A4）。
    if (postState.isLoading && postState.posts.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(8),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: settings.worksPerRow,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 100 / settings.previewHeight,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => const PostCardSkeleton(),
            childCount: settings.pageSize.clamp(8, 24),
          ),
        ),
      );
    }

    // 错误态（A5）。
    if (postState.error != null && postState.posts.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateView(
          icon: Icons.cloud_off,
          title: postState.error!,
          actionLabel: Strings.retry,
          onAction: () => ref.read(postListProvider.notifier).loadPosts(isRefresh: true),
        ),
      );
    }

    // 空结果态（A5）。
    if (!postState.isLoading && postState.posts.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateView(
          icon: Icons.search_off,
          title: Strings.emptyResultTitle,
          hint: Strings.emptyResultHint,
          actionLabel: Strings.clearSearch,
          onAction: () => ref.read(postListProvider.notifier).search(''),
        ),
      );
    }

    // 内容网格：瀑布流（A1）或等高网格。
    final masonry = settings.layoutMode == LayoutMode.masonry;
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: masonry
          ? SliverMasonryGrid.count(
              crossAxisCount: settings.worksPerRow,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childCount: postState.posts.length,
              itemBuilder: (context, index) => PostCard(
                post: postState.posts[index],
                index: index,
                fixedHeight: false,
              ),
            )
          : SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: settings.worksPerRow,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 100 / settings.previewHeight,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => PostCard(
                  post: postState.posts[index],
                  index: index,
                  fixedHeight: true,
                ),
                childCount: postState.posts.length,
              ),
            ),
    );
  }

  Widget _buildPaginationBar(PostListState postState, AppSettings settings) {
    if (postState.posts.isEmpty && postState.page <= 1) return const SizedBox.shrink();
    final canPrev = postState.page > 1 && !postState.isLoading;
    final canNext = !postState.isLoading &&
        postState.posts.length >= settings.pageSize &&
        !(postState.totalPages > 0 && postState.page >= postState.totalPages);

    return Material(
      // A8:随主题走，避免浅色模式下页码文字与深色底同色不可见。
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: canPrev
                ? () => ref.read(postListProvider.notifier).loadPosts(targetPage: postState.page - 1)
                : null,
            child: const Text('<'),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: postState.isLoading ? null : () => _showJumpDialog(postState),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                postState.totalPages > 0
                    ? 'Page ${postState.page} / ${postState.totalPages}'
                    : 'Page ${postState.page}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: canNext
                ? () => ref.read(postListProvider.notifier).loadPosts(targetPage: postState.page + 1)
                : null,
            child: const Text('>'),
          ),
        ],
      ),
      ),
    );
  }

  // 跳页对话框（A3:修复原先 TextEditingController 泄漏，改为 StatefulWidget 自管理）。
  void _showJumpDialog(PostListState postState) {
    final maxPage = postState.totalPages > 0 ? postState.totalPages : null;
    showDialog(
      context: context,
      builder: (context) => _JumpPageDialog(
        currentPage: postState.page,
        maxPage: maxPage,
        onJump: (page) => ref.read(postListProvider.notifier).loadPosts(targetPage: page),
      ),
    );
  }
}

class _SortChip extends ConsumerWidget {
  final String label;
  final String sortParam;
  final String current;

  const _SortChip({required this.label, required this.sortParam, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChoiceChip(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(label, style: const TextStyle(fontSize: 12), maxLines: 1, softWrap: false),
      ),
      selected: current == sortParam,
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onSelected: (selected) {
        if (selected) ref.read(postListProvider.notifier).setSort(sortParam);
      },
    );
  }
}

/// 跳页对话框：自管理 controller，修复原实现的内存泄漏（清单 A3）。
class _JumpPageDialog extends StatefulWidget {
  final int currentPage;
  final int? maxPage;
  final ValueChanged<int> onJump;

  const _JumpPageDialog({
    required this.currentPage,
    required this.maxPage,
    required this.onJump,
  });

  @override
  State<_JumpPageDialog> createState() => _JumpPageDialogState();
}

class _JumpPageDialogState extends State<_JumpPageDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentPage.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final newPage = int.tryParse(_controller.text);
    if (newPage == null || newPage < 1) {
      setState(() => _errorText = Strings.jumpPageInvalid);
      return;
    }
    if (widget.maxPage != null && newPage > widget.maxPage!) {
      setState(() => _errorText = '超出最大页码 (${widget.maxPage})');
      return;
    }
    widget.onJump(newPage);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(Strings.jumpPageTitle),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.maxPage != null
              ? '${Strings.jumpPageHint} (1 - ${widget.maxPage})'
              : Strings.jumpPageHint,
          errorText: _errorText,
        ),
        onChanged: (_) {
          if (_errorText != null) setState(() => _errorText = null);
        },
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(Strings.cancel)),
        ElevatedButton(onPressed: _submit, child: const Text(Strings.jump)),
      ],
    );
  }
}
