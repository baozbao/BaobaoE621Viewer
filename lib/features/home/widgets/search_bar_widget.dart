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

  @override
  void initState() {
    super.initState();
    _controller = SearchController()..text = ref.read(postListProvider).currentTags;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    if (query.trim().isEmpty) return;
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
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
  }

  @override
  Widget build(BuildContext context) {
    // 监听外部对搜索标签的修改（如从详情页点标签搜索）。
    ref.listen(postListProvider, (previous, next) {
      if (previous?.currentTags != next.currentTags &&
          _controller.text != next.currentTags) {
        _controller.text = next.currentTags;
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SearchAnchor(
        searchController: _controller,
        viewOnSubmitted: (value) {
          _controller.closeView(value);
          _submitSearch(value);
        },
        builder: (context, controller) {
          return SearchBar(
            controller: controller,
            constraints: const BoxConstraints(maxHeight: 44),
            padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0)),
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
                leading: Icon(Icons.tag,
                    size: 18, color: PostFormat.tagCategoryColor(tag.category)),
                title: Text(tag.name),
                subtitle: tag.antecedentName != null
                    ? Text('${tag.antecedentName} →', style: const TextStyle(fontSize: 11))
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

  List<Widget> _historySuggestions(SearchController controller) {
    final history = ref.read(searchHistoryProvider);
    if (history.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(Strings.noSearchHistory),
        ),
      ];
    }
    return history.map((item) {
      return ListTile(
        leading: const Icon(Icons.history),
        title: Text(item),
        onTap: () {
          controller.closeView(item);
          _submitSearch(item);
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () =>
              ref.read(searchHistoryProvider.notifier).removeSearch(item),
        ),
      );
    }).toList();
  }
}
