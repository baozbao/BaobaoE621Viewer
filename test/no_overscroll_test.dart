import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_e621_viewer/core/widgets/no_overscroll_behavior.dart';

void main() {
  Widget wrap({required TargetPlatform platform}) {
    return MaterialApp(
      scrollBehavior: const NoOverscrollBehavior(),
      theme: ThemeData(platform: platform),
      home: Scaffold(
        body: ListView.builder(
          itemCount: 50,
          itemExtent: 40,
          itemBuilder: (c, i) => Text('item $i'),
        ),
      ),
    );
  }

  // Android 默认是 stretch，iOS 默认无指示器，其它平台是 glow。
  // 三种默认都要被压掉。
  for (final platform in const [
    TargetPlatform.android,
    TargetPlatform.fuchsia,
    TargetPlatform.iOS,
  ]) {
    testWidgets('$platform 上不出现拉伸/光晕指示器', (tester) async {
      await tester.pumpWidget(wrap(platform: platform));
      await tester.pumpAndSettle();

      // 越界拖拽：往下拉超出顶部边界。
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump();

      expect(
        find.byType(StretchingOverscrollIndicator),
        findsNothing,
        reason: '$platform 仍在拉伸内容',
      );
      expect(
        find.byType(GlowingOverscrollIndicator),
        findsNothing,
        reason: '$platform 仍在画越界光晕',
      );
      await tester.pumpAndSettle();
    });
  }

  testWidgets('默认 MaterialScrollBehavior 在 Android 上确实会拉伸（对照）', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Scaffold(
          body: ListView.builder(
            itemCount: 50,
            itemExtent: 40,
            itemBuilder: (c, i) => Text('item $i'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 若这条失败，说明 Flutter 默认行为变了，上面的测试就失去意义。
    expect(find.byType(StretchingOverscrollIndicator), findsOneWidget);
  });
}
