
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/posts/models/e621_post.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../../../core/utils/post_format.dart';

/// 诊断用：在 Chrome Console 输出每个 post 的 showBottomBar 计算过程。
class PostCardDiagnostic extends ConsumerWidget {
  final E621Post post;
  final int index;

  const PostCardDiagnostic({
    super.key,
    required this.post,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final typeBadge = PostFormat.typeBadge(post.file.ext);
    final showBottomBar =
        (settings.showPreviewType && typeBadge != null) ||
        settings.showPreviewUpvote ||
        settings.showPreviewScore;

    // 输出到 DevTools Console
    debugPrint(
      'POST #$index id=${post.id} '
      'ext="${post.file.ext}" '
      'typeBadge=$typeBadge '
      'showType=${settings.showPreviewType} '
      'showUp=${settings.showPreviewUpvote} '
      'showScore=${settings.showPreviewScore} '
      '=> showBottomBar=$showBottomBar'
    );

    return Container(
      color: showBottomBar ? Colors.green.withAlpha(50) : Colors.red.withAlpha(50),
      child: Center(
        child: Text(
          'Post ${post.id}\n'
          'ext: ${post.file.ext}\n'
          'bar: $showBottomBar',
          style: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}
