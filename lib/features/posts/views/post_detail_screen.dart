import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/e621_post.dart';
import '../providers/post_list_provider.dart';
import '../utils/download_helper.dart';
import '../widgets/tag_group_section.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../popular/providers/popular_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/post_format.dart';
import '../../../core/widgets/native_web_image.dart';
import '../../../core/widgets/hidden_post_placeholder.dart';
import '../../../core/widgets/media_player.dart';
import '../../../core/widgets/frosted_surface.dart';

/// 详情页路由参数（B2:传索引 + 数据源，支持画廊左右滑）。
class PostDetailArgs {
  /// 在 [source] 列表中的起始索引。
  final int index;

  /// 画廊数据源。默认 `postList` = 首页列表；`favorites` = 收藏页；
  /// `popular` = 热门榜单（需配合 [scale]）。
  final PostDetailSource source;

  /// 当 source 为 popular 时的时间范围。
  final PopularScale? scale;

  const PostDetailArgs({
    required this.index,
    this.source = PostDetailSource.postList,
    this.scale,
  });
}

enum PostDetailSource { postList, favorites, popular, history }

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostDetailArgs args;

  const PostDetailScreen({super.key, required this.args});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  /// 任一页处于放大状态时，禁用 PageView 横滑（B1/B2 手势冲突）。
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.args.index;
    _pageController = PageController(initialPage: widget.args.index);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recordCurrentPost());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<E621Post> _watchPosts() {
    switch (widget.args.source) {
      case PostDetailSource.postList:
        return ref.watch(postListProvider).posts;
      case PostDetailSource.favorites:
        return ref.watch(favoritesProvider);
      case PostDetailSource.popular:
        // 复用热门页已缓存的榜单，避免详情页重复请求。
        return ref.watch(popularPostsProvider(widget.args.scale!)).value ??
            const [];
      case PostDetailSource.history:
        return ref.watch(historyProvider).map((e) => e.post).toList();
    }
  }

  List<E621Post> _readPostsSnapshot() {
    switch (widget.args.source) {
      case PostDetailSource.postList:
        return ref.read(postListProvider).posts;
      case PostDetailSource.favorites:
        return ref.read(favoritesProvider);
      case PostDetailSource.popular:
        return ref.read(popularPostsProvider(widget.args.scale!)).value ??
            const [];
      case PostDetailSource.history:
        return ref.read(historyProvider).map((e) => e.post).toList();
    }
  }

  void _recordCurrentPost() {
    if (widget.args.source == PostDetailSource.history) return;
    final posts = _readPostsSnapshot();
    if (_currentIndex < posts.length) {
      ref.read(historyProvider.notifier).record(posts[_currentIndex]);
    }
  }

  void _onPageChanged(int index, int total) {
    setState(() => _currentIndex = index);
    _recordCurrentPost();
    // 画廊滑到接近末尾时，无限滚动模式下自动加载下一页（B2 + A3）。
    if (widget.args.source == PostDetailSource.postList &&
        ref.read(settingsProvider).browseMode == BrowseMode.infinite &&
        index >= total - 3) {
      ref.read(postListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = _watchPosts();

    if (posts.isEmpty || _currentIndex >= posts.length) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Icon(Icons.broken_image, size: 50)),
      );
    }

    final current = posts[_currentIndex];
    final isFav = ref.watch(favoritesProvider.notifier).isFavorited(current.id);

    return PopScope(
      // 返回主页时：若开启「选择标签返回时自动搜索」且有暂选标签，
      // 自动搜索 原标签 + 新标签。
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        final settings = ref.read(settingsProvider);
        final pending = ref.read(postListProvider).pendingTags;
        if (settings.autoSearchOnTagReturn && pending.isNotEmpty) {
          ref.read(postListProvider.notifier).applyPendingTags();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('#${current.id}'),
          // 毛玻璃顶栏：大图顶到栏下时透出模糊色影，比实色挡板更贴合看图场景。
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          flexibleSpace: FrostedSurface(
            border: AppTheme.surfaceBorder(
              light: Theme.of(context).brightness == Brightness.light,
            ),
          ),
          actions: [
            IconButton(
              tooltip: isFav
                  ? Strings.removedFromFavorites
                  : Strings.added2Favorites,
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.redAccent : null,
              ),
              onPressed: () {
                ref.read(favoritesProvider.notifier).toggle(current);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? Strings.removedFromFavorites
                            : Strings.added2Favorites,
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
              },
            ),
            IconButton(
              tooltip: Strings.download,
              icon: const Icon(Icons.download),
              onPressed: () =>
                  DownloadHelper.showDownloadSheet(context, ref, current),
            ),
          ],
        ),
        body: PageView.builder(
          controller: _pageController,
          physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
          itemCount: posts.length,
          onPageChanged: (i) => _onPageChanged(i, posts.length),
          itemBuilder: (context, index) {
            return _PostDetailPage(
              post: posts[index],
              onZoomChanged: (z) {
                if (z != _zoomed) setState(() => _zoomed = z);
              },
            );
          },
        ),
      ),
    );
  }
}

/// 单个帖子的详情内容：可缩放大图 + 标签分组 + 信息。
class _PostDetailPage extends ConsumerWidget {
  final E621Post post;
  final ValueChanged<bool> onZoomChanged;

  const _PostDetailPage({required this.post, required this.onZoomChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 媒体区。url == null = 服务端隐藏（未登录/已删除），不是加载失败。
          if (post.file.url == null)
            SizedBox(
              height: 300,
              child: HiddenPostPlaceholder(deleted: post.flags.deleted),
            )
          else if (PostFormat.isVideo(post.file.ext))
            AspectRatio(
              aspectRatio: post.file.width / post.file.height,
              child: MediaPlayer(
                // 优先用 e621 转码的 H.264 mp4（alternates），
                // 原始 VP9 webm 在低端设备/模拟器上软解会一直缓冲转圈。
                videoUrl: post.bestVideoUrl ?? post.file.url!,
                aspectRatio: post.file.width / post.file.height,
              ),
            )
          else if (post.file.ext == 'swf')
            const SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flash_off, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Flash 动画 (.swf) 现已停止支持',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            _ZoomableImage(
              url: post.file.url!,
              aspectRatio: post.file.width / post.file.height,
              onZoomChanged: onZoomChanged,
            ),

          const SizedBox(height: 8),

          // 收藏 / 分数 / 下载 快捷条。
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 16,
                  color: PostFormat.scoreColor(post.score.total),
                ),
                const SizedBox(width: 2),
                Text(
                  '${post.score.total}',
                  style: TextStyle(
                    color: PostFormat.scoreColor(post.score.total),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                const SizedBox(width: 2),
                Text('${post.favCount}'),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: PostFormat.ratingColor(post.rating).withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: PostFormat.ratingColor(post.rating),
                    ),
                  ),
                  child: Text(
                    PostFormat.ratingLabel(post.rating),
                    style: TextStyle(
                      color: PostFormat.ratingColor(post.rating),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // 标签分组（B3）。
          TagGroupSection(tags: post.tags),

          const Divider(height: 24),

          // 图片信息。
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              Strings.imageInfo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: onSurface.withAlpha(160),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _InfoRow('ID', '${post.id}'),
          _InfoRow(
            '尺寸',
            '${post.file.width}x${post.file.height} (${PostFormat.fileSize(post.file.size)})',
          ),
          _InfoRow('类型', post.file.ext.toUpperCase()),
          _InfoRow('MD5', post.file.md5),
          _InfoRow('发布时间', post.createdAt),

          if (post.description.isNotEmpty) ...[
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                Strings.description,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: onSurface.withAlpha(160),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(post.description),
            ),
          ],

          if (post.sources.isNotEmpty) ...[
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                Strings.source,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: onSurface.withAlpha(160),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...post.sources.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                child: Text(
                  s,
                  style: const TextStyle(color: Colors.lightBlueAccent),
                ),
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// 捏合缩放 + 双击放大（B1）。放大状态变化通过 [onZoomChanged] 上报，
/// 供父级禁用 PageView 横滑。
class _ZoomableImage extends StatefulWidget {
  final String url;
  final double aspectRatio;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableImage({
    required this.url,
    required this.aspectRatio,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_notifyZoom);
  }

  @override
  void dispose() {
    _controller.removeListener(_notifyZoom);
    _controller.dispose();
    super.dispose();
  }

  void _notifyZoom() {
    final scale = _controller.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > 1.05);
  }

  void _handleDoubleTap() {
    if (_controller.value.getMaxScaleOnAxis() > 1.05) {
      _controller.value = Matrix4.identity();
    } else {
      final pos = _doubleTapDetails?.localPosition;
      if (pos == null) return;
      // 以双击点为中心放大到 2.5x。
      const scale = 2.5;
      final x = -pos.dx * (scale - 1);
      final y = -pos.dy * (scale - 1);
      _controller.value = Matrix4.identity()
        ..translateByDouble(x, y, 0, 1)
        ..scaleByDouble(scale, scale, 1, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _doubleTapDetails = d,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1,
        maxScale: 5,
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: NativeWebImage(imageUrl: widget.url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
              ),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
