import 'package:flutter/material.dart';

/// 服务端隐藏帖子的占位。
///
/// e621 对"不给当前请求者看"的帖子仍会返回全部元数据（id/tags/md5/score...），
/// 只把 file/preview/sample 的 url 全部置为 null，没有单独的"被隐藏"字段：
/// - `flags.deleted == true`  → 帖子已删除（登录也看不了）；
/// - `flags.deleted == false` → 未登录被隐藏（游客全局黑名单 / DNP），
///   对应网页端的 "You must be logged in to view this image"，
///   登录（login + api_key）后 API 会正常下发 url。
class HiddenPostPlaceholder extends StatelessWidget {
  /// true = 帖子已删除；false = 未登录被隐藏。
  final bool deleted;

  /// true = 列表缩略图的紧凑尺寸；false = 详情页大尺寸。
  final bool compact;

  const HiddenPostPlaceholder({
    super.key,
    this.deleted = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withAlpha(140);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            deleted ? Icons.delete_outline : Icons.lock_outline,
            size: compact ? 28 : 48,
            color: color,
          ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            deleted ? '帖子已删除' : '仅登录后可见',
            style: TextStyle(color: color, fontSize: compact ? 10 : 14),
          ),
          if (!compact && !deleted) ...[
            const SizedBox(height: 4),
            Text(
              'e621 对未登录用户隐藏了此图片',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(90),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
