import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_e621_viewer/core/theme/app_theme.dart';
import 'package:flutter_e621_viewer/features/home/widgets/search_filter_rows.dart';
import 'package:flutter_e621_viewer/features/posts/providers/post_list_provider.dart';
import 'package:flutter_e621_viewer/features/download/providers/download_list_provider.dart';

void main() {
  group('评级下拉展示文本', () {
    test('空集或全选显示"全部"', () {
      expect(ratingDropdownDisplay({}), '全部');
      expect(
        ratingDropdownDisplay({
          RatingFilter.safe,
          RatingFilter.questionable,
          RatingFilter.explicit,
        }),
        '全部',
      );
    });

    test('单选显示对应文案', () {
      expect(ratingDropdownDisplay({RatingFilter.safe}), '非色图');
      expect(ratingDropdownDisplay({RatingFilter.questionable}), '可能是色图');
      expect(ratingDropdownDisplay({RatingFilter.explicit}), '色图！');
    });

    test('多选但非全选显示"部分"', () {
      expect(
        ratingDropdownDisplay({RatingFilter.safe, RatingFilter.explicit}),
        '部分',
      );
    });
  });

  group('类型下拉展示文本', () {
    test('空集或全选显示"全部"', () {
      expect(mediaTypeDropdownDisplay({}), '全部');
      expect(
        mediaTypeDropdownDisplay({MediaType.image, MediaType.video}),
        '全部',
      );
    });

    test('单选显示对应文案', () {
      expect(mediaTypeDropdownDisplay({MediaType.image}), '图片');
      expect(mediaTypeDropdownDisplay({MediaType.video}), '视频');
    });
  });

  Future<void> pumpNarrow(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(320 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Column(children: [child])),
      ),
    );
    await tester.pump();
  }

  testWidgets('窄屏下浏览筛选栏（排序+评级两个下拉框）不溢出', (tester) async {
    await pumpNarrow(
      tester,
      BrowseFilterRow(
        currentSort: 'order:score',
        onSelectSort: (_) {},
        ratingFilters: {RatingFilter.explicit},
        onToggleRating: (_) {},
        onClearRating: () {},
        variant: AppThemeVariant.e621,
      ),
    );

    expect(find.byType(FilterDropdown), findsNWidgets(2));
    expect(tester.takeException(), isNull, reason: '窄屏下不应溢出');
  });

  testWidgets('窄屏下下载筛选栏（排序+评级+类型三个下拉框）不溢出', (tester) async {
    await pumpNarrow(
      tester,
      DownloadFilterRow(
        currentSort: 'order:score',
        onSelectSort: (_) {},
        ratingFilters: {RatingFilter.safe},
        onToggleRating: (_) {},
        onClearRating: () {},
        mediaTypes: {MediaType.image},
        onToggleMediaType: (_) {},
        onClearMediaType: () {},
        variant: AppThemeVariant.e621,
      ),
    );

    expect(find.byType(FilterDropdown), findsNWidgets(3));
    expect(tester.takeException(), isNull, reason: '窄屏下不应溢出');
  });
}
