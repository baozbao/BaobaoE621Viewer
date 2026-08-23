import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_e621_viewer/core/theme/app_theme.dart';

/// Switch 按下时的叠层必须是透明的。
///
/// M3 里这层叠层的取色链（material/switch.dart）是：
///   widget.overlayColor → switchTheme.overlayColor
///   → activeThumbColor.withAlpha(kRadialReactionAlpha) → defaults
/// 链上没有 splashColor / highlightColor / focusColor / hoverColor，
/// 所以全局压掉 splash 系列拦不住它 —— 必须显式配 switchTheme.overlayColor。
/// 不配就会拿 thumb 的选中色（亮蓝）画一圈，表现为点开关闪蓝光。
void main() {
  for (final variant in AppThemeVariant.values) {
    test('${variant.name} 主题的 Switch 叠层在各状态下均为透明', () {
      final overlay = AppTheme.of(variant).switchTheme.overlayColor;

      expect(
        overlay,
        isNotNull,
        reason:
            '${variant.name} 没配 switchTheme.overlayColor，'
            '会回落到 thumb 选中色画叠层（蓝光）',
      );

      // 按下是最显眼的那一下；focus/hover 在桌面端鼠标下也会出现。
      const cases = <String, Set<WidgetState>>{
        '选中+按下': {WidgetState.selected, WidgetState.pressed},
        '未选中+按下': {WidgetState.pressed},
        '选中+悬停': {WidgetState.selected, WidgetState.hovered},
        '选中+获焦': {WidgetState.selected, WidgetState.focused},
      };

      cases.forEach((name, states) {
        final c = overlay!.resolve(states);
        expect(
          c?.a ?? 0.0,
          0.0,
          reason: '${variant.name} 在「$name」时叠层不透明（$c），会闪出色块',
        );
      });
    });
  }

  // 这里刻意不写"点一下开关再断言"的 widget 测试。
  // 试过一版：它读到的仍是主题解析值，和上面三个用例重复，
  // 把 overlayColor 拿掉之后照样通过 —— 是个假保护，不如不留。
  // 叠层有没有真的画出来属于渲染层，widget 测试断言不到。
}
