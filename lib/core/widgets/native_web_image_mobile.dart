import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget buildNativeWebImage(String imageUrl, BoxFit fit) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    fit: fit,
    httpHeaders: const {'User-Agent': 'E621Mobile/1.0 (by Baozbao)'},
    placeholder: (context, url) =>
        const Center(child: CircularProgressIndicator()),
    errorWidget: (context, url, error) => const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.redAccent),
          Text('获取失败', style: TextStyle(color: Colors.redAccent, fontSize: 10)),
        ],
      ),
    ),
  );
}
