import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
import 'filter_menu_panel_data.dart';

int _counter = 0;

/// 注册一个 HTML 菜单面板（平台视图），返回 viewType。
///
/// 为什么用 HTML 而不是 Flutter 浮层：Flutter Web 上帖子预览图
/// （HtmlElementView）是 DOM 元素、永远盖在画布之上。把菜单也做成
/// 平台视图后，它在 DOM 里排在图片之后（更高图层），天然覆盖在 posts 上，
/// 不需要隐藏任何图片。
String registerFilterMenuPanel({
  required List<FilterMenuRowData> rows,
  required int surfaceArgb,
  required int outlineArgb,
  required int onSurfaceArgb,
}) {
  final viewId = 'filter-menu-${_counter++}';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (viewId) {
    final div = web.HTMLDivElement()
      ..style.backgroundColor = _css(surfaceArgb)
      ..style.border = '1px solid ${_css(_opaque(outlineArgb))}'
      ..style.borderRadius = '8px'
      ..style.overflow = 'hidden'
      ..style.boxShadow = '0 4px 14px rgba(0,0,0,0.4)';

    for (final row in rows) {
      final rowDiv = web.HTMLDivElement()
        ..style.height = '36px'
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.padding = '0 10px'
        ..style.cursor = 'pointer';
      if (row.bg != null) {
        rowDiv.style.backgroundColor = _css(row.bg!.toARGB32());
      }

      final check = web.HTMLSpanElement()
        ..textContent = row.selected ? '✓' : ''
        ..style.width = '16px'
        ..style.display = 'inline-block';
      if (row.selected && row.check != null) {
        check.style.color = _css(_opaque(row.check!.toARGB32()));
      }

      final label = web.HTMLSpanElement()
        ..textContent = row.label
        ..style.fontSize = '12px'
        ..style.fontWeight = row.selected ? '600' : '400';
      final textArgb = row.text != null
          ? _opaque(row.text!.toARGB32())
          : _opaque(onSurfaceArgb);
      label.style.color = _css(textArgb);

      rowDiv.append(check);
      rowDiv.append(label);
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
