import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

Widget buildNativeWebImage(String imageUrl, BoxFit fit) {
  final String viewId = 'img-${imageUrl.hashCode}';
  
  // Register the view factory
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int viewId) {
      final img = web.HTMLImageElement()
        ..src = imageUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = fit == BoxFit.cover ? 'cover' : 'contain'
        ..style.pointerEvents = 'none';
      return img;
    },
  );

  return HtmlElementView(viewType: viewId);
}
