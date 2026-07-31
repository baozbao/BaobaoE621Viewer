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
      cardTheme: const CardThemeData(color: _surface, elevation: 0),
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
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return _onSurfaceMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primary.withAlpha(90);
          }
          return _divider;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surface,
        labelStyle: const TextStyle(color: _onSurface),
        side: const BorderSide(color: _divider),
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
  static const _lightBg = Color(0xFFE4E9EF); // 页面背景：柔和灰蓝（避免纯白刺眼）
  static const _lightSurface = Color(0xFFF4F7FA); // 卡片/面板：微灰白，非纯白
  static const _lightPrimary = Color(0xFF1E5A8A); // 主色：稍深亮蓝（白底上够对比）
  static const _lightOnSurface = Color(0xFF14212E); // 主文字：深藏蓝
  static const _lightMuted = Color(0xFF52657A); // 次要文字：灰蓝（加深，保证可读）
  static const _lightDivider = Color(0xFFCBD5DF);

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
      cardTheme: const CardThemeData(color: _lightSurface, elevation: 0),
      dividerTheme: const DividerThemeData(color: _lightDivider, thickness: 1),
      listTileTheme: const ListTileThemeData(
        iconColor: _lightMuted,
        textColor: _lightOnSurface,
      ),
      textTheme: const TextTheme().apply(
        bodyColor: _lightOnSurface,
        displayColor: _lightOnSurface,
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
