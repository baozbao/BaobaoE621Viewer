import 'dart:ui';

/// 搜索建议面板（历史/标签补全）的单行数据。
class SearchSuggestionRowData {
  const SearchSuggestionRowData({
    required this.text,
    required this.onTap,
    this.color,
    this.sub,
    this.count,
    this.onDelete,
  });

  final String text;
  final VoidCallback onTap;

  /// 左侧分类色点（标签补全用）。
  final Color? color;

  /// 副文本（antecedent →）。
  final String? sub;

  /// 右侧数量（x 帖）。
  final String? count;

  /// 删除按钮（历史行用）。
  final VoidCallback? onDelete;
}
