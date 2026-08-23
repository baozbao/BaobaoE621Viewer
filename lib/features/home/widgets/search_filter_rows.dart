import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/filter_menu_open.dart';
import '../../posts/providers/post_list_provider.dart';
import '../../download/providers/download_list_provider.dart' show MediaType;
import 'filter_menu_panel_data.dart';
import 'filter_menu_panel_stub.dart'
    if (dart.library.js_interop) 'filter_menu_panel_web.dart'
    as menu_panel;

/// 下拉框方案：搜索框下方一排等宽下拉框。
/// 浏览页 = 排序 + 评级；下载页 = 排序 + 评级 + 类型。
///
/// 选项面板是自定义浮层（OverlayEntry），不占布局空间（不会把帖子挤下去）。
/// Web 端浮层会被 HtmlElementView 图片（DOM 层在画布之上）盖住，
/// 因此菜单面板本身也做成 HTML 平台视图 —— 它在 DOM 里排在图片之后
/// （更高图层），天然覆盖在 posts 上，不需要隐藏任何图片。

/// 排序参数 → 中文文案。
const _sortLabels = <String, String>{
  'order:score': '高分',
  'order:favcount': '收藏',
  'order:id': '最新',
  'order:rank': '热度',
  'order:random': '随机',
};

const _sortOrder = <String>[
  'order:score',
  'order:favcount',
  'order:id',
  'order:rank',
  'order:random',
];

String _ratingLabel(RatingFilter r) => switch (r) {
  RatingFilter.safe => Strings.ratingSafe,
  RatingFilter.questionable => Strings.ratingQuestionable,
  RatingFilter.explicit => Strings.ratingExplicit,
};

/// 评级下拉的展示文本：空集或全选 → "全部"；单选 → 该选项文案；多选非全 → "部分"。
String ratingDropdownDisplay(Set<RatingFilter> selected) {
  if (selected.isEmpty || selected.length == RatingFilter.values.length) {
    return Strings.ratingAll;
  }
  if (selected.length == 1) return _ratingLabel(selected.first);
  return Strings.ratingPartial;
}

/// 类型下拉的展示文本：空集或全选 → "全部"；单选 → 该选项。
String mediaTypeDropdownDisplay(Set<MediaType> selected) {
  if (selected.isEmpty || selected.length == MediaType.values.length) {
    return Strings.ratingAll;
  }
  return selected.first == MediaType.image
      ? Strings.mediaTypeImage
      : Strings.mediaTypeVideo;
}

/// 单个下拉项。
class FilterOption {
  const FilterOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
}

/// 各主题的选中项配色。
class _DropdownColors {
  const _DropdownColors({
    required this.bg,
    required this.check,
    required this.text,
  });

  /// 选中项背景（null = 面板背景色，不染色）。
  final Color? bg;
  final Color check;
  final Color text;
}

_DropdownColors _highlightColors(AppThemeVariant v) {
  switch (v) {
    case AppThemeVariant.e621:
      // 背景色 + 蓝色高亮（亮蓝文字与勾）。
      return const _DropdownColors(
        bg: null,
        check: Color(0xFF3B8ED0),
        text: Color(0xFF3B8ED0),
      );
    case AppThemeVariant.dark:
      // 灰色高亮底 + 橘色 √ + 白字。
      return const _DropdownColors(
        bg: Color(0x3DFFFFFF),
        check: Color(0xFFF2A359),
        text: Colors.white,
      );
    case AppThemeVariant.light:
      // 浅色主题保持原样：主色淡底 + 蓝字蓝勾。
      return const _DropdownColors(
        bg: Color(0x2A1E5A8A),
        check: Color(0xFF1E5A8A),
        text: Color(0xFF1E5A8A),
      );
  }
}

/// 通用下拉框：小标题 + 按钮 + 自定义浮层面板（等宽、不挤布局、颜色固定）。
class FilterDropdown extends StatefulWidget {
  const FilterDropdown({
    super.key,
    required this.title,
    required this.displayText,
    required this.options,
    required this.variant,
    this.closeOnSelect = false,
  });

  final String title;
  final String displayText;
  final List<FilterOption> options;
  final AppThemeVariant variant;

  /// 单选下拉（排序）选中后自动收起；多选保持展开。
  final bool closeOnSelect;

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _entry;
  Rect? _panelRect;

  bool get _open => _entry != null;

  @override
  void initState() {
    super.initState();
    registerFilterMenuClose(_close);
  }

  void _toggle() {
    if (_open) {
      _close();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    // 先关闭其它打开的下拉 / 搜索建议面板（互斥，只留一个）。
    closeAllFilterMenus();

    final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    // 面板矩形（选项行高固定 36，高度可精确计算）：
    // 图片组件据此只隐藏被菜单盖住的那部分，其余网格不受影响。
    final panelHeight = widget.options.length * 36.0 + 2.0;
    _panelRect = Rect.fromLTWH(
      offset.dx,
      offset.dy + size.height + 3,
      size.width,
      panelHeight,
    );
    filterMenuRects.value = List<Rect>.from(filterMenuRects.value)
      ..add(_panelRect!);

    _entry = OverlayEntry(
      builder: (context) => _buildPanel(context, offset, size),
    );
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  void _close() {
    if (_entry == null) return;
    if (_panelRect != null) {
      filterMenuRects.value = List<Rect>.from(filterMenuRects.value)
        ..removeWhere((r) => r == _panelRect);
    }
    _panelRect = null;
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    unregisterFilterMenuClose(_close);
    if (_entry != null) {
      if (_panelRect != null) {
        filterMenuRects.value = List<Rect>.from(filterMenuRects.value)
          ..removeWhere((r) => r == _panelRect);
      }
      _entry?.remove();
    }
    super.dispose();
  }

  void _handleOptionTap(FilterOption o) {
    o.onTap();
    if (widget.closeOnSelect) {
      _close();
    } else {
      // 多选：刷新面板（Web 重建 HTML 视图，io 重画 Flutter 面板）。
      _entry?.markNeedsBuild();
    }
  }

  Widget _buildPanel(BuildContext context, Offset offset, Size size) {
    final scheme = Theme.of(context).colorScheme;
    final colors = _highlightColors(widget.variant);

    final rows = <FilterMenuRowData>[
      for (final o in widget.options)
        FilterMenuRowData(
          label: o.label,
          selected: o.selected,
          bg: o.selected ? colors.bg : null,
          text: o.selected ? colors.text : null,
          check: o.selected ? colors.check : null,
          onTap: () => _handleOptionTap(o),
        ),
    ];

    String webViewId = '';
    if (kIsWeb) {
      webViewId = menu_panel.registerFilterMenuPanel(
        rows: rows,
        surfaceArgb: scheme.surface.toARGB32(),
        outlineArgb: scheme.outline.toARGB32(),
        onSurfaceArgb: scheme.onSurface.toARGB32(),
      );
    }

    return Stack(
      children: [
        // 点面板外（筛选栏以下区域）关闭。
        // 不拦截搜索栏/筛选栏：点搜索框可一键关闭本菜单并打开搜索建议。
        Positioned(
          top: offset.dy + size.height + 3,
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 3,
          width: size.width,
          height: rows.length * 36.0 + 2.0,
          // Web：HTML 平台视图（排在图片 DOM 之后 → 盖在 posts 上）；
          // io：普通 Flutter 面板。
          child: kIsWeb
              ? HtmlElementView(viewType: webViewId)
              : _buildFlutterPanel(rows, colors),
        ),
      ],
    );
  }

  Widget _buildFlutterPanel(
    List<FilterMenuRowData> rows,
    _DropdownColors colors,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 4,
      color: scheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in rows)
              InkWell(
                onTap: row.onTap,
                child: SizedBox(
                  height: 36,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    color: row.selected ? colors.bg : null,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          child: row.selected
                              ? Icon(Icons.check, size: 16, color: colors.check)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            row.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: row.selected ? colors.text : null,
                              fontWeight: row.selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        InkWell(
          key: _buttonKey,
          onTap: _toggle,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.displayText,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 18,
                  color: scheme.onSurface.withAlpha(160),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 排序下拉（单选，选中后自动收起）。
class SortDropdown extends StatelessWidget {
  const SortDropdown({
    super.key,
    required this.currentSort,
    required this.onSelect,
    required this.variant,
  });

  final String currentSort;
  final ValueChanged<String> onSelect;
  final AppThemeVariant variant;

  @override
  Widget build(BuildContext context) {
    final label = _sortLabels[currentSort] ?? _sortLabels.values.first;
    return FilterDropdown(
      title: Strings.sortLabel,
      displayText: label,
      variant: variant,
      closeOnSelect: true,
      options: [
        for (final param in _sortOrder)
          FilterOption(
            label: _sortLabels[param]!,
            selected: currentSort == param,
            onTap: () => onSelect(param),
          ),
      ],
    );
  }
}

/// 评级下拉（多选，保持展开）。
class RatingDropdown extends StatelessWidget {
  const RatingDropdown({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.onClear,
    required this.variant,
  });

  final Set<RatingFilter> selected;
  final ValueChanged<RatingFilter> onToggle;
  final VoidCallback onClear;
  final AppThemeVariant variant;

  @override
  Widget build(BuildContext context) {
    return FilterDropdown(
      title: Strings.ratingLabel,
      displayText: ratingDropdownDisplay(selected),
      variant: variant,
      options: [
        FilterOption(
          label: Strings.ratingAll,
          selected:
              selected.isEmpty || selected.length == RatingFilter.values.length,
          onTap: onClear,
        ),
        for (final r in RatingFilter.values)
          FilterOption(
            label: _ratingLabel(r),
            selected: selected.contains(r),
            onTap: () => onToggle(r),
          ),
      ],
    );
  }
}

/// 媒体类型下拉（下载页专用，多选：全部/图片/视频）。
class MediaTypeDropdown extends StatelessWidget {
  const MediaTypeDropdown({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.onClear,
    required this.variant,
  });

  final Set<MediaType> selected;
  final ValueChanged<MediaType> onToggle;
  final VoidCallback onClear;
  final AppThemeVariant variant;

  @override
  Widget build(BuildContext context) {
    return FilterDropdown(
      title: Strings.mediaTypeLabel,
      displayText: mediaTypeDropdownDisplay(selected),
      variant: variant,
      options: [
        FilterOption(
          label: Strings.ratingAll,
          selected:
              selected.isEmpty || selected.length == MediaType.values.length,
          onTap: onClear,
        ),
        FilterOption(
          label: Strings.mediaTypeImage,
          selected: selected.contains(MediaType.image),
          onTap: () => onToggle(MediaType.image),
        ),
        FilterOption(
          label: Strings.mediaTypeVideo,
          selected: selected.contains(MediaType.video),
          onTap: () => onToggle(MediaType.video),
        ),
      ],
    );
  }
}

/// 浏览页筛选栏：排序 + 评级（两个等宽下拉框）。
class BrowseFilterRow extends StatelessWidget {
  const BrowseFilterRow({
    super.key,
    required this.currentSort,
    required this.onSelectSort,
    required this.ratingFilters,
    required this.onToggleRating,
    required this.onClearRating,
    required this.variant,
  });

  final String currentSort;
  final ValueChanged<String> onSelectSort;
  final Set<RatingFilter> ratingFilters;
  final ValueChanged<RatingFilter> onToggleRating;
  final VoidCallback onClearRating;
  final AppThemeVariant variant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SortDropdown(
              currentSort: currentSort,
              onSelect: onSelectSort,
              variant: variant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RatingDropdown(
              selected: ratingFilters,
              onToggle: onToggleRating,
              onClear: onClearRating,
              variant: variant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 下载页筛选栏：排序 + 评级 + 类型（三个等宽下拉框）。
class DownloadFilterRow extends StatelessWidget {
  const DownloadFilterRow({
    super.key,
    required this.currentSort,
    required this.onSelectSort,
    required this.ratingFilters,
    required this.onToggleRating,
    required this.onClearRating,
    required this.mediaTypes,
    required this.onToggleMediaType,
    required this.onClearMediaType,
    required this.variant,
  });

  final String currentSort;
  final ValueChanged<String> onSelectSort;
  final Set<RatingFilter> ratingFilters;
  final ValueChanged<RatingFilter> onToggleRating;
  final VoidCallback onClearRating;
  final Set<MediaType> mediaTypes;
  final ValueChanged<MediaType> onToggleMediaType;
  final VoidCallback onClearMediaType;
  final AppThemeVariant variant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SortDropdown(
              currentSort: currentSort,
              onSelect: onSelectSort,
              variant: variant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RatingDropdown(
              selected: ratingFilters,
              onToggle: onToggleRating,
              onClear: onClearRating,
              variant: variant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: MediaTypeDropdown(
              selected: mediaTypes,
              onToggle: onToggleMediaType,
              onClear: onClearMediaType,
              variant: variant,
            ),
          ),
        ],
      ),
    );
  }
}
