import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/e621_post.dart';
import '../repositories/post_repository.dart';
import '../../settings/providers/settings_provider.dart';

class PostListState {
  final List<E621Post> posts;
  final bool isLoading;
  final String? error;
  final int page;
  final int totalPages; // 0 = unknown
  final String currentTags;
  final String currentSort;

  PostListState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.totalPages = 0,
    this.currentTags = 'female',
    this.currentSort = 'order:score',
  });

  PostListState copyWith({
    List<E621Post>? posts,
    bool? isLoading,
    String? error,
    int? page,
    int? totalPages,
    String? currentTags,
    String? currentSort,
  }) {
    return PostListState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      currentTags: currentTags ?? this.currentTags,
      currentSort: currentSort ?? this.currentSort,
    );
  }
}

class PostListNotifier extends Notifier<PostListState> {
  @override
  PostListState build() {
    return PostListState();
  }

  Future<void> loadPosts({bool isRefresh = false, int? targetPage}) async {
    if (state.isLoading) return;

    final repo = ref.read(postRepositoryProvider);
    final settings = ref.read(settingsProvider);
    
    final pageToLoad = targetPage ?? (isRefresh ? 1 : state.page);
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Build final tags string
      List<String> queryTags = [];
      
      // 1. User search tags
      if (state.currentTags.isNotEmpty) {
        queryTags.addAll(state.currentTags.split(' ').where((s) => s.isNotEmpty));
      }
      
      // 2. Sort param
      queryTags.add(state.currentSort);
      
      // 4. Blacklisted tags
      if (settings.enableBlacklist && settings.blacklistedTags.isNotEmpty) {
        for (final tag in settings.blacklistedTags) {
          queryTags.add('-$tag');
        }
      }

      final tagsString = queryTags.join(' ');

      // Fetch posts and total count in parallel
      final results = await Future.wait([
        repo.getPosts(tags: tagsString, page: pageToLoad, limit: settings.pageSize),
        // Only fetch total count on first page or refresh to avoid unnecessary requests
        if (isRefresh || pageToLoad == 1 || state.totalPages == 0)
          repo.fetchTotalPostCount(tags: tagsString),
      ]);

      final fetchedPosts = results[0] as List<E621Post>;
      
      int totalPages = state.totalPages;
      if (results.length > 1) {
        final totalPostCount = results[1] as int;
        if (totalPostCount > 0) {
          totalPages = max(1, (totalPostCount / settings.pageSize).ceil());
          // e621 hard-limits page numbers to 750; requests beyond that return 422.
          totalPages = min(totalPages, 750);
        }
      }

      // Auto-correct: if this page returned fewer posts than pageSize,
      // this is the actual last page. Fixes rounding errors from the
      // approximate total post count calculation.
      if (fetchedPosts.length < settings.pageSize && fetchedPosts.isNotEmpty) {
        totalPages = pageToLoad;
      } else if (fetchedPosts.isEmpty && pageToLoad > 1) {
        totalPages = pageToLoad - 1;
      }

      state = state.copyWith(
        posts: fetchedPosts,
        page: pageToLoad,
        totalPages: totalPages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void search(String tags) {
    state = state.copyWith(currentTags: tags, totalPages: 0);
    loadPosts(isRefresh: true);
  }

  void setSort(String sortParam) {
    if (state.currentSort == sortParam) return;
    state = state.copyWith(currentSort: sortParam, totalPages: 0);
    loadPosts(isRefresh: true);
  }
}

final postListProvider = NotifierProvider<PostListNotifier, PostListState>(() {
  return PostListNotifier();
});
