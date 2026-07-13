import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/providers/search_history_provider.dart';
import '../../posts/providers/post_list_provider.dart';

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
    
    // Trigger the search immediately for responsiveness
    ref.read(postListProvider.notifier).search(query);
    
    // IMPORTANT: Delay updating the history provider!
    // When the Search view closes, it plays an animation. If we update the history 
    // provider while the view is closing, Riverpod tries to rebuild the unmounted 
    // Consumer inside the suggestionsBuilder, causing the white screen lifecycle crash.
    Future.delayed(const Duration(milliseconds: 300), () {
      ref.read(searchHistoryProvider.notifier).addSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for external changes to the search tags (e.g. from PostDetailScreen)
    ref.listen(postListProvider, (previous, next) {
      if (previous?.currentTags != next.currentTags && _controller.text != next.currentTags) {
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
        builder: (BuildContext context, SearchController controller) {
          return SearchBar(
            controller: controller,
            constraints: const BoxConstraints(maxHeight: 44), // Reduce search bar height
            padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0)),
            onSubmitted: (value) {
              _submitSearch(value);
            },
            leading: const Icon(Icons.search, size: 20), // Smaller icon
            trailing: [
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20), // Smaller icon
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    controller.clear();
                  },
                ),
            ],
          );
        },
        suggestionsBuilder: (BuildContext context, SearchController controller) {
          // Wrap with a single Consumer so that ref.watch happens in a valid build context
          return [
            Consumer(
              builder: (context, ref, child) {
                final history = ref.watch(searchHistoryProvider);
                if (history.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No search history'),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: history.map((item) {
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(item),
                      onTap: () {
                        controller.closeView(item);
                        _submitSearch(item);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          ref.read(searchHistoryProvider.notifier).removeSearch(item);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            )
          ];
        },
      ),
    );
  }
}
