import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/models/e621_post.dart';
import '../../../core/services/log_service.dart';
import '../../../core/widgets/native_web_image.dart';

class PostCard extends ConsumerWidget {
  final E621Post post;
  
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDynamic = post.file.ext == 'webm' || post.file.ext == 'gif' || post.file.ext == 'mp4' || post.file.ext == 'swf';
    
    return GestureDetector(
      onTap: () {
        context.push('/post', extra: post);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
          // Image
          if (post.preview.url != null)
            NativeWebImage(
              imageUrl: post.preview.url!,
              fit: BoxFit.cover,
            )
          else
            const Center(child: Icon(Icons.broken_image)),
            
          // Transparent overlay to catch clicks (HtmlElementView steals clicks otherwise)
          Positioned.fill(
            child: Container(color: Colors.transparent),
          ),
          
          // Extension badge
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                post.file.ext,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Stats badge
          Positioned(
            bottom: 4,
            left: 4,
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                const SizedBox(width: 2),
                Text(
                  '${post.favCount}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: Colors.black87, blurRadius: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
