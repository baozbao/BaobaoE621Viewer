import 'package:flutter/material.dart';
import 'native_web_image_stub.dart'
    if (dart.library.js_interop) 'native_web_image_web.dart'
    if (dart.library.io) 'native_web_image_mobile.dart';

class NativeWebImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const NativeWebImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return buildNativeWebImage(imageUrl, fit);
  }
}
