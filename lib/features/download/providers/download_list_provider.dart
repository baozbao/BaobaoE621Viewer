import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/models/e621_post.dart';
import '../../posts/providers/post_list_provider.dart';
import '../../posts/repositories/post_repository.dart';
import '../../settings/providers/settings_provider.dart';
import '../../search/providers/search_history_provider.dart';
import '../../../core/utils/error_messages.dart';

/// 媒体类型过滤（下载页）。
enum MediaType { image, video }

/// 由选中状态生成媒体类型过滤的查询 token（官方 metatag）。
/// gif 按图片处理（e621 官方分类：gif 是 image）。
///
/// 注意：OR 分组里 ~ 必须像前缀一样贴在每个 metatag 上
/// （官方语法是 "( ~type:webm ~type:mp4 )"）；写成 "( type:webm ~ type:mp4 )"
/// API 会静默返回空结果。
List<String> mediaTypeFilterTags(Set<MediaType> mediaTypes) {
  final hasImage = mediaTypes.contains(MediaType.image);
  final hasVideo = mediaTypes.contains(MediaType.video);
  if (hasImage && !hasVideo) {
    // 仅图片 = 排除两种视频类型（gif/jpg/png/webp 保留）。
    return ['-type:webm', '-type:mp4'];
  }
  if (hasVideo && !hasImage) {
    return ['( ~type:webm ~type:mp4 )'];
  }
  return const [];
}

/// 下载页状态：与浏览页同构（独立搜索条件），额外带多选集合。
class DownloadListState {
  final List<E621Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final int totalPages; // 0 = unknown
  final String currentTags;
  final String currentSort;
  final Set<RatingFilter> ratingFilters;

  /// 媒体类型过滤：空或两者都选 = 不过滤。
  final Set<MediaType> mediaTypes;

  /// 已选中的帖子（按选择顺序）。用 Map 存完整对象：
  /// 翻页后上一页的帖子已不在 [posts] 里，但选中集合必须跨页存活。
  final Map<int, E621Post> selected;
  final bool hasReachedEnd;

  /// 是否已从浏览页继承过搜索条件（只继承一次）。
  final bool initialized;

  DownloadListState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.totalPages = 0,
    this.currentTags = '',
    this.currentSort = 'order:score',
    this.ratingFilters = const {},
    this.mediaTypes = const {},
    this.selected = const {},
    this.hasReachedEnd = false,
    this.initialized = false,
  });

  DownloadListState copyWith({
    List<E621Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    int? totalPages,
    String? currentTags,
    String? currentSort,
    Set<RatingFilter>? ratingFilters,
    Set<MediaType>? mediaTypes,
    Map<int, E621Post>? selected,
    bool? hasReachedEnd,
    bool? initialized,
  }) {
    return DownloadListState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      currentTags: currentTags ?? this.currentTags,
      currentSort: currentSort ?? this.currentSort,
      ratingFilters: ratingFilters ?? this.ratingFilters,
      mediaTypes: mediaTypes ?? this.mediaTypes,
      selected: selected ?? this.selected,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      initialized: initialized ?? this.initialized,
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
    // 类型过滤也是实际请求的一部分，同样展示，方便直接复制去网页搜索。
    for (final t in mediaTypeFilterTags(mediaTypes)) {
      add(t);
    }
    return parts.join(' ');
  }

  /// 已选帖子（按选择顺序）。
  List<E621Post> get selectedPosts => selected.values.toList();

  /// 预估总体积（原文件大小之和；视频转 mp4 时实际会小一些）。
  int get selectedBytes =>
      selected.values.fold(0, (sum, p) => sum + p.file.size);
}

class DownloadListNotifier extends Notifier<DownloadListState> {
  /// 上一次已记入历史的请求串，避免重复记录。
  String? _lastRecorded;

  @override
  DownloadListState build() {
    return DownloadListState();
  }

  /// 首次进入下载页时从浏览页继承搜索条件（只执行一次）。
  /// 之后两页状态完全独立。
  void initFromBrowse() {
    if (state.initialized) return;
    final browse = ref.read(postListProvider);
    state = state.copyWith(
      currentTags: browse.currentTags,
      currentSort: browse.currentSort,
      ratingFilters: browse.ratingFilters,
      initialized: true,
      totalPages: 0,
      hasReachedEnd: false,
    );
    loadPosts(isRefresh: true);
  }

  /// 拼接最终查询串：用户标签 + 排序 + 评级过滤 + 黑名单（去重保序）。
  String _buildTags() {
    final settings = ref.read(settingsProvider);
    final queryTags = <String>[];

    if (state.currentTags.isNotEmpty) {
      queryTags.addAll(state.currentTags.split(' ').where((s) => s.isNotEmpty));
    }
    queryTags.add(state.currentSort);

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

    // 媒体类型过滤（官方 metatag，gif 按图片处理；空或两者都选 = 不过滤）。
    queryTags.addAll(mediaTypeFilterTags(state.mediaTypes));

    if (settings.enableBlacklist && settings.blacklistedTags.isNotEmpty) {
      for (final tag in settings.blacklistedTags) {
        queryTags.add('-$tag');
      }
    }

    final seen = <String>{};
    return queryTags.where(seen.add).join(' ');
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
          limit: settings.downloadPageSize,
        ),
        if (isRefresh || pageToLoad == 1 || state.totalPages == 0)
          repo.fetchTotalPostCount(tags: tagsString),
      ]);

      final fetchedPosts = results[0] as List<E621Post>;

      int totalPages = state.totalPages;
      if (results.length > 1) {
        final totalPostCount = results[1] as int;
        if (totalPostCount > 0) {
          totalPages = max(
            1,
            (totalPostCount / settings.downloadPageSize).ceil(),
          );
          totalPages = min(totalPages, 750);
        }
      }

      if (fetchedPosts.length < settings.downloadPageSize &&
          fetchedPosts.isNotEmpty) {
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
    // 排序 / 评级由 chips 单独维护。提交文本里的 order:*/rating:* 剥掉，
    // 只把纯用户标签写进 currentTags，避免请求里重复。
    final userTags = tags
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .where(
          (s) =>
              !s.startsWith('order:') &&
              s != RatingFilter.safe.tag &&
              s != RatingFilter.questionable.tag &&
              s != RatingFilter.explicit.tag &&
              s != '-type:webm' &&
              s != '-type:mp4' &&
              s != '( ~type:webm ~type:mp4 )',
        )
        .join(' ');

    state = state.copyWith(
      currentTags: userTags,
      totalPages: 0,
      hasReachedEnd: false,
    );
    _recordSearch();
    loadPosts(isRefresh: true);
  }

  /// 把当前「实际请求串」（标签 + 排序 + 评级 + 类型）记入历史。
  void _recordSearch() {
    final display = state.displayTags.trim();
    if (display.isEmpty || display == _lastRecorded) return;
    _lastRecorded = display;
    ref.read(searchHistoryProvider.notifier).addSearch(display);
  }

  void setSort(String sortParam) {
    if (state.currentSort == sortParam) return;
    state = state.copyWith(
      currentSort: sortParam,
      totalPages: 0,
      hasReachedEnd: false,
    );
    _recordSearch();
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
    _recordSearch();
    loadPosts(isRefresh: true);
  }

  void clearRatingFilters() {
    if (state.ratingFilters.isEmpty) return;
    state = state.copyWith(
      ratingFilters: {},
      totalPages: 0,
      hasReachedEnd: false,
    );
    _recordSearch();
    loadPosts(isRefresh: true);
  }

  void clearMediaTypes() {
    if (state.mediaTypes.isEmpty) return;
    state = state.copyWith(mediaTypes: {}, totalPages: 0, hasReachedEnd: false);
    _recordSearch();
    loadPosts(isRefresh: true);
  }

  void toggleMediaType(MediaType type) {
    final next = Set<MediaType>.from(state.mediaTypes);
    if (next.contains(type)) {
      next.remove(type);
    } else {
      next.add(type);
    }
    state = state.copyWith(
      mediaTypes: next,
      totalPages: 0,
      hasReachedEnd: false,
    );
    _recordSearch();
    loadPosts(isRefresh: true);
  }

  // ---- 多选 ----

  void toggleSelect(E621Post post) {
    if (post.file.url == null) return; // 无下载地址的帖子不可选
    final next = Map<int, E621Post>.from(state.selected);
    if (next.containsKey(post.id)) {
      next.remove(post.id);
    } else {
      next[post.id] = post;
    }
    state = state.copyWith(selected: next);
  }

  /// 全选本页（有下载地址的帖子）。
  void selectAllOnPage() {
    final next = Map<int, E621Post>.from(state.selected);
    for (final p in state.posts) {
      if (p.file.url != null) next[p.id] = p;
    }
    state = state.copyWith(selected: next);
  }

  void clearSelection() {
    if (state.selected.isEmpty) return;
    state = state.copyWith(selected: {});
  }
}

final downloadListProvider =
    NotifierProvider<DownloadListNotifier, DownloadListState>(() {
      return DownloadListNotifier();
    });
