import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_e621_viewer/core/theme/app_theme.dart';
import 'package:flutter_e621_viewer/core/widgets/frosted_surface.dart';

void main() {
  // 卡片的圆角裁剪边缘只能有一条边：图片自身的边缘。往 ClipRRect 里再铺一层
  // 满幅 Border.all，描边会画在盒子内侧、压在裁剪的抗锯齿边缘上，与图片边缘
  // 挤在同一条像素带里叠加，卡片外缘出现一圈亮边。
  test('卡片裁剪区内不叠满幅描边层', () {
    // 只看 PostCard/骨架卡的外层结构（build 里 GestureDetector 之后那段），
    // 徽标之类不带裁剪的小容器该有描边，不在此列。
    for (final p in const [
      'lib/features/home/widgets/post_card.dart',
      'lib/features/home/widgets/post_card_skeleton.dart',
    ]) {
      final code = File(p)
          .readAsLinesSync()
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      // 满幅描边的特征：Positioned.fill 里套描边，或 ClipRRect 直接包描边盒。
      expect(
        code,
        isNot(matches(RegExp(r'Positioned\.fill[\s\S]{0,200}?Border\.all'))),
        reason: '$p 用 Positioned.fill 铺了描边层，卡片外缘会出现叠加亮边',
      );
      expect(
        code,
        isNot(matches(RegExp(r'ClipRRect[\s\S]{0,200}?Border\.all'))),
        reason: '$p 在 ClipRRect 内画了满幅描边，会与图片边缘叠加出亮边',
      );
    }
  });

  // BackdropFilter 采样的是上一帧已合成的背景，滚动中与当前帧错开一个帧的
  // 位移：顶栏文字和卡片徽标会看起来在画面上滑动，松手才归位。滚动区域内
  // 一律不用它。
  test('滚动区域内不使用 BackdropFilter', () {
    const paths = [
      'lib/features/home/widgets/post_card.dart',
      'lib/core/widgets/frosted_surface.dart',
      'lib/features/home/views/home_screen.dart',
    ];
    for (final p in paths) {
      // 只看实际代码，注释里提这个名字（解释为什么不用）不算。
      final code = File(p)
          .readAsLinesSync()
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(
        code,
        isNot(contains('BackdropFilter')),
        reason: '$p 重新引入了 BackdropFilter，滚动时会错位',
      );
    }
  });

  group('主题质感配置', () {
    test('三套主题都配了卡片阴影与描边，不再是全扁平', () {
      for (final variant in AppThemeVariant.values) {
        final card = AppTheme.of(variant).cardTheme;
        expect(card.elevation, greaterThan(0), reason: variant.name);
        expect(card.shape, isA<RoundedRectangleBorder>(), reason: variant.name);

        // surfaceTint 必须透明：M3 默认会用它给卡片染色，
        // 在藏蓝/纯黑主题下会泛灰紫。
        expect(card.surfaceTintColor, Colors.transparent, reason: variant.name);
      }
    });

    test('卡片描边在各主题下都可见（浅色不能用半透明白）', () {
      for (final variant in AppThemeVariant.values) {
        final shape = AppTheme.of(variant).cardTheme.shape;
        final side = (shape as RoundedRectangleBorder).side;
        expect(side.color.a, greaterThan(0), reason: '${variant.name} 描边不可见');
      }
    });

    test('浅色主题的描边是实色，深色是半透明白', () {
      // 浅色下半透明白等于没有边框，这是玻璃拟态最常见的翻车点。
      expect(AppTheme.surfaceBorder(light: true).a, 1.0);
      expect(AppTheme.surfaceBorder(light: false).a, lessThan(1.0));
    });

    test('浅色阴影比深色克制', () {
      final light = AppTheme.cardShadow(light: true).first;
      final dark = AppTheme.cardShadow(light: false).first;
      expect(light.color.a, lessThan(dark.color.a));
    });

    test('三套主题都配了 chip 与 SnackBar 主题', () {
      for (final variant in AppThemeVariant.values) {
        final theme = AppTheme.of(variant);
        expect(
          theme.chipTheme.shape,
          isA<StadiumBorder>(),
          reason: variant.name,
        );
        expect(
          theme.snackBarTheme.behavior,
          SnackBarBehavior.floating,
          reason: variant.name,
        );
      }
    });

    test('保留原有的无点击特效设定，质感改动没顺手打开水波纹', () {
      for (final variant in AppThemeVariant.values) {
        final theme = AppTheme.of(variant);
        expect(theme.splashColor, Colors.transparent, reason: variant.name);
        expect(theme.highlightColor, Colors.transparent, reason: variant.name);
      }
    });
  });

  group('FrostedSurface', () {
    testWidgets('渲染不崩，且默认取 AppBar 背景色', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.e621Theme,
          home: const Scaffold(
            body: SizedBox(height: 60, child: FrostedSurface()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // 刻意不用 BackdropFilter：滚动时滤镜采样上一帧的背景，顶栏会跟着抖。
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('不透明度足够高，浅色主题下压在图片上仍可读', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SizedBox(height: 60, child: FrostedSurface()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(FrostedSurface),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final color = (box.decoration as BoxDecoration).color!;
      // 没有模糊兜底，压在图片上全靠底色，要求比原先更高。
      expect(color.a, greaterThanOrEqualTo(0.9), reason: '低于 0.9 时文字压在图片上会看不清');
    });
  });
}
