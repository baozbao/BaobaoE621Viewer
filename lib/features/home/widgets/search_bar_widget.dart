import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/providers/search_history_provider.dart';
import '../../search/repositories/search_repository.dart';
import '../../posts/providers/post_list_provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/post_format.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({super.key});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  late final SearchController _controller;

  /// 历史列表自己的滚动控制器（PRD-028）。有了它这块区域的滚动才独立于
  /// 下层页面，否则手势会落到首页的 CustomScrollView 上。
  final ScrollController _historyScroll = ScrollController();

  /// 本次打开视图后用户是否敲过键盘。false 时优先展示历史 ——
  /// 输入框里带着当前生效的标签，不能仅凭「有内容」就去走标签补全。
  bool _userEdited = false;

  @override
  void initState() {
    super.initState();
    _controller = SearchController()
      ..text = ref.read(postListProvider).displayTags;
  }

  @override
  void dispose() {
    _historyScroll.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    // 空提交不改变搜索条件，但 SearchAnchor 的 closeView 已经把输入框刷成了
    // 空串。此时若直接 return，输入框显示空、provider 里还是旧标签，二者失同步：
    // 之后每次提交都是空串又被这里拦掉，界面看着能点却怎么都刷不出来，
    // 只有输入新词让 currentTags 真的变化才能恢复。所以要把输入框回填成
    // 当前实际生效的搜索条件，让 UI 始终反映真实状态。
    if (query.trim().isEmpty) {
      _controller.text = ref.read(postListProvider).displayTags;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      return;
    }
    ref.read(postListProvider.notifier).search(query);

    // 延迟更新历史：搜索视图关闭时有动画，此时若立即改历史 provider，
    // Riverpod 会尝试重建已卸载的 suggestionsBuilder，触发白屏崩溃。
    Future.delayed(const Duration(milliseconds: 300), () {
      ref.read(searchHistoryProvider.notifier).addSearch(query);
    });
  }

  /// 取输入里光标前的最后一个词（多标签组合搜索时只补全当前词）。
  String _lastToken(String text) {
    final parts = text.split(' ');
    return parts.isEmpty ? '' : parts.last;
  }

  /// 用补全结果替换最后一个词，并补一个空格，方便继续输入下一个标签。
  void _applyCompletion(String fullText, String tagName) {
    final parts = fullText.split(' ');
    if (parts.isEmpty) {
      _controller.text = '$tagName ';
    } else {
      parts[parts.length - 1] = tagName;
      _controller.text = '${parts.join(' ')} ';
    }
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 监听外部对搜索标签的修改（如从详情页点标签搜索）。
    ref.listen(postListProvider, (previous, next) {
      if (previous?.displayTags != next.displayTags &&
          _controller.text != next.displayTags) {
        _controller.text = next.displayTags;
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SearchAnchor(
        searchController: _controller,
        // 窄屏上 SearchAnchor 默认走全屏视图，此时给内容加的高度约束不起作用
        // （撑不满就留空白），必须显式关掉全屏并约束视图本身（PRD-028）。
        isFullScreen: false,
        viewConstraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.35,
        ),
        // 视图背景默认透明，不给色的话底层图片网格会从下面透上来。
        viewBackgroundColor: Theme.of(context).colorScheme.surface,
        viewElevation: 3,
        viewOnChanged: (_) {
          // 一旦敲键盘就切到标签补全。只置位不 setState：suggestionsBuilder
          // 本来就会因输入变化而重跑。
          _userEdited = true;
        },
        viewOnSubmitted: (value) {
          _controller.closeView(value);
          _submitSearch(value);
        },
        builder: (context, controller) {
          return SearchBar(
            controller: controller,
            // 每次点开重新从历史开始。注意必须自己调 openView：
            // 传了 onTap 就覆盖掉 SearchBar 默认的打开行为，漏掉这句点击会没反应。
            onTap: () {
              _userEdited = false;
              controller.openView();
            },
            constraints: const BoxConstraints(maxHeight: 44),
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0),
            ),
            onSubmitted: _submitSearch,
            leading: const Icon(Icons.search, size: 20),
            trailing: [
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  padding: EdgeInsets.zero,
                  onPressed: controller.clear,
                ),
            ],
          );
        },
        suggestionsBuilder: (context, controller) async {
          // 刚点开还没动键盘时先给历史（PRD-028）。输入框里带着当前生效的
          // 标签，若直接按内容走补全，用户点一下看到的会是标签建议而不是历史。
          if (!_userEdited) {
            return _historySuggestions(controller);
          }

          final token = _lastToken(controller.text).trim();

          // 无当前词时回落到历史记录（C1）。
          if (token.isEmpty) {
            return _historySuggestions(controller);
          }

          // 300ms 防抖：延迟后若输入已变，放弃这次结果。
          await Future<void>.delayed(const Duration(milliseconds: 300));
          if (_lastToken(controller.text).trim() != token) {
            return const <Widget>[];
          }

          try {
            final tags = await ref
                .read(searchRepositoryProvider)
                .getTagAutocomplete(token);
            if (!context.mounted) return const <Widget>[];
            if (tags.isEmpty) {
              return [
                const ListTile(
                  leading: Icon(Icons.search_off),
                  title: Text(Strings.emptyResultTitle),
                ),
              ];
            }
            return tags.map((tag) {
              return ListTile(
                leading: Icon(
                  Icons.tag,
                  size: 18,
                  color: PostFormat.tagCategoryColor(tag.category),
                ),
                title: Text(tag.name),
                subtitle: tag.antecedentName != null
                    ? Text(
                        '${tag.antecedentName} →',
                        style: const TextStyle(fontSize: 11),
                      )
                    : null,
                trailing: Text(
                  '${PostFormat.compactCount(tag.postCount)} 帖',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () => _applyCompletion(controller.text, tag.name),
              );
            }).toList();
          } catch (_) {
            // 补全失败静默回落历史。
            return _historySuggestions(controller);
          }
        },
      ),
    );
  }

  /// 历史下拉（PRD-028）。
  ///
  /// 返回单个 widget 而不是一串 ListTile：SearchAnchor 会把返回的列表塞进
  /// 自己的滚动容器，条目多了以后手势归属不明确。这里自己包一层带高度上限
  /// 的独立滚动区，把滚动关进这块区域，不会带动下层的图片网格。
  List<Widget> _historySuggestions(SearchController controller) {
    // 包 Consumer：suggestionsBuilder 只在输入变化时重跑，删掉一条后若不订阅
    // provider，列表不会就地刷新，得关掉重开才看得到变化。
    return [
      Consumer(
        builder: (context, ref, _) {
          final history = ref.watch(searchHistoryProvider);

          if (history.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(Strings.noSearchHistory),
            );
          }

          // 高度由 SearchAnchor 的 viewConstraints 控制，这里不再限高，
          // 否则两层约束打架。shrinkWrap 让列表按内容收缩，条目少时不留空白。
          return Scrollbar(
            controller: _historyScroll,
            child: ListView.builder(
              controller: _historyScroll,
              // 自带 controller，滚动在这块区域内消化掉，不会传到下层网格。
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: history.length,
              itemBuilder: (context, i) => _HistoryTile(
                query: history[i],
                onTap: () {
                  controller.closeView(history[i]);
                  _submitSearch(history[i]);
                },
                onDelete: () => ref
                    .read(searchHistoryProvider.notifier)
                    .removeSearch(history[i]),
              ),
            ),
          );
        },
      ),
    ];
  }
}

/// 单条历史。文字左对齐，右侧 x 删除。
class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.query,
    required this.onTap,
    required this.onDelete,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withAlpha(150);

    return ListTile(
      onTap: onTap,
      leading: Icon(Icons.history, size: 20, color: muted),
      // 显式左对齐，不依赖 ListTile 的默认行为。
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          query,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        tooltip: Strings.removeSearchHistoryItem,
        color: muted,
        // 保证 44x44 可点区域，避免误触整行触发搜索。
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        onPressed: onDelete,
      ),
    );
  }
}
