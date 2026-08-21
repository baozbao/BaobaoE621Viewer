import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/models/e621_post.dart';
import '../../posts/views/post_detail_screen.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/post_format.dart';
import '../../../core/widgets/native_web_image.dart';
import '../../../core/widgets/hidden_post_placeholder.dart';

class PostCard extends ConsumerWidget {
  final E621Post post;

  /// 详情页返回时定位用的索引（B2 画廊）。
  final int index;

  /// true = 等高网格模式（图片 contain 完整显示，不裁切、不变形）；
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
    final settings = ref.watch(settingsProvider);
    final typeBadge = PostFormat.typeBadge(post.file.ext);
    final showBottomBar =
        (settings.showPreviewType && typeBadge != null) ||
        settings.showPreviewUpvote ||
        settings.showPreviewScore;

    // url == null 不是加载失败，而是 e621 服务端故意抹掉：
    // 未登录命中全局黑名单 / DNP，或帖子已删除（见 HiddenPostPlaceholder）。
    Widget image = post.preview.url != null
        ? NativeWebImage(
            imageUrl: post.preview.url!,
            // 等高网格用 contain：完整显示、不裁切、不变形（不做强制填满）。
            // 瀑布流用 fill：AspectRatio 已按原图比例撑开盒子，fill 与 contain 视觉一致。
            fit: fixedHeight ? BoxFit.contain : BoxFit.fill,
          )
        : HiddenPostPlaceholder(deleted: post.flags.deleted, compact: true);

    // 瀑布流模式下用原始宽高比撑开卡片高度，避免裁剪。
    var cardRatio = 1.0;
    if (!fixedHeight) {
      final w = post.preview.width > 0 ? post.preview.width : post.file.width;
      final h = post.preview.height > 0
          ? post.preview.height
          : post.file.height;
      cardRatio = (w > 0 && h > 0) ? w / h : 1.0;
      image = AspectRatio(aspectRatio: cardRatio, child: image);
    }

    // 图片区域：图片 + 点击拦截层。
    //
    // 注意：HtmlElementView（NativeWebImage）在 Web 上是独立 DOM 层，
    // 永远合成在 CanvasKit 画布之上。任何与它重叠的 Flutter 覆盖层都会被
    // 图片 DOM 盖住 —— 这就是得分框"部分卡片消失"的根因。
    // 因此信息栏必须放到图片下方（Column），绝不能叠在图片上。
    final imageRegion = Stack(
      fit: fixedHeight ? StackFit.expand : StackFit.loose,
      children: [
        image,

        // 透明层：拦截点击（HtmlElementView 在 Web 上会吞掉点击）。
        Positioned.fill(child: Container(color: Colors.transparent)),
      ],
    );

    final Widget content;
    if (!showBottomBar) {
      content = imageRegion;
    } else {
      content = Column(
        mainAxisSize: fixedHeight ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 等高网格：图片填满"格子高度 - 信息栏高度"；
          // 瀑布流：图片按原始宽高比自然撑高。
          if (fixedHeight) Expanded(child: imageRegion) else imageRegion,
          _buildInfoBar(settings, typeBadge),
        ],
      );
    }

    final light = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      onTap:
          onTap ??
          () => context.push('/post', extra: PostDetailArgs(index: index)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppTheme.cardShadow(light: light),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: content,
        ),
      ),
    );
  }

  /// 信息栏（得分框）：实色底，位于图片下方，与 HtmlElementView 不重叠。
  Widget _buildInfoBar(AppSettings settings, String? typeBadge) {
    return Container(
      // 信息栏背景：三段半透明渐变，只作用于背景容器，不影响图标和文字。
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x14000000), // 顶部 8% 黑（几乎透明）
            Color(0x59000000), // 中部 35% 黑
            Color(0x99000000), // 底部 60% 黑
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      // 类型徽标必须显示（媒体类型是关键信息），窄卡片下换短文案而不是
      // 隐藏，也不用 FittedBox 缩字号 —— 缩放没有下限，每行 4~6 张时
      // 会把字压到 3~4px 高，看着就像徽标没渲染。
      //
      // 宽度一律用 TextPainter 实测，不用常数估：'56.3k' 比 '10' 宽一倍，
      // 估算会在真实数据上溢出（Row 溢出后 Spacer 归零、右侧被裁）。
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final hasType = settings.showPreviewType && typeBadge != null;
          final favText = PostFormat.compactCount(post.favCount);
          final upText = PostFormat.compactCount(post.score.total);

          // 每组计数 = 图标 12 + 间隔 1 + 数字实测宽。
          final favW = settings.showPreviewScore
              ? 13 + _measure(favText, _countStyle)
              : 0.0;
          final upW = settings.showPreviewUpvote
              ? 13 + _measure(upText, _countStyle)
              : 0.0;
          final gap = favW > 0 && upW > 0 ? 6.0 : 0.0;

          // 徽标 = 文字实测宽 + 左右 padding 6*2 + 边框 0.5*2。
          final fullLabel = typeBadge;
          final shortLabel = PostFormat.typeBadgeShort(post.file.ext);
          final fullW = !hasType ? 0.0 : 13 + _measure(fullLabel!, _badgeStyle);
          final shortW = !hasType
              ? 0.0
              : 13 + _measure(shortLabel!, _badgeStyle);

          // 逐级降级，每级都用实测宽判断装不装得下。
          // 下限：计数至少留一组，绝不清空。
          var typeW = fullW;
          var useShort = false;
          var showFav = favW > 0;
          var showUp = upW > 0;

          double need() =>
              typeW +
              (showFav ? favW : 0) +
              (showUp ? upW : 0) +
              (showFav && showUp ? gap : 0) +
              (typeW > 0 && (showFav || showUp) ? 4 : 0);

          // 1) 类型徽标退短版。
          if (need() > w && hasType) {
            useShort = true;
            typeW = shortW;
          }
          // 2) 两组计数只留一组（收藏比得分更常参考）。
          if (need() > w && showFav && showUp) showUp = false;

          final label = !hasType ? null : (useShort ? shortLabel : fullLabel);
          final showCounts = showFav || showUp;

          if (label == null && !showCounts) {
            return const SizedBox.shrink();
          }

          return Row(
            children: [
              if (label != null) _Badge(text: label),
              const Spacer(),
              if (showCounts)
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showFav) ...[
                          const Icon(
                            Icons.favorite,
                            size: 12,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 1),
                          _OverlayCount(
                            text: PostFormat.compactCount(post.favCount),
                            color: Colors.redAccent,
                          ),
                        ],
                        if (showFav && showUp) const SizedBox(width: 6),
                        if (showUp) ...[
                          Icon(
                            Icons.arrow_upward,
                            size: 12,
                            color: PostFormat.scoreColor(post.score.total),
                          ),
                          const SizedBox(width: 1),
                          _OverlayCount(
                            text: PostFormat.compactCount(post.score.total),
                            color: PostFormat.scoreColor(post.score.total),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// 实测与渲染必须共用同一份样式，否则量出来的宽度对不上实际绘制。
const _badgeStyle = TextStyle(
  color: Colors.white,
  fontSize: 10,
  fontWeight: FontWeight.bold,
  letterSpacing: 0.3,
);

const _countStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.bold);

/// 单行文本的实际绘制宽度（向上取整，避免半像素导致的临界溢出）。
double _measure(String text, TextStyle style) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return tp.width.ceilToDouble();
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withAlpha(38), width: 0.5),
      ),
      child: Text(text, style: _badgeStyle),
    );
  }
}

class _OverlayCount extends StatelessWidget {
  final String text;
  final Color color;

  const _OverlayCount({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _countStyle.copyWith(
        color: color,
        shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
      ),
    );
  }
}
