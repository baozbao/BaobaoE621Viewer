import 'dart:ui';

/// 下拉菜单的单行数据（传给 HTML 面板渲染）。
class FilterMenuRowData {
  const FilterMenuRowData({
    required this.label,
    required this.selected,
    required this.onTap,
    this.bg,
    this.text,
    this.check,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// 选中背景（含透明度，null = 面板背景不染色）。
  final Color? bg;

  /// 选中文字色（null = 默认前景色）。
  final Color? text;

  /// 勾颜色。
  final Color? check;
}
