import 'package:flutter/material.dart';

/// 滚到边界后不做任何越界反馈：既不拉伸内容，也不画光晕。
///
/// Android 上 MaterialApp 默认用 StretchingOverscrollIndicator，列表拉到底会把
/// 整片内容按比例压缩再弹回 —— 图片网格里这个形变很明显。glow 一并去掉，
/// 保持各平台一致的"到底就是到底"。
class NoOverscrollBehavior extends MaterialScrollBehavior {
  const NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  /// 关掉桌面/Web 自动滚动条：浏览页的标题（SliverAppBar）在滚动视图内部，
  /// 自动滚动条会纵贯整个视口、看起来"穿到标题上面"；下载页则正常，
  /// 两页表现不一致。统一不画（手动加 Scrollbar 的地方不受影响）。
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
