import 'search_suggestion_panel_data.dart';

/// 移动端不用 HTML 面板（返回空 id，不会用到）。
String registerSearchSuggestionPanel({
  required List<SearchSuggestionRowData> rows,
  required int surfaceArgb,
  required int outlineArgb,
  required int onSurfaceArgb,
}) {
  return '';
}
