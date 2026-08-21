import 'package:flutter/material.dart';

/// 栏背景：半透明底色 + 底部描边，让顶栏浮在内容之上而不是一块死板的实色。
///
/// 曾经用 BackdropFilter 做真磨砂，但滚动时滤镜采样的是上一帧已合成的背景，
/// 与当前帧错开一个帧的位移，顶栏文字看起来会跟着抖。改成半透明实色后
/// 滚动稳定，代价是没有模糊感。
///
/// 只做视觉，不参与布局与手势 —— 调用方把它塞进 flexibleSpace 之类的
/// 装饰位，尺寸由外层决定。
class FrostedSurface extends StatelessWidget {
  const FrostedSurface({
    super.key,
    this.tint,
    this.opacity = 0.94,
    this.border,
    this.child,
  });

  /// 玻璃的底色。默认取 AppBar 背景，保持各主题的识别度。
  final Color? tint;

  /// 底色不透明度。没有模糊兜底，压在图片上时不能太低，否则文字看不清。
  final double opacity;

  /// 底部描边，用来划出栏与内容的边界。
  final Color? border;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base =
        tint ?? theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: base.withValues(alpha: opacity),
        border: border == null
            ? null
            : Border(bottom: BorderSide(color: border!, width: 0.5)),
      ),
      child: child,
    );
  }
}
