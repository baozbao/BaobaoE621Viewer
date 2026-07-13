import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

class AppSettings {
  final String siteHost; // e621.net or e926.net
  final ThemeMode themeMode;
  final int previewHeight;
  final int worksPerRow;
  final int pageSize;
  final bool enableBlacklist;
  final List<String> blacklistedTags;

  const AppSettings({
    this.siteHost = 'e621.net',
    this.themeMode = ThemeMode.dark,
    this.previewHeight = 150,
    this.worksPerRow = 4,
    this.pageSize = 40,
    this.enableBlacklist = true,
    this.blacklistedTags = const [],
  });

  AppSettings copyWith({
    String? siteHost,
    ThemeMode? themeMode,
    int? previewHeight,
    int? worksPerRow,
    int? pageSize,
    bool? enableBlacklist,
    List<String>? blacklistedTags,
  }) {
    return AppSettings(
      siteHost: siteHost ?? this.siteHost,
      themeMode: themeMode ?? this.themeMode,
      previewHeight: previewHeight ?? this.previewHeight,
      worksPerRow: worksPerRow ?? this.worksPerRow,
      pageSize: pageSize ?? this.pageSize,
      enableBlacklist: enableBlacklist ?? this.enableBlacklist,
      blacklistedTags: blacklistedTags ?? this.blacklistedTags,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    
    return AppSettings(
      siteHost: prefs.getString('siteHost') ?? 'e621.net',
      themeMode: ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.dark.index],
      previewHeight: prefs.getInt('previewHeight') ?? 150,
      worksPerRow: prefs.getInt('worksPerRow') ?? 4,
      pageSize: prefs.getInt('pageSize') ?? 40,
      enableBlacklist: prefs.getBool('enableBlacklist') ?? true,
      blacklistedTags: prefs.getStringList('blacklistedTags') ?? [],
    );
  }

  void updateSiteHost(String host) {
    state = state.copyWith(siteHost: host);
    ref.read(sharedPreferencesProvider).setString('siteHost', host);
  }



  void updateThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    ref.read(sharedPreferencesProvider).setInt('themeMode', mode.index);
  }

  void updatePreviewHeight(int height) {
    state = state.copyWith(previewHeight: height);
    ref.read(sharedPreferencesProvider).setInt('previewHeight', height);
  }

  void updateWorksPerRow(int count) {
    state = state.copyWith(worksPerRow: count);
    ref.read(sharedPreferencesProvider).setInt('worksPerRow', count);
  }

  void updatePageSize(int size) {
    state = state.copyWith(pageSize: size);
    ref.read(sharedPreferencesProvider).setInt('pageSize', size);
  }
  
  void updateEnableBlacklist(bool val) {
    state = state.copyWith(enableBlacklist: val);
    ref.read(sharedPreferencesProvider).setBool('enableBlacklist', val);
  }

  void addBlacklistTag(String tag) {
    String cleanTag = tag.trim();
    while (cleanTag.startsWith('-')) {
      cleanTag = cleanTag.substring(1).trim();
    }
    if (cleanTag.isEmpty || state.blacklistedTags.contains(cleanTag)) return;

    final newList = List<String>.from(state.blacklistedTags)..add(cleanTag);
    state = state.copyWith(blacklistedTags: newList);
    ref.read(sharedPreferencesProvider).setStringList('blacklistedTags', newList);
  }

  void removeBlacklistTag(String tag) {
    final newList = List<String>.from(state.blacklistedTags)..remove(tag);
    state = state.copyWith(blacklistedTags: newList);
    ref.read(sharedPreferencesProvider).setStringList('blacklistedTags', newList);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});
