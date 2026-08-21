import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/e621_post.dart';
import '../repositories/post_repository.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/utils/error_messages.dart';

/// 评级过滤（A7）。null 项表示"全部"。
enum RatingFilter { safe, questionable, explicit }

extension RatingFilterX on RatingFilter {
  String get tag => switch (this) {
    RatingFilter.safe => 'rating:s',
    RatingFilter.questionable => 'rating:q',
    RatingFilter.explicit => 'rating:e',
  };
}

class PostListState {
  final List<E621Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final int totalPages; // 0 = unknown
  final String currentTags;
  final String currentSort;
  final Set<RatingFilter> ratingFilters;
  final bool hasReachedEnd;

  PostListState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.totalPages = 0,
    this.currentTags = 'female',
    this.currentSort = 'order:score',
    this.ratingFilters = const {},
    this.hasReachedEnd = false,
  });

  PostListState copyWith({
    List<E621Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    int? totalPages,
    String? currentTags,
    String? currentSort,
    Set<RatingFilter>? ratingFilters,
    bool? hasReachedEnd,
  }) {
    return PostListState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error, // 显式覆盖：null 表示清除错误
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      currentTags: currentTags ?? this.currentTags,
      currentSort: currentSort ?? this.currentSort,
      ratingFilters: ratingFilters ?? this.ratingFilters,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }

  /// 搜索框展示串：用户标签 + 当前排序 + 评级过滤（去重、保持顺序）。
  String get displayTags {
    final parts = <String>[];
    void add(String s) {
      final t = s.trim();
      if (t.isNotEmpty && !parts.contains(t)) parts.add(t);
    }

    for (final t in currentTags.split(' ')) {
      add(t);
    }
    add(currentSort);
    for (final r in ratingFilters) {
      add(r.tag);
    }
    return parts.join(' ');
  }
}

class PostListNotifier extends Notifier<PostListState> {
  @override
  PostListState build() {
    return PostListState();
  }

  /// 拼接最终查询串：用户标签 + 排序 + 评级过滤 + 黑名单。
  /// 集中在 notifier 而非 UI（A7 要求）。
  String _buildTags() {
    final settings = ref.read(settingsProvider);
    final queryTags = <String>[];

    if (state.currentTags.isNotEmpty) {
      queryTags.addAll(state.currentTags.split(' ').where((s) => s.isNotEmpty));
    }
    queryTags.add(state.currentSort);

    // 评级过滤：单选时用 rating:x；多选时用排除法（e621 每帖只有一个评级，
    // 无法用多个正向 rating: 求并集，只能排除未选中的评级）。
    final selected = state.ratingFilters;
    if (selected.isNotEmpty && selected.length < RatingFilter.values.length) {
      if (selected.length == 1) {
        queryTags.add(selected.first.tag);
      } else {
        for (final r in RatingFilter.values) {
          if (!selected.contains(r)) queryTags.add('-${r.tag}');
        }
      }
    }

    if (settings.enableBlacklist && settings.blacklistedTags.isNotEmpty) {
      for (final tag in settings.blacklistedTags) {
        queryTags.add('-$tag');
      }
    }
    // 去重（保序）：防止用户标签里已经带了 order:/rating: 等条件时，
    // 与显式追加的排序/评级重复。
    final seen = <String>{};
    final unique = queryTags.where(seen.add).toList();
    return unique.join(' ');
  }

  Future<void> loadPosts({bool isRefresh = false, int? targetPage}) async {
    if (state.isLoading) return;

    final repo = ref.read(postRepositoryProvider);
    final settings = ref.read(settingsProvider);

    final pageToLoad = targetPage ?? (isRefresh ? 1 : state.page);

    state = state.copyWith(isLoading: true, error: null);

    try {
      final tagsString = _buildTags();

      final results = await Future.wait([
        repo.getPosts(
          tags: tagsString,
          page: pageToLoad,
          limit: settings.pageSize,
        ),
        if (isRefresh || pageToLoad == 1 || state.totalPages == 0)
          repo.fetchTotalPostCount(tags: tagsString),
      ]);

      final fetchedPosts = results[0] as List<E621Post>;

      int totalPages = state.totalPages;
      if (results.length > 1) {
        final totalPostCount = results[1] as int;
        if (totalPostCount > 0) {
          totalPages = max(1, (totalPostCount / settings.pageSize).ceil());
          totalPages = min(totalPages, 750); // e621 硬上限 750 页
        }
      }

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
        hasReachedEnd: fetchedPosts.length < settings.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: humanizeError(e));
    }
  }

  /// 无限滚动追加下一页（A3）。与分页模式共用同一份数据。
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedEnd) return;
    if (state.error != null) return;

    final repo = ref.read(postRepositoryProvider);
    final settings = ref.read(settingsProvider);
    final nextPage = state.page + 1;

    state = state.copyWith(isLoadingMore: true);

    try {
      final fetched = await repo.getPosts(
        tags: _buildTags(),
        page: nextPage,
        limit: settings.pageSize,
      );

      // 按 id 去重后追加，避免 order:random 或边界重复。
      final existingIds = state.posts.map((p) => p.id).toSet();
      final merged = [
        ...state.posts,
        ...fetched.where((p) => !existingIds.contains(p.id)),
      ];

      state = state.copyWith(
        posts: merged,
        page: nextPage,
        isLoadingMore: false,
        hasReachedEnd: fetched.length < settings.pageSize,
      );
    } catch (e) {
      // 追加失败不覆盖已有内容，只停掉 loading。
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> reloadCurrentSearch() async {
    state = state.copyWith(
      posts: [],
      page: 1,
      totalPages: 0,
      hasReachedEnd: false,
      error: null,
    );
    await loadPosts(isRefresh: true);
  }

  void search(String tags) {
    // 排序 / 评级由 chips 单独维护（currentSort / ratingFilters）。
    // 提交文本里若混入了 order:*/rating:*，这里剥掉，只把纯用户标签写进
    // currentTags，避免和 _buildTags 里显式追加的条件重复。
    final userTags = tags
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .where(
          (s) =>
              !s.startsWith('order:') &&
              s != RatingFilter.safe.tag &&
              s != RatingFilter.questionable.tag &&
              s != RatingFilter.explicit.tag,
        )
        .join(' ');

    state = state.copyWith(
      currentTags: userTags,
      totalPages: 0,
      hasReachedEnd: false,
    );
    loadPosts(isRefresh: true);
  }

  void setSort(String sortParam) {
    if (state.currentSort == sortParam) return;
    state = state.copyWith(
      currentSort: sortParam,
      totalPages: 0,
      hasReachedEnd: false,
    );
    loadPosts(isRefresh: true);
  }

  void toggleRating(RatingFilter rating) {
    final next = Set<RatingFilter>.from(state.ratingFilters);
    if (next.contains(rating)) {
      next.remove(rating);
    } else {
      next.add(rating);
    }
    state = state.copyWith(
      ratingFilters: next,
      totalPages: 0,
      hasReachedEnd: false,
    );
    loadPosts(isRefresh: true);
  }

  void clearRatingFilters() {
    if (state.ratingFilters.isEmpty) return;
    state = state.copyWith(
      ratingFilters: {},
      totalPages: 0,
      hasReachedEnd: false,
    );
    loadPosts(isRefresh: true);
  }
}

final postListProvider = NotifierProvider<PostListNotifier, PostListState>(() {
  return PostListNotifier();
});
