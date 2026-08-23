import 'package:flutter/material.dart';

/// App 支持的三套独立主题（用户手动选择，不跟随系统）。
enum AppThemeVariant { e621, dark, light }

/// 全 App 主题。提供三套可选主题：
/// - [e621Theme]：还原 e621 官网「深藏蓝」配色（默认）。
/// - [darkTheme]：经典纯黑深色。
/// - [lightTheme]：白底 + 藏蓝顶栏的浅色。
class AppTheme {
  /// 根据用户选择的 variant 返回对应主题。
  static ThemeData of(AppThemeVariant variant) {
    switch (variant) {
      case AppThemeVariant.e621:
        return e621Theme;
      case AppThemeVariant.dark:
        return darkTheme;
      case AppThemeVariant.light:
        return lightTheme;
    }
  }

  // ========================================================================
  // E621 主题（默认）：还原官网深藏蓝层次。
  // 背景最深、卡片亮一档、顶栏/底栏用招牌导航蓝，亮蓝只作交互色。
  // ========================================================================
  static const _bg = Color(0xFF0A1929); // 页面背景：深藏蓝
  static const _surface = Color(0xFF152F4A); // 卡片/面板：亮一档
  static const _nav = Color(0xFF012E57); // 顶栏/底栏：招牌藏蓝
  static const _primary = Color(0xFF3B8ED0); // 主色/链接/选中：亮蓝
  static const _accent = Color(0xFFF2A359); // 强调橙
  static const _onSurface = Color(0xFFE3ECF4); // 主文字：近白偏蓝
  static const _onSurfaceMuted = Color(0xFF8FA6BC); // 次要文字：灰蓝
  static const _divider = Color(0xFF1E3A5A); // 分隔线

  static ThemeData get e621Theme {
    const colorScheme = ColorScheme.dark(
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _accent,
      onSecondary: Color(0xFF1A1200),
      surface: _surface,
      onSurface: _onSurface,
      surfaceContainerHighest: _surface,
      outline: _divider,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bg,
      primaryColor: _primary,
      colorScheme: colorScheme,
      canvasColor: _bg,
      dividerColor: _divider,
      hintColor: _onSurfaceMuted,
      appBarTheme: const AppBarTheme(
        backgroundColor: _nav,
        foregroundColor: _onSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _onSurface),
      ),
      navigationBarTheme: _navBarTheme(
        background: _nav,
        selected: _primary,
        unselected: _onSurfaceMuted,
        indicator: _primary.withAlpha(60),
      ),
      cardColor: _surface,
      cardTheme: _cardTheme(
        surface: _surface,
        light: false,
        border: const Color(0x1FFFFFFF),
      ),
      dividerTheme: const DividerThemeData(color: _divider, thickness: 1),
      listTileTheme: const ListTileThemeData(
        iconColor: _onSurfaceMuted,
        textColor: _onSurface,
      ),
      textTheme: const TextTheme().apply(
        bodyColor: _onSurface,
        displayColor: _onSurface,
      ),
      iconTheme: const IconThemeData(color: _onSurface),
      switchTheme: _switchTheme(
        selected: _primary,
        unselected: _onSurfaceMuted,
        track: _divider,
      ),
      chipTheme: _chipTheme(
        surface: _surface,
        onSurface: _onSurface,
        border: _divider,
        selected: _primary,
      ),
      snackBarTheme: _snackBarTheme(
        surface: const Color(0xFF1E3D5C), // 比卡片再亮一档，浮在内容上要能分辨
        onSurface: _onSurface,
      ),
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      useMaterial3: true,
      segmentedButtonTheme: _segmentedButtonTheme,
      pageTransitionsTheme: _transitions,
    );
  }

  // ========================================================================
  // 深色主题：还原经典纯黑配色（改主题前的原版）。
  // ========================================================================
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: const Color(0xFF005282),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF005282),
        secondary: Color(0xFFF2A359),
        surface: Color(0xFF1E1E1E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF002B45),
        elevation: 0,
        centerTitle: true,
      ),
      // 原本没配 cardTheme，卡片走 M3 默认会被 surfaceTint 染成灰紫；
      // 显式给一套纯黑阴影 + 微亮描边，纯黑背景下才有层次。
      cardColor: const Color(0xFF1E1E1E),
      cardTheme: _cardTheme(
        surface: const Color(0xFF1E1E1E),
        light: false,
        border: const Color(0x14FFFFFF),
      ),
      chipTheme: _chipTheme(
        surface: const Color(0xFF1E1E1E),
        onSurface: Colors.white,
        border: const Color(0x1FFFFFFF),
        selected: const Color(0xFF4A90C2), // 比 primary 亮，纯黑上够对比
      ),
      snackBarTheme: _snackBarTheme(
        surface: const Color(0xFF2A2A2A),
        onSurface: Colors.white,
      ),
      switchTheme: _switchTheme(
        selected: const Color(0xFF4A90C2),
        unselected: const Color(0xFF8A8A8A),
        track: const Color(0xFF3A3A3A),
      ),
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      useMaterial3: true,
      segmentedButtonTheme: _segmentedButtonTheme,
      pageTransitionsTheme: _transitions,
    );
  }

  // ========================================================================
  // 浅色主题：白底 + 藏蓝顶栏/底栏 + 深亮蓝交互，保持 e621 识别度。
  // ========================================================================
  // 浅色背景再压深一档：纯白/近白在长时间看图时偏刺眼，这里用更明显的
  // 灰蓝作为页面底，卡片比底再亮一档形成层次。
  static const _lightBg = Color(0xFFCDD6DF); // 页面背景：深一档的柔和灰蓝
  static const _lightSurface = Color(0xFFE9EEF4); // 卡片/面板：比背景亮一档
  static const _lightPrimary = Color(0xFF1E5A8A); // 主色：稍深亮蓝（白底上够对比）
  static const _lightOnSurface = Color(0xFF14212E); // 主文字：深藏蓝
  static const _lightMuted = Color(0xFF52657A); // 次要文字：灰蓝（加深，保证可读）
  static const _lightDivider = Color(0xFFA9B5C3); // 深一档，保证浅色背景下描边/分隔线可见

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: _lightPrimary,
      onPrimary: Colors.white,
      secondary: _accent,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      outline: _lightDivider,
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBg,
      primaryColor: _lightPrimary,
      colorScheme: colorScheme,
      canvasColor: _lightBg,
      dividerColor: _lightDivider,
      hintColor: _lightMuted,
      appBarTheme: const AppBarTheme(
        backgroundColor: _nav,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      navigationBarTheme: _navBarTheme(
        background: _nav,
        selected: Colors.white,
        unselected: Colors.white70,
        indicator: Colors.white.withAlpha(50),
      ),
      cardColor: _lightSurface,
      cardTheme: _cardTheme(
        surface: _lightSurface,
        light: true,
        border: const Color(0xFFE2E8F0),
      ),
      chipTheme: _chipTheme(
        surface: Colors.white,
        onSurface: _lightOnSurface,
        border: _lightDivider,
        selected: _lightPrimary,
      ),
      // 浅色下 SnackBar 用深底反白，跟 M3 默认一致，比浅底浅字醒目。
      snackBarTheme: _snackBarTheme(
        surface: const Color(0xFF1F2C3A),
        onSurface: Colors.white,
      ),
      dividerTheme: const DividerThemeData(color: _lightDivider, thickness: 1),
      listTileTheme: const ListTileThemeData(
        iconColor: _lightMuted,
        textColor: _lightOnSurface,
      ),
      textTheme: const TextTheme().apply(
        bodyColor: _lightOnSurface,
        displayColor: _lightOnSurface,
      ),
      switchTheme: _switchTheme(
        selected: _lightPrimary,
        unselected: _lightMuted,
        track: const Color(0xFFC9D3DE),
      ),
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      useMaterial3: true,
      segmentedButtonTheme: _segmentedButtonTheme,
      pageTransitionsTheme: _transitions,
    );
  }

  // ---- 质感片段 ----

  /// 卡片主题。用 shadowColor + 低 elevation 而不是 M3 默认的 surfaceTint：
  /// 后者在深色主题下会把卡片染成灰紫色，破坏藏蓝配色。
  /// 描边负责近距离的层次，阴影负责远距离的浮起感，两者缺一都显得扁。
  static CardThemeData _cardTheme({
    required Color surface,
    required bool light,
    required Color border,
  }) {
    return CardThemeData(
      color: surface,
      elevation: light ? 1.5 : 2,
      shadowColor: light ? const Color(0x1F000000) : Colors.black,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  }

  /// SnackBar 主题。默认样式是贴底通栏的直角块，浮起的圆角胶囊更轻。
  /// 下载进度和收藏提示都走它，所以值得统一。
  static SnackBarThemeData _snackBarTheme({
    required Color surface,
    required Color onSurface,
  }) {
    return SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: onSurface, fontSize: 13),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: const EdgeInsets.all(12),
    );
  }

  /// Chip 主题。给筛选 chip 一点厚度：胶囊圆角 + 描边 + 选中态用主色淡填充，
  /// 而不是 M3 默认那种整块实色反白（在深色主题下太跳）。
  static ChipThemeData _chipTheme({
    required Color surface,
    required Color onSurface,
    required Color border,
    required Color selected,
  }) {
    return ChipThemeData(
      backgroundColor: surface,
      selectedColor: selected.withAlpha(48),
      checkmarkColor: selected,
      labelStyle: TextStyle(color: onSurface, fontSize: 13),
      secondaryLabelStyle: TextStyle(color: selected, fontSize: 13),
      side: BorderSide(color: border),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      showCheckmark: true,
      elevation: 0,
      pressElevation: 0,
    );
  }

  /// 卡片阴影。图片浏览应用的主角是图，所以阴影只做「垫起来」的暗示：
  /// 大模糊半径 + 低透明度，读起来像环境光而不是一道黑边。
  /// 深色主题下黑影几乎看不见，层次主要靠边框亮一档来体现（见 [surfaceBorder]）。
  static List<BoxShadow> cardShadow({required bool light}) {
    if (light) {
      return const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ];
    }
    return const [
      BoxShadow(color: Color(0x59000000), blurRadius: 14, offset: Offset(0, 5)),
    ];
  }

  /// 顶栏/底栏阴影：比卡片更扩散，用来把浮起的栏与内容分层。
  static List<BoxShadow> barShadow({required bool light}) {
    return [
      BoxShadow(
        color: light ? const Color(0x1F000000) : const Color(0x66000000),
        blurRadius: 16,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// 卡片描边。深色下用比表面亮一档的半透明白，浅色下用实色浅灰 ——
  /// 浅色模式若沿用半透明白会彻底消失，是玻璃拟态最常见的翻车点。
  static Color surfaceBorder({required bool light}) =>
      light ? const Color(0xFFE2E8F0) : const Color(0x1FFFFFFF);

  // ---- 共享片段 ----
  static NavigationBarThemeData _navBarTheme({
    required Color background,
    required Color selected,
    required Color unselected,
    required Color indicator,
  }) {
    return NavigationBarThemeData(
      backgroundColor: background,
      indicatorColor: indicator,
      elevation: 0,
      // 关闭点击叠层（M3 默认取 primary 蓝，不受 splash/highlight 控制）。
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? selected : unselected,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return IconThemeData(color: isSelected ? selected : unselected);
      }),
    );
  }

  /// Switch 主题。关键是 overlayColor 必须显式给透明。
  ///
  /// Switch 按下时 thumb 周围会涨开一圈叠层，它的取色链是（见 Flutter 源码
  /// material/switch.dart 的 effectiveActivePressedOverlayColor）：
  ///   widget.overlayColor → switchTheme.overlayColor
  ///   → activeThumbColor.withAlpha(kRadialReactionAlpha) → defaults
  /// 这条链里没有 splashColor / highlightColor / focusColor / hoverColor
  /// 任何一个（focus/hover 那两条链里才有），所以全局压掉 splash 系列对它无效。
  /// 不配 overlayColor 就会落到第三条，拿 thumb 的选中色（亮蓝）加透明度画出来
  /// —— 表现就是点开关时闪一下蓝光。
  static SwitchThemeData _switchTheme({
    required Color selected,
    required Color unselected,
    required Color track,
  }) {
    return SwitchThemeData(
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return selected;
        return unselected;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return selected.withAlpha(90);
        }
        return track;
      }),
    );
  }

  /// 关闭 SegmentedButton 的点击叠层（M3 默认取 primary 蓝，不受 splash/highlight 控制）。
  static final SegmentedButtonThemeData _segmentedButtonTheme =
      SegmentedButtonThemeData(
        style: ButtonStyle(
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      );

  static const _transitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
    },
  );
}
