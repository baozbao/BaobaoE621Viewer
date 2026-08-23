import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import '../../search/providers/search_history_provider.dart';
import '../../search/repositories/search_repository.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/post_format.dart';
import '../../../core/widgets/filter_menu_open.dart';
import 'search_suggestion_panel_data.dart';
import 'search_suggestion_panel_stub.dart'
    if (dart.library.js_interop) 'search_suggestion_panel_web.dart'
    as search_panel;

/// 通用搜索栏（浏览页 / 下载页共用）。
///
/// 通过 [stateProvider] + [displayTagsOf] + [onSearch] 与任意列表 provider
/// 解耦：输入框显示 provider 的展示标签（含排序/评级），提交时回调通知对方。
///
/// Web 端建议面板是 HTML 平台视图（DOM 层在图片之上，不会被预览图遮挡）；
/// 移动端仍用 SearchAnchor。
class SearchBarWidget<S> extends ConsumerStatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.stateProvider,
    required this.displayTagsOf,
    required this.onSearch,
  });

  final ProviderListenable<S> stateProvider;

  /// 从状态取"搜索框应显示的完整标签串"（用户标签 + 排序 + 评级）。
  final String Function(S state) displayTagsOf;

  /// 用户提交搜索时回调（query 为输入框原始文本）。
  final void Function(WidgetRef ref, String query) onSearch;

  @override
  ConsumerState<SearchBarWidget<S>> createState() => _SearchBarWidgetState<S>();
}

class _SearchBarWidgetState<S> extends ConsumerState<SearchBarWidget<S>> {
  late final SearchController _controller;

  /// 历史列表自己的滚动控制器（PRD-028）。有了它这块区域的滚动才独立于
  /// 下层页面，否则手势会落到页面的 CustomScrollView 上。
  final ScrollController _historyScroll = ScrollController();

  /// 本次打开视图后用户是否敲过键盘。false 时优先展示历史 ——
  /// 输入框里带着当前生效的标签，不能仅凭「有内容」就去走标签补全。
  bool _userEdited = false;

  // ---- Web 专用：自定义建议面板（HTML 平台视图）----
  final GlobalKey _webFieldKey = GlobalKey();
  final FocusNode _webFocus = FocusNode();
  OverlayEntry? _webEntry;
  Rect? _webRect;
  Timer? _webDebounce;
  List<SearchSuggestionRowData> _webRows = const [];

  @override
  void initState() {
    super.initState();
    _controller = SearchController()
      ..text = widget.displayTagsOf(ref.read(widget.stateProvider));
    registerFilterMenuClose(_closeWebPanel);
  }

  @override
  void dispose() {
    unregisterFilterMenuClose(_closeWebPanel);
    _webDebounce?.cancel();
    _closeWebPanel();
    _webFocus.dispose();
    _historyScroll.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    // 空提交不改变搜索条件。把输入框回填成当前实际生效的搜索条件，
    // 让 UI 始终反映真实状态。
    if (query.trim().isEmpty) {
      _controller.text = widget.displayTagsOf(ref.read(widget.stateProvider));
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      return;
    }
    // 历史由 provider 的 search() 统一记录（含 tag 点击、默认请求），
    // 这里不再重复添加，避免同集合重复项。
    widget.onSearch(ref, query);
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

  // ===================== Web：HTML 建议面板 =====================

  void _openWebPanel() {
    // 一键关闭其它打开的下拉/面板（含筛选下拉），再开自己的面板。
    closeAllFilterMenus();
    if (_webEntry != null) return;

    final box = _webFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    _webRows = _historyRows();
    _webRect = Rect.fromLTWH(
      offset.dx,
      offset.dy + size.height + 3,
      size.width,
      300,
    );
    filterMenuRects.value = List<Rect>.from(filterMenuRects.value)
      ..add(_webRect!);

    _webEntry = OverlayEntry(
      builder: (context) => _buildWebPanel(offset, size),
    );
    Overlay.of(context).insert(_webEntry!);
    setState(() {});
  }

  void _closeWebPanel() {
    if (_webEntry == null) return;
    if (_webRect != null) {
      filterMenuRects.value = List<Rect>.from(filterMenuRects.value)
        ..removeWhere((r) => r == _webRect);
    }
    _webRect = null;
    _webEntry?.remove();
    _webEntry = null;
    _webDebounce?.cancel();
    if (mounted) setState(() {});
  }

  void _refreshWebPanel() {
    _webEntry?.markNeedsBuild();
  }

  List<SearchSuggestionRowData> _historyRows() {
    final history = ref.read(searchHistoryProvider);
    return [
      for (final q in history)
        SearchSuggestionRowData(
          text: q,
          onTap: () {
            _closeWebPanel();
            _submitSearch(q);
          },
          onDelete: () {
            ref.read(searchHistoryProvider.notifier).removeSearch(q);
            _webRows = _historyRows();
            _refreshWebPanel();
          },
        ),
    ];
  }

  void _scheduleAutocomplete() {
    _webDebounce?.cancel();
    _webDebounce = Timer(const Duration(milliseconds: 300), () async {
      final token = _lastToken(_controller.text).trim();

      List<SearchSuggestionRowData> rows;
      if (token.isEmpty) {
        rows = _historyRows();
      } else {
        try {
          final tags = await ref
              .read(searchRepositoryProvider)
              .getTagAutocomplete(token);
          if (!mounted) return;
          rows = [
            for (final tag in tags)
              SearchSuggestionRowData(
                text: tag.name,
                color: PostFormat.tagCategoryColor(tag.category),
                sub: tag.antecedentName != null
                    ? '${tag.antecedentName} →'
                    : null,
                count: '${PostFormat.compactCount(tag.postCount)} 帖',
                onTap: () {
                  _applyCompletion(_controller.text, tag.name);
                  _scheduleAutocomplete();
                },
              ),
          ];
        } catch (_) {
          if (!mounted) return;
          rows = _historyRows();
        }
      }

      if (!mounted) return;
      setState(() => _webRows = rows);
      _refreshWebPanel();
    });
  }

  Widget _buildWebPanel(Offset offset, Size size) {
    final scheme = Theme.of(context).colorScheme;

    final viewId = search_panel.registerSearchSuggestionPanel(
      rows: _webRows,
      surfaceArgb: scheme.surface.toARGB32(),
      outlineArgb: scheme.outline.toARGB32(),
      onSurfaceArgb: scheme.onSurface.toARGB32(),
    );

    final panelHeight = math
        .min(_webRows.length * 34.0 + 2.0, 300.0)
        .clamp(44.0, 300.0);

    return Stack(
      children: [
        // 点面板外（搜索栏以下）关闭。
        Positioned(
          top: offset.dy + size.height + 3,
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _closeWebPanel,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 3,
          width: size.width,
          height: panelHeight,
          child: HtmlElementView(viewType: viewId),
        ),
      ],
    );
  }

  Widget _buildWebSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SearchBar(
        key: _webFieldKey,
        controller: _controller,
        focusNode: _webFocus,
        onTap: () {
          // 点开即从历史开始（与 SearchAnchor 行为一致）。
          _userEdited = false;
          _openWebPanel();
        },
        constraints: const BoxConstraints(maxHeight: 44),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        onChanged: (value) {
          _userEdited = true;
          _scheduleAutocomplete();
        },
        onSubmitted: (value) {
          _closeWebPanel();
          _submitSearch(value);
        },
        leading: const Icon(Icons.search, size: 20),
        trailing: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              padding: EdgeInsets.zero,
              // X = 清除搜索：真正清空 provider 里的搜索条件并刷新。
              onPressed: () {
                _closeWebPanel();
                _controller.clear();
                widget.onSearch(ref, '');
              },
            ),
        ],
      ),
    );
  }

  // ===================== 移动端：SearchAnchor =====================

  Widget _buildAnchorSearchBar(BuildContext context) {
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
              closeAllFilterMenus();
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
                  // X = 清除搜索：真正清空 provider 里的搜索条件并刷新。
                  onPressed: () {
                    controller.clear();
                    widget.onSearch(ref, '');
                  },
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

  @override
  Widget build(BuildContext context) {
    // 监听列表状态：排序/评级/标签变化时同步输入框展示串。
    ref.listen<S>(widget.stateProvider, (previous, next) {
      final prevTags = previous == null ? '' : widget.displayTagsOf(previous);
      final nextTags = widget.displayTagsOf(next);
      if (prevTags != nextTags && _controller.text != nextTags) {
        _controller.text = nextTags;
      }
    });

    if (kIsWeb) return _buildWebSearchBar();
    return _buildAnchorSearchBar(context);
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
