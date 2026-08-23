import 'dart:ui';
import 'package:flutter/foundation.dart';

/// 当前打开的下拉筛选菜单的矩形列表（全局坐标）。
///
/// 用于在菜单打开期间锁定列表滚动（防止内容在浮层下方滚动）。
final ValueNotifier<List<Rect>> filterMenuRects = ValueNotifier<List<Rect>>([]);

final List<VoidCallback> _closeCallbacks = <VoidCallback>[];

/// 菜单打开时注册自己的关闭回调；关闭/销毁时注销。
void registerFilterMenuClose(VoidCallback cb) => _closeCallbacks.add(cb);

void unregisterFilterMenuClose(VoidCallback cb) => _closeCallbacks.remove(cb);

/// 关闭所有打开的下拉菜单（切换 tab / 页面时调用）。
void closeAllFilterMenus() {
  for (final cb in List<VoidCallback>.from(_closeCallbacks)) {
    cb();
  }
}
