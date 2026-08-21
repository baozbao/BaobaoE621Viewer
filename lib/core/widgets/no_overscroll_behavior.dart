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
}
