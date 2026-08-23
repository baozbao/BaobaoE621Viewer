import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/post_format.dart';
import '../../../core/widgets/hidden_post_placeholder.dart';
import '../../../core/widgets/native_web_image.dart';
import '../../posts/views/post_detail_screen.dart';
import '../models/history_entry.dart';

class HistoryListItem extends StatelessWidget {
  final HistoryEntry entry;
  final int index;

  const HistoryListItem({super.key, required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final post = entry.post;
    final artist = post.tags.artist.take(2).join(', ');
    final character = post.tags.character.take(2).join(', ');
    final subtitle = [
      if (artist.isNotEmpty) artist,
      if (character.isNotEmpty) character,
    ].join(' · ');
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(
          '/post',
          extra: PostDetailArgs(index: index, source: PostDetailSource.history),
        ),
        child: SizedBox(
          height: 104,
          child: Row(
            children: [
              SizedBox(
                width: 104,
                height: 104,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (post.preview.url == null)
                      HiddenPostPlaceholder(
                        deleted: post.flags.deleted,
                        compact: true,
                      )
                    else
                      NativeWebImage(
                        imageUrl: post.preview.url!,
                        fit: BoxFit.cover,
                      ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 3,
                        color: PostFormat.ratingColor(post.rating),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(160),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          post.file.ext.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '#${post.id}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(entry.viewedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: onSurface.withAlpha(130),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle.isEmpty ? '未知作者' : subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: onSurface.withAlpha(170),
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: PostFormat.ratingColor(
                                post.rating,
                              ).withAlpha(35),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: PostFormat.ratingColor(
                                  post.rating,
                                ).withAlpha(180),
                              ),
                            ),
                            child: Text(
                              PostFormat.ratingLabel(post.rating),
                              style: TextStyle(
                                color: PostFormat.ratingColor(post.rating),
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_upward,
                            size: 14,
                            color: PostFormat.scoreColor(post.score.total),
                          ),
                          const SizedBox(width: 1),
                          Text(
                            PostFormat.compactCount(post.score.total),
                            style: TextStyle(
                              color: PostFormat.scoreColor(post.score.total),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            PostFormat.compactCount(post.favCount),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
