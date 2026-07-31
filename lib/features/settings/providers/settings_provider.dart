import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/pref_keys.dart';
import '../../../core/theme/app_theme.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

/// 首页网格布局模式（A1）。
enum LayoutMode { masonry, grid }

/// 浏览模式（A3）。
enum BrowseMode { infinite, paged }

class AppSettings {
  final String siteHost; // e621.net or e926.net
  final AppThemeVariant themeVariant;
  final int previewHeight;
  final int worksPerRow;
  final int pageSize;
  final bool enableBlacklist;
  final List<String> blacklistedTags;
  final LayoutMode layoutMode;
  final BrowseMode browseMode;
  final bool showPreviewType;
  final bool showPreviewUpvote;
  final bool showPreviewScore;

  const AppSettings({
    this.siteHost = 'e621.net',
    this.themeVariant = AppThemeVariant.e621,
    this.previewHeight = 150,
    this.worksPerRow = 4,
    this.pageSize = 40,
    this.enableBlacklist = true,
    this.blacklistedTags = const [],
    this.layoutMode = LayoutMode.masonry,
    this.browseMode = BrowseMode.paged,
    this.showPreviewType = true,
    this.showPreviewUpvote = true,
    this.showPreviewScore = true,
  });

  AppSettings copyWith({
    String? siteHost,
    AppThemeVariant? themeVariant,
    int? previewHeight,
    int? worksPerRow,
    int? pageSize,
    bool? enableBlacklist,
    List<String>? blacklistedTags,
    LayoutMode? layoutMode,
    BrowseMode? browseMode,
    bool? showPreviewType,
    bool? showPreviewUpvote,
    bool? showPreviewScore,
  }) {
    return AppSettings(
      siteHost: siteHost ?? this.siteHost,
      themeVariant: themeVariant ?? this.themeVariant,
      previewHeight: previewHeight ?? this.previewHeight,
      worksPerRow: worksPerRow ?? this.worksPerRow,
      pageSize: pageSize ?? this.pageSize,
      enableBlacklist: enableBlacklist ?? this.enableBlacklist,
      blacklistedTags: blacklistedTags ?? this.blacklistedTags,
      layoutMode: layoutMode ?? this.layoutMode,
      browseMode: browseMode ?? this.browseMode,
      showPreviewType: showPreviewType ?? this.showPreviewType,
      showPreviewUpvote: showPreviewUpvote ?? this.showPreviewUpvote,
      showPreviewScore: showPreviewScore ?? this.showPreviewScore,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);

    return AppSettings(
      siteHost: prefs.getString(PrefKeys.siteHost) ?? 'e621.net',
      themeVariant: AppThemeVariant.values[prefs.getInt(PrefKeys.themeVariant) ?? AppThemeVariant.e621.index],
      previewHeight: prefs.getInt(PrefKeys.previewHeight) ?? 150,
      worksPerRow: prefs.getInt(PrefKeys.worksPerRow) ?? 4,
      pageSize: prefs.getInt(PrefKeys.pageSize) ?? 40,
      enableBlacklist: prefs.getBool(PrefKeys.enableBlacklist) ?? true,
      blacklistedTags: prefs.getStringList(PrefKeys.blacklistedTags) ?? [],
      layoutMode: LayoutMode.values[prefs.getInt(PrefKeys.layoutMode) ?? LayoutMode.masonry.index],
      browseMode: BrowseMode.values[prefs.getInt(PrefKeys.browseMode) ?? BrowseMode.paged.index],
      showPreviewType: prefs.getBool(PrefKeys.showPreviewType) ?? true,
      showPreviewUpvote: prefs.getBool(PrefKeys.showPreviewUpvote) ?? true,
      showPreviewScore: prefs.getBool(PrefKeys.showPreviewScore) ?? true,
    );
  }

  SharedPreferences get _p => ref.read(sharedPreferencesProvider);

  void updateSiteHost(String host) {
    state = state.copyWith(siteHost: host);
    _p.setString(PrefKeys.siteHost, host);
  }

  void updateThemeVariant(AppThemeVariant variant) {
    state = state.copyWith(themeVariant: variant);
    _p.setInt(PrefKeys.themeVariant, variant.index);
  }

  void updatePreviewHeight(int height) {
    state = state.copyWith(previewHeight: height);
    _p.setInt(PrefKeys.previewHeight, height);
  }

  void updateWorksPerRow(int count) {
    state = state.copyWith(worksPerRow: count);
    _p.setInt(PrefKeys.worksPerRow, count);
  }

  void updatePageSize(int size) {
    state = state.copyWith(pageSize: size);
    _p.setInt(PrefKeys.pageSize, size);
  }

  void updateEnableBlacklist(bool val) {
    state = state.copyWith(enableBlacklist: val);
    _p.setBool(PrefKeys.enableBlacklist, val);
  }

  void updateLayoutMode(LayoutMode mode) {
    state = state.copyWith(layoutMode: mode);
    _p.setInt(PrefKeys.layoutMode, mode.index);
  }

  void updateBrowseMode(BrowseMode mode) {
    state = state.copyWith(browseMode: mode);
    _p.setInt(PrefKeys.browseMode, mode.index);
  }

  void updateShowPreviewType(bool value) {
    state = state.copyWith(showPreviewType: value);
    _p.setBool(PrefKeys.showPreviewType, value);
  }

  void updateShowPreviewUpvote(bool value) {
    state = state.copyWith(showPreviewUpvote: value);
    _p.setBool(PrefKeys.showPreviewUpvote, value);
  }

  void updateShowPreviewScore(bool value) {
    state = state.copyWith(showPreviewScore: value);
    _p.setBool(PrefKeys.showPreviewScore, value);
  }

  void addBlacklistTag(String tag) {
    String cleanTag = tag.trim();
    while (cleanTag.startsWith('-')) {
      cleanTag = cleanTag.substring(1).trim();
    }
    if (cleanTag.isEmpty || state.blacklistedTags.contains(cleanTag)) return;

    final newList = List<String>.from(state.blacklistedTags)..add(cleanTag);
    state = state.copyWith(blacklistedTags: newList);
    _p.setStringList(PrefKeys.blacklistedTags, newList);
  }

  /// 批量添加（D4:支持空格/逗号分隔粘贴）。
  void addBlacklistTags(Iterable<String> tags) {
    final newList = List<String>.from(state.blacklistedTags);
    for (final raw in tags) {
      String cleanTag = raw.trim();
      while (cleanTag.startsWith('-')) {
        cleanTag = cleanTag.substring(1).trim();
      }
      if (cleanTag.isEmpty || newList.contains(cleanTag)) continue;
      newList.add(cleanTag);
    }
    state = state.copyWith(blacklistedTags: newList);
    _p.setStringList(PrefKeys.blacklistedTags, newList);
  }

  void removeBlacklistTag(String tag) {
    final newList = List<String>.from(state.blacklistedTags)..remove(tag);
    state = state.copyWith(blacklistedTags: newList);
    _p.setStringList(PrefKeys.blacklistedTags, newList);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});
