import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
import 'search_suggestion_panel_data.dart';

int _counter = 0;

/// 注册搜索建议的 HTML 面板（平台视图）。
/// 与筛选下拉同理：DOM 层排在图片之后，天然盖在 posts 上。
String registerSearchSuggestionPanel({
  required List<SearchSuggestionRowData> rows,
  required int surfaceArgb,
  required int outlineArgb,
  required int onSurfaceArgb,
}) {
  final viewId = 'search-suggestion-${_counter++}';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (viewId) {
    final div = web.HTMLDivElement()
      ..style.backgroundColor = _css(surfaceArgb)
      ..style.border = '1px solid ${_css(_opaque(outlineArgb))}'
      ..style.borderRadius = '8px'
      ..style.overflowY = 'auto'
      ..style.maxHeight = '300px'
      ..style.boxShadow = '0 4px 14px rgba(0,0,0,0.4)';

    if (rows.isEmpty) {
      final empty = web.HTMLDivElement()
        ..textContent = '暂无搜索历史'
        ..style.padding = '16px'
        ..style.fontSize = '13px'
        ..style.color = _css(_opaque(onSurfaceArgb));
      div.append(empty);
      return div;
    }

    for (final row in rows) {
      final rowDiv = web.HTMLDivElement()
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.padding = '7px 10px'
        ..style.cursor = 'pointer';

      if (row.color != null) {
        final dot = web.HTMLSpanElement()
          ..style.width = '8px'
          ..style.height = '8px'
          ..style.borderRadius = '50%'
          ..style.backgroundColor = _css(_opaque(row.color!.toARGB32()))
          ..style.marginRight = '8px'
          ..style.flexShrink = '0';
        rowDiv.append(dot);
      }

      final main = web.HTMLDivElement()..style.flex = '1';
      final title = web.HTMLDivElement()
        ..textContent = row.text
        ..style.fontSize = '13px'
        ..style.color = _css(_opaque(onSurfaceArgb));
      main.append(title);
      if (row.sub != null) {
        final sub = web.HTMLDivElement()
          ..textContent = row.sub!
          ..style.fontSize = '11px'
          ..style.color = _css(_opaque(onSurfaceArgb));
        main.append(sub);
      }
      rowDiv.append(main);

      if (row.count != null) {
        final count = web.HTMLSpanElement()
          ..textContent = row.count!
          ..style.fontSize = '11px'
          ..style.color = _css(_opaque(onSurfaceArgb))
          ..style.marginRight = '8px';
        rowDiv.append(count);
      }

      if (row.onDelete != null) {
        final del = web.HTMLButtonElement()
          ..textContent = '×'
          ..style.border = 'none'
          ..style.background = 'transparent'
          ..style.color = _css(_opaque(onSurfaceArgb))
          ..style.fontSize = '16px'
          ..style.cursor = 'pointer'
          ..style.padding = '0 6px';
        del.onclick = ((web.Event e) {
          e.stopPropagation();
          row.onDelete!();
        }).toJS;
        rowDiv.append(del);
      }

      rowDiv.onclick = ((web.Event e) {
        row.onTap();
      }).toJS;
      div.append(rowDiv);
    }

    return div;
  });

  return viewId;
}

int _opaque(int argb) => 0xFF000000 | argb;

String _css(int argb) {
  final r = (argb >> 16) & 0xFF;
  final g = (argb >> 8) & 0xFF;
  final b = argb & 0xFF;
  final a = ((argb >> 24) & 0xFF) / 255.0;
  return 'rgba($r,$g,$b,${a.toStringAsFixed(3)})';
}
