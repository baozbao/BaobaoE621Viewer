import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/post_format.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/filter_menu_open.dart';
import '../../../core/widgets/hidden_post_placeholder.dart';
import '../../../core/widgets/native_web_image.dart';
import '../../home/widgets/search_bar_widget.dart';
import '../../home/widgets/search_filter_rows.dart';
import '../../posts/models/e621_post.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/download_list_provider.dart';
import '../services/batch_download_service.dart';

/// 下载页：继承浏览页搜索条件的选择界面（批量下载）。
class DownloadScreen extends ConsumerStatefulWidget {
  const DownloadScreen({super.key});

  @override
  ConsumerState<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends ConsumerState<DownloadScreen> {
  @override
  void initState() {
    super.initState();
    // 首次进入时继承浏览页的搜索条件（provider 内部只继承一次）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(downloadListProvider.notifier).initFromBrowse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(downloadListProvider);
    final settings = ref.watch(settingsProvider);

    // 下载网格设置变化（含「与浏览一致」同步）→ 立即按新排版刷新列表。
    ref.listen(settingsProvider, (prev, next) {
      if (prev == null) return;
      final changed =
          prev.downloadPreviewHeight != next.downloadPreviewHeight ||
          prev.downloadWorksPerRow != next.downloadWorksPerRow ||
          prev.downloadPageSize != next.downloadPageSize;
      if (changed) {
        ref.read(downloadListProvider.notifier).reloadCurrentSearch();
      }
    });

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: const Text(Strings.downloadTab),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SearchBarWidget<DownloadListState>(
            stateProvider: downloadListProvider,
            displayTagsOf: (s) => s.displayTags,
            onSearch: (ref, q) =>
                ref.read(downloadListProvider.notifier).search(q),
          ),
          DownloadFilterRow(
            currentSort: state.currentSort,
            onSelectSort: (p) =>
                ref.read(downloadListProvider.notifier).setSort(p),
            ratingFilters: state.ratingFilters,
            onToggleRating: (r) =>
                ref.read(downloadListProvider.notifier).toggleRating(r),
            onClearRating: () =>
                ref.read(downloadListProvider.notifier).clearRatingFilters(),
            mediaTypes: state.mediaTypes,
            onToggleMediaType: (t) =>
                ref.read(downloadListProvider.notifier).toggleMediaType(t),
            onClearMediaType: () =>
                ref.read(downloadListProvider.notifier).clearMediaTypes(),
            variant: settings.themeVariant,
          ),
          Expanded(child: _buildGrid(state, settings)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(state, settings),
    );
  }

  Widget _buildGrid(DownloadListState state, AppSettings settings) {
    if (state.isLoading && state.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.posts.isEmpty) {
      return EmptyStateView(
        icon: Icons.cloud_off,
        title: state.error!,
        actionLabel: Strings.retry,
        onAction: () =>
            ref.read(downloadListProvider.notifier).loadPosts(isRefresh: true),
      );
    }
    if (!state.isLoading && state.posts.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off,
        title: Strings.emptyResultTitle,
        hint: Strings.emptyResultHint,
        actionLabel: Strings.clearSearch,
        onAction: () => ref.read(downloadListProvider.notifier).search(''),
      );
    }

    // 等高网格：列数/格子宽高比使用下载页自己的网格设置。
    // 下拉筛选菜单打开时锁定滚动，避免图片滚进菜单区域重新盖住浮层。
    return ValueListenableBuilder<List<Rect>>(
      valueListenable: filterMenuRects,
      builder: (context, menuRects, _) => GridView.builder(
        physics: menuRects.isEmpty
            ? null
            : const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: settings.downloadWorksPerRow,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 100 / settings.downloadPreviewHeight,
        ),
        itemCount: state.posts.length,
        itemBuilder: (context, i) {
          final post = state.posts[i];
          return _SelectableThumb(
            post: post,
            selected: state.selected.containsKey(post.id),
            onTap: () =>
                ref.read(downloadListProvider.notifier).toggleSelect(post),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(DownloadListState state, AppSettings settings) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '已选 ${state.selected.length} 张 · 预估 ${PostFormat.fileSize(state.selectedBytes)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(downloadListProvider.notifier)
                        .selectAllOnPage(),
                    child: const Text(Strings.selectAllPage),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(downloadListProvider.notifier)
                        .clearSelection(),
                    child: const Text(Strings.clearSelection),
                  ),
                  FilledButton(
                    onPressed: state.selected.isEmpty
                        ? null
                        : () => _startDownload(state),
                    child: const Text(Strings.startBatchDownload),
                  ),
                ],
              ),
            ),
            _buildPagination(state, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(DownloadListState state, AppSettings settings) {
    if (state.posts.isEmpty && state.page <= 1) {
      return const SizedBox.shrink();
    }
    final canPrev = state.page > 1 && !state.isLoading;
    final canNext =
        !state.isLoading &&
        state.posts.length >= settings.downloadPageSize &&
        !(state.totalPages > 0 && state.page >= state.totalPages);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: canPrev
                ? () => ref
                      .read(downloadListProvider.notifier)
                      .loadPosts(targetPage: state.page - 1)
                : null,
            child: const Text('<'),
          ),
          const SizedBox(width: 16),
          Text(
            state.totalPages > 0
                ? 'Page ${state.page} / ${state.totalPages}'
                : 'Page ${state.page}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: canNext
                ? () => ref
                      .read(downloadListProvider.notifier)
                      .loadPosts(targetPage: state.page + 1)
                : null,
            child: const Text('>'),
          ),
        ],
      ),
    );
  }

  Future<void> _startDownload(DownloadListState state) async {
    final posts = state.selectedPosts;
    if (posts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Strings.batchEmptySelection)),
      );
      return;
    }

    final settings = ref.read(settingsProvider);
    final album = kIsWeb
        ? null
        : BatchDownloadService.albumFolder(state.currentTags, DateTime.now());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Strings.batchConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('数量：${posts.length} 张'),
            Text('预估体积：${PostFormat.fileSize(state.selectedBytes)}'),
            Text(
              settings.batchWebmToMp4
                  ? Strings.batchQualityNoteMp4On
                  : Strings.batchQualityNoteMp4Off,
            ),
            if (!kIsWeb) Text('保存到：$album'),
            if (kIsWeb) const Text('将以浏览器逐个下载'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(Strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(Strings.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final progress = BatchProgress();
    final dio = ref.read(dioProvider);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ProgressDialog(progress: progress),
    );

    final result = await BatchDownloadService.run(
      dio: dio,
      posts: posts,
      webmToMp4: settings.batchWebmToMp4,
      album: album,
      progress: progress,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.cancelled
              ? Strings.batchCancelled
              : '${Strings.batchFinished}：成功 ${result.done}，失败 ${result.failed}',
        ),
      ),
    );
  }
}

/// 选中态颜色：亮绿（与点赞数一致），在任意图片内容上都醒目。
const _selectColor = Color(0xFF35D08A);

/// 单个可选缩略图：封面 + 类型徽标 + 选中高亮/角标。
class _SelectableThumb extends StatelessWidget {
  const _SelectableThumb({
    required this.post,
    required this.selected,
    required this.onTap,
  });

  final E621Post post;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typeBadge = PostFormat.typeBadgeShort(post.file.ext);
    final disabled = post.file.url == null;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            post.preview.url != null
                ? NativeWebImage(imageUrl: post.preview.url!, fit: BoxFit.cover)
                : HiddenPostPlaceholder(
                    deleted: post.flags.deleted,
                    compact: true,
                  ),
            // 透明拦截层：HtmlElementView 会吞掉整格的点击，
            // 没有这一层 GestureDetector 永远收不到 tap。
            Positioned.fill(child: Container(color: Colors.transparent)),
            // 选中高亮：亮绿描边 + 淡绿罩层，比主题蓝醒目得多。
            if (selected)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: _selectColor, width: 3),
                  color: _selectColor.withAlpha(64),
                ),
              ),
            if (selected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 18, color: _selectColor),
                ),
              ),
            // 类型小徽标
            if (typeBadge != null)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(140),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    typeBadge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // 无下载地址：整块置灰禁用
            if (disabled)
              Container(
                color: Colors.black.withAlpha(90),
                child: const Center(
                  child: Icon(Icons.block, color: Colors.white54, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 批量下载进度对话框：完成后自动关闭。
class _ProgressDialog extends StatefulWidget {
  const _ProgressDialog({required this.progress});

  final BatchProgress progress;

  @override
  State<_ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<_ProgressDialog> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.progress,
      builder: (context, _) {
        final finished =
            widget.progress.cancelled ||
            widget.progress.done + widget.progress.failed >=
                widget.progress.total;

        if (finished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
        }

        final total = widget.progress.total;
        final value = total > 0
            ? (widget.progress.done + widget.progress.failed) / total
            : 0.0;

        return AlertDialog(
          title: const Text(Strings.batchProgressTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: value),
              const SizedBox(height: 12),
              Text(
                '${widget.progress.done + widget.progress.failed} / $total · ${Strings.batchFailedCount} ${widget.progress.failed}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => widget.progress.cancel(),
              child: const Text(Strings.cancel),
            ),
          ],
        );
      },
    );
  }
}
