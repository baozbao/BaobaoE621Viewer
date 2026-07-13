import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/models/e621_post.dart';
import '../../posts/views/post_detail_screen.dart';
import '../../../core/utils/post_format.dart';
import '../../../core/widgets/native_web_image.dart';
import '../../../core/widgets/hidden_post_placeholder.dart';

class PostCard extends ConsumerWidget {
  final E621Post post;

  /// 详情页返回时定位用的索引（B2 画廊）。
  final int index;

  /// true = 等高网格模式（图片 cover 填满固定单元格）；
  /// false = 瀑布流模式（卡片高度跟随图片原始宽高比）。
  final bool fixedHeight;

  /// 自定义点击行为。默认跳详情页（数据源 = 首页列表）。
  /// 收藏页等需要指定不同数据源时传入。
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.index = 0,
    this.fixedHeight = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingColor = PostFormat.ratingColor(post.rating);

    // url == null 不是加载失败，而是 e621 服务端故意抹掉：
    // 未登录命中全局黑名单 / DNP，或帖子已删除（见 HiddenPostPlaceholder）。
    Widget image = post.preview.url != null
        ? NativeWebImage(
            imageUrl: post.preview.url!,
            fit: fixedHeight ? BoxFit.cover : BoxFit.fill,
          )
        : HiddenPostPlaceholder(deleted: post.flags.deleted, compact: true);

    // 瀑布流模式下用原始宽高比撑开卡片高度，避免裁剪。
    if (!fixedHeight) {
      final w = post.preview.width > 0 ? post.preview.width : post.file.width;
      final h = post.preview.height > 0 ? post.preview.height : post.file.height;
      final ratio = (w > 0 && h > 0) ? w / h : 1.0;
      image = AspectRatio(aspectRatio: ratio, child: image);
    }

    final content = Stack(
      fit: fixedHeight ? StackFit.expand : StackFit.loose,
      children: [
        image,

        // 透明层：拦截点击（HtmlElementView 在 Web 上会吞掉点击）。
        Positioned.fill(child: Container(color: Colors.transparent)),

        // 左缘评级色条（A2）。
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(width: 3, color: ratingColor),
        ),

        // 底部渐变 + 分数（右）/ 类型徽标（左）。
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (PostFormat.typeBadge(post.file.ext) != null)
                  _Badge(text: PostFormat.typeBadge(post.file.ext)!),
                const Spacer(),
                Icon(Icons.arrow_upward, size: 12, color: PostFormat.scoreColor(post.score.total)),
                const SizedBox(width: 1),
                Text(
                  PostFormat.compactCount(post.score.total),
                  style: TextStyle(
                    color: PostFormat.scoreColor(post.score.total),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap ??
          () => context.push('/post', extra: PostDetailArgs(index: index)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: content,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(160),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
