import 'package:flutter/material.dart';

/// 与帖子展示相关的通用格式化 / 配色工具。
/// 评级配色对齐 e621 官网心智：s 绿 / q 黄 / e 红。
class PostFormat {
  const PostFormat._();

  /// 评级色（用于卡片色条、评级文字等）。
  static Color ratingColor(String rating) {
    switch (rating) {
      case 's':
        return const Color(0xFF41C47D); // 绿
      case 'q':
        return const Color(0xFFFFB340); // 黄
      case 'e':
        return const Color(0xFFFF5D5D); // 红
      default:
        return Colors.grey;
    }
  }

  /// 评级中文全称。
  static String ratingLabel(String rating) {
    switch (rating) {
      case 's':
        return 'Safe';
      case 'q':
        return 'Questionable';
      case 'e':
        return 'Explicit';
      default:
        return '未知';
    }
  }

  /// 大数字缩写：1234 -> 1.2k，1200000 -> 1.2m。
  static String compactCount(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) {
      final v = n / 1000;
      return '${v.toStringAsFixed(v >= 100 ? 0 : 1)}k';
    }
    final v = n / 1000000;
    return '${v.toStringAsFixed(v >= 100 ? 0 : 1)}m';
  }

  /// 文件大小可读化。
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// 是否为动态内容（视频 / GIF / Flash）。
  static bool isAnimated(String ext) =>
      ext == 'webm' || ext == 'mp4' || ext == 'gif' || ext == 'swf';

  /// 是否为视频（需要播放器）。
  static bool isVideo(String ext) => ext == 'webm' || ext == 'mp4';

  /// 分数配色：正分绿、零灰、负分红。
  static Color scoreColor(int score) {
    if (score > 0) return const Color(0xFF41C47D);
    if (score < 0) return const Color(0xFFFF5D5D);
    return Colors.grey;
  }

  /// 卡片右下角类型徽标文案（图片返回 null 表示不显示）。
  static String? typeBadge(String ext) {
    switch (ext) {
      case 'webm':
      case 'mp4':
        return '▶ ${ext.toUpperCase()}';
      case 'gif':
        return 'GIF';
      case 'swf':
        return 'SWF';
      default:
        return null;
    }
  }

  /// e621 tag category 编号 → 配色（用于搜索补全项、标签分组）。
  /// 0 general, 1 artist, 3 copyright, 4 character, 5 species, 6 invalid,
  /// 7 meta, 8 lore。
  static Color tagCategoryColor(int category) {
    switch (category) {
      case 1:
        return const Color(0xFFFFB85C); // 画师 橙
      case 3:
        return const Color(0xFF7EE2A8); // 版权 绿
      case 4:
        return const Color(0xFFC792EA); // 角色 紫
      case 5:
        return const Color(0xFF82AAFF); // 种族 蓝
      case 7:
        return const Color(0xFFB0BEC5); // 元信息 灰蓝
      default:
        return const Color(0xFF9AA4B2); // 通用 / 其它
    }
  }
}
