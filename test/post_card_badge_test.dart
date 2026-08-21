import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_e621_viewer/features/home/widgets/post_card.dart';
import 'package:flutter_e621_viewer/features/posts/models/e621_post.dart';
import 'package:flutter_e621_viewer/features/settings/providers/settings_provider.dart';

/// 瀑布流（fixedHeight: false）下底部信息栏必须落在卡片可见区内。
///
/// Stack 用 StackFit.loose 时尺寸只由非定位子节点决定（即图片本身），
/// Positioned(bottom: 0) 贴的是 Stack 底边 —— 一旦 Stack 高度与图片实际
/// 渲染高度不一致，徽章就会跑到裁剪区外看不见。
void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  E621Post makePost({
    required int previewW,
    required int previewH,
    required int fileW,
    required int fileH,
    String ext = 'webm',
    String rating = 's',
    int favCount = 12,
    int score = 10,
  }) {
    return E621Post(
      id: 1,
      createdAt: '2024-01-01T00:00:00.000Z',
      file: PostFile(
        width: fileW,
        height: fileH,
        ext: ext,
        size: 1000,
        md5: 'abc',
        url: 'https://example.com/f.$ext',
      ),
      preview: PostPreview(
        width: previewW,
        height: previewH,
        url: 'https://example.com/p.jpg',
      ),
      score: PostScore(up: score, down: 0, total: score),
      rating: rating,
      favCount: favCount,
      tags: const PostTags(),
      flags: const PostFlags(pending: false, flagged: false, deleted: false),
    );
  }

  Future<void> pumpCard(
    WidgetTester tester,
    E621Post post, {
    double width = 180,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: PostCard(post: post, fixedHeight: false),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('preview 尺寸缺失时，底部信息栏仍在卡片可见区内', (tester) async {
    // preview 尺寸为 0 → 代码回退到 file 尺寸算宽高比。
    await pumpCard(
      tester,
      makePost(previewW: 0, previewH: 0, fileW: 1920, fileH: 1080),
    );

    final cardRect = tester.getRect(find.byType(PostCard));
    final badge = find.text('▶ WEBM');
    expect(badge, findsOneWidget, reason: '类型徽标应当渲染');

    final badgeRect = tester.getRect(badge);
    expect(
      badgeRect.bottom,
      lessThanOrEqualTo(cardRect.bottom + 0.5),
      reason: '徽标底边超出卡片底边，会被 ClipRRect 裁掉',
    );
    expect(
      badgeRect.top,
      greaterThanOrEqualTo(cardRect.top - 0.5),
      reason: '徽标顶边跑到卡片上方',
    );
  });

  // 媒体类型徽标是关键信息，任何列宽下都必须能看到（全版或短版），
  // 且必须是全字号 —— 不允许缩成看不清的一条。
  // 手机每行 4 张时列宽只有 80px 上下，这是最常见的实际场景。
  for (final width in const [200.0, 160.0, 120.0, 95.0, 80.0, 60.0]) {
    testWidgets('列宽 $width 下媒体类型徽标仍可见且字号未被压缩', (tester) async {
      await pumpCard(
        tester,
        makePost(previewW: 150, previewH: 150, fileW: 1920, fileH: 1080),
        width: width,
      );

      // 全版 '▶ WEBM' 或短版 '▶'，两者都算显示了类型。
      final full = find.text('▶ WEBM');
      final short = find.text('▶');
      final badge = full.evaluate().isNotEmpty ? full : short;

      expect(badge.evaluate(), isNotEmpty, reason: '列宽 $width 下媒体类型徽标完全消失了');
      debugPrint(
        'width=$width -> ${full.evaluate().isNotEmpty ? "全版 ▶ WEBM" : "短版 ▶"}'
        ', 收藏数=${find.byIcon(Icons.favorite).evaluate().isNotEmpty}'
        ', 得分=${find.byIcon(Icons.arrow_upward).evaluate().isNotEmpty}',
      );

      final h = tester.getRect(badge).height;
      expect(
        h,
        greaterThanOrEqualTo(10),
        reason: '列宽 $width 时徽标高度只有 $h，字号被压缩到看不清',
      );

      // 手机每行 4 张（列宽 80~95px）是最常见场景，那里必须还看得到收藏数。
      if (width >= 80) {
        expect(
          find.byIcon(Icons.favorite),
          findsOneWidget,
          reason: '列宽 $width 下收藏数消失了，常用布局信息不该这么早让位',
        );
      }
    });
  }

  // 真机复现路径：SizedBox 包一层会给出确定宽度，而真实瀑布流走的是
  // SliverMasonryGrid，卡片宽度由 crossAxisCount 分配、Stack 用 StackFit.loose。
  // 上面那批用例测不到这条路径，这里按真实结构搭。
  Future<void> pumpMasonry(
    WidgetTester tester, {
    required int perRow,
    required E621Post post,
    double viewportWidth = 411,
  }) async {
    tester.view.physicalSize = Size(viewportWidth * 3, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: perRow,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childCount: 6,
                    itemBuilder: (context, index) =>
                        PostCard(post: post, index: index, fixedHeight: false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  // 每行 2~6 张，配合 5 位数计数 —— 这是徽标"有时不见"的真实条件组合。
  for (final perRow in const [2, 3, 4, 5, 6]) {
    testWidgets('瀑布流每行 $perRow 张且计数为 5 位数时底部栏不溢出', (tester) async {
      await pumpMasonry(
        tester,
        perRow: perRow,
        post: makePost(
          previewW: 850,
          previewH: 1100,
          fileW: 1700,
          fileH: 2200,
          favCount: 56300,
          score: 31200,
        ),
      );

      expect(
        tester.takeException(),
        isNull,
        reason: '瀑布流每行 $perRow 张时底部信息栏溢出了',
      );

      // 只断言"不溢出"是不够的：徽章整个消失时同样不溢出，用例会假通过。
      // 这里要求计数确实渲染出来了。
      expect(
        find.text('56.3k'),
        findsWidgets,
        reason: '瀑布流每行 $perRow 张时收藏数没有渲染',
      );
    });
  }

  // 扁宽图（横幅、条漫头图）在窄列里高度只有 20~40px，而信息栏固定 32px。
  // 框比容器高时 Positioned(bottom:0) 会把顶部顶出 Stack，被 ClipRRect 裁掉，
  // 表现就是"部分卡片没有得分框"。之前的用例全用 0.77 竖图，从没触发过。
  for (final ratio in const [1.5, 2.5, 4.0, 6.0]) {
    testWidgets('宽高比 $ratio 的扁图在 4 列下仍显示得分框', (tester) async {
      final w = (ratio * 1000).round();
      await pumpMasonry(
        tester,
        perRow: 4,
        post: makePost(
          previewW: w,
          previewH: 1000,
          fileW: w * 2,
          fileH: 2000,
          ext: 'jpg',
          favCount: 56300,
          score: 4200,
        ),
      );

      expect(tester.takeException(), isNull, reason: '宽高比 $ratio 时溢出');

      // find.byIcon 找得到不代表看得见：ClipRRect 只裁绘制，widget 仍在树里。
      // 必须比几何位置 —— 得分框顶边不能超出卡片顶边，否则就是被裁掉了。
      final card = tester.getRect(find.byType(PostCard).first);
      final bar = tester.getRect(find.byIcon(Icons.favorite).first);
      debugPrint(
        'DBG ratio=$ratio card=${card.top.toStringAsFixed(1)}~'
        '${card.bottom.toStringAsFixed(1)} (h=${card.height.toStringAsFixed(1)}) '
        'bar=${bar.top.toStringAsFixed(1)}~${bar.bottom.toStringAsFixed(1)}',
      );
      expect(
        bar.top,
        greaterThanOrEqualTo(card.top - 0.5),
        reason:
            '宽高比 $ratio 的得分框顶出卡片外被裁掉了'
            '（卡片 ${card.top}~${card.bottom}，框 ${bar.top}~${bar.bottom}）',
      );
      expect(
        bar.bottom,
        lessThanOrEqualTo(card.bottom + 0.5),
        reason: '宽高比 $ratio 的得分框底部超出卡片',
      );
    });
  }

  // 截图里那张狮子卡就是这种：jpg 没有类型徽标，一旦计数也被降级掉，
  // 整条底栏退成 SizedBox.shrink() 直接消失。静态图必须保住计数。
  for (final perRow in const [2, 3, 4, 5, 6]) {
    testWidgets('瀑布流每行 $perRow 张时静态图仍显示收藏数', (tester) async {
      await pumpMasonry(
        tester,
        perRow: perRow,
        post: makePost(
          previewW: 850,
          previewH: 1100,
          fileW: 1700,
          fileH: 2200,
          ext: 'jpg',
          favCount: 56300,
          score: 4200,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        find.byIcon(Icons.favorite),
        findsWidgets,
        reason: '每行 $perRow 张时静态图的底栏整块消失了',
      );
    });
  }

  // 回归：真机日志显示 w=100 的卡片上 Row 溢出 12px（'▶ WEBM' + '❤56.3k'）。
  // 溢出后 Spacer 被压成 0、右侧内容被 ClipRRect 裁掉，表现就是计数看不见，
  // 外加 debug 模式那条黄黑条纹。大数字必须参与测试 —— '56.3k' 比 '12' 宽一倍。
  for (final width in const [
    220.0,
    160.0,
    130.0,
    115.0,
    100.0,
    90.0,
    75.0,
    60.0,
    45.0,
  ]) {
    testWidgets('列宽 $width 且计数为 5 位数时底部栏不溢出', (tester) async {
      await pumpCard(
        tester,
        makePost(
          previewW: 150,
          previewH: 150,
          fileW: 1920,
          fileH: 1080,
          favCount: 56300,
          score: 31200,
        ),
        width: width,
      );

      // 布局期的溢出会以 FlutterError 形式记录，这里直接断言一条都没有。
      expect(tester.takeException(), isNull, reason: '列宽 $width 下底部信息栏溢出了');
    });
  }

  testWidgets('评级色条避开圆角，不与裁剪弧线相交', (tester) async {
    // 色条通高（top/bottom = 0）时会在四个圆角处被 ClipRRect 的弧线切过，
    // Explicit 帖子（红）看起来就是卡片外缘一道红亮边。
    await pumpCard(
      tester,
      makePost(
        previewW: 150,
        previewH: 200,
        fileW: 1500,
        fileH: 2000,
        rating: 'e',
      ),
    );

    final cardRect = tester.getRect(find.byType(PostCard));
    // 色条是 PostCard 里唯一宽度恰好 2px 的 SizedBox。
    final bar = find.byWidgetPredicate(
      (w) => w is SizedBox && w.width == 2 && w.height == null,
    );
    expect(bar, findsOneWidget, reason: '找不到评级色条');

    final barRect = tester.getRect(bar);
    const radius = 10.0;
    expect(
      barRect.top - cardRect.top,
      greaterThanOrEqualTo(radius),
      reason: '色条顶端伸进了圆角区域，会被裁出一段亮弧',
    );
    expect(
      cardRect.bottom - barRect.bottom,
      greaterThanOrEqualTo(radius),
      reason: '色条底端伸进了圆角区域，会被裁出一段亮弧',
    );
  });

  testWidgets('preview 与 file 宽高比不一致时，底部信息栏仍在可见区内', (tester) async {
    // preview 是 150 宽的缩略图，比例与原图不同。
    await pumpCard(
      tester,
      makePost(previewW: 150, previewH: 150, fileW: 1920, fileH: 1080),
    );

    final cardRect = tester.getRect(find.byType(PostCard));
    final badgeRect = tester.getRect(find.text('▶ WEBM'));
    expect(
      badgeRect.bottom,
      lessThanOrEqualTo(cardRect.bottom + 0.5),
      reason: '徽标底边超出卡片底边，会被裁掉',
    );
  });
}
