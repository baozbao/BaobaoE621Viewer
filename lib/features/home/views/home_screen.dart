import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/post_card.dart';
import '../widgets/search_bar_widget.dart';
import '../../posts/providers/post_list_provider.dart';
import '../../settings/providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postListProvider.notifier).loadPosts(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postListProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      bottomNavigationBar: postState.posts.isNotEmpty || postState.page > 1
          ? Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).bottomAppBarTheme.color ?? Colors.black87,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: postState.page > 1 && !postState.isLoading
                        ? () {
                            ref.read(postListProvider.notifier).loadPosts(targetPage: postState.page - 1);
                          }
                        : null,
                    child: const Text('<'),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: postState.isLoading
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final textController = TextEditingController(text: postState.page.toString());
                                final maxPage = postState.totalPages > 0 ? postState.totalPages : null;
                                String? errorText;

                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: const Text('跳转页码'),
                                      content: TextField(
                                        controller: textController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: maxPage != null 
                                            ? '输入页码 (1 - $maxPage)' 
                                            : '输入页码',
                                          errorText: errorText,
                                        ),
                                        autofocus: true,
                                        onChanged: (_) {
                                          if (errorText != null) {
                                            setState(() => errorText = null);
                                          }
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('取消'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            final newPage = int.tryParse(textController.text);
                                            if (newPage == null || newPage < 1) {
                                              setState(() => errorText = '请输入有效的正整数');
                                              return;
                                            }
                                            if (maxPage != null && newPage > maxPage) {
                                              setState(() => errorText = '超出最大页码 ($maxPage)');
                                              return;
                                            }
                                            
                                            ref.read(postListProvider.notifier).loadPosts(targetPage: newPage);
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('跳转'),
                                        ),
                                      ],
                                    );
                                  }
                                );
                              },
                            );
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        postState.totalPages > 0
                          ? 'Page ${postState.page} / ${postState.totalPages}'
                          : 'Page ${postState.page}',
                        style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: postState.isLoading 
                        || postState.posts.length < settings.pageSize 
                        || (postState.totalPages > 0 && postState.page >= postState.totalPages)
                        ? null
                        : () {
                            ref.read(postListProvider.notifier).loadPosts(targetPage: postState.page + 1);
                          },
                    child: const Text('>'),
                  ),
                ],
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(postListProvider.notifier).loadPosts(isRefresh: true);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              toolbarHeight: 40,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const SizedBox(width: 4), // A little extra space from the left edge
                  const Text('E621 VIEWER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('By Baozbao', style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(150))),
                ],
              ),
              centerTitle: false,
              floating: true, // App bar will hide when scrolling down, and appear when scrolling up
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, size: 20),
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    await context.push('/settings');
                    // Reload posts to apply any settings changes (like blacklist or page size)
                    if (context.mounted) {
                      ref.read(postListProvider.notifier).loadPosts(isRefresh: true);
                    }
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SearchBarWidget(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Text('排序:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(width: 8),
                          _SortChip(label: '高分', sortParam: 'order:score', currentState: postState.currentSort),
                          const SizedBox(width: 4),
                          _SortChip(label: '收藏', sortParam: 'order:favcount', currentState: postState.currentSort),
                          const SizedBox(width: 4),
                          _SortChip(label: '最新', sortParam: 'order:id', currentState: postState.currentSort),
                          const SizedBox(width: 4),
                          _SortChip(label: '随机', sortParam: 'order:random', currentState: postState.currentSort),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (postState.isLoading && postState.posts.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (postState.error != null)
              SliverFillRemaining(child: Center(child: Text('Error: ${postState.error}')))
            else
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: settings.worksPerRow,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 100 / settings.previewHeight,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return PostCard(post: postState.posts[index]);
                    },
                    childCount: postState.posts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends ConsumerWidget {
  final String label;
  final String sortParam;
  final String currentState;

  const _SortChip({
    required this.label,
    required this.sortParam,
    required this.currentState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = currentState == sortParam;
    return ChoiceChip(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          softWrap: false,
        ),
      ),
      selected: isSelected,
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onSelected: (selected) {
        if (selected) {
          ref.read(postListProvider.notifier).setSort(sortParam);
        }
      },
    );
  }
}
