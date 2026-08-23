import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

String _objectFit(BoxFit fit) {
  switch (fit) {
    case BoxFit.cover:
      return 'cover';
    case BoxFit.fill:
      return 'fill';
    case BoxFit.contain:
      return 'contain';
    case BoxFit.fitWidth:
      return '100% auto';
    case BoxFit.fitHeight:
      return 'auto 100%';
    case BoxFit.none:
      return 'none';
    case BoxFit.scaleDown:
      return 'scale-down';
  }
}

Widget buildNativeWebImage(String imageUrl, BoxFit fit) {
  // viewType 必须把 fit 也编码进去：同一个 URL 会以不同 fit 出现在
  // 首页网格 / 历史列表 / 详情页，若只按 URL 生成 viewId，
  // registerViewFactory 会互相覆盖，导致部分图片用错 object-fit（拉伸）。
  final String viewId = 'img-${imageUrl.hashCode}-${fit.index}';

  // Register the view factory
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    final img = web.HTMLImageElement()
      ..src = imageUrl
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = _objectFit(fit)
      ..style.pointerEvents = 'none';
    return img;
  });

  return HtmlElementView(viewType: viewId);
}
