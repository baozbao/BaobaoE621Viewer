import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/pref_keys.dart';
import '../../posts/models/e621_post.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/history_entry.dart';

class HistoryNotifier extends Notifier<List<HistoryEntry>> {
  static const _maxEntries = 200;

  @override
  List<HistoryEntry> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getStringList(PrefKeys.browseHistory) ?? [];
    final result = <HistoryEntry>[];
    for (final s in raw) {
      try {
        result.add(
          HistoryEntry.fromJson(jsonDecode(s) as Map<String, dynamic>),
        );
      } catch (_) {
        // 跳过损坏项
      }
    }
    result.sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
    return result;
  }

  void record(E621Post post) {
    final now = DateTime.now();
    final entries = state.where((e) => e.post.id != post.id).toList();
    state = [
      HistoryEntry(post: post, viewedAt: now),
      ...entries,
    ].take(_maxEntries).toList();
    _persist();
  }

  void remove(int id) {
    state = state.where((e) => e.post.id != id).toList();
    _persist();
  }

  void clear() {
    state = [];
    ref.read(sharedPreferencesProvider).remove(PrefKeys.browseHistory);
  }

  void _persist() {
    final raw = state.map((e) => jsonEncode(e.toJson())).toList();
    ref
        .read(sharedPreferencesProvider)
        .setStringList(PrefKeys.browseHistory, raw);
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryEntry>>(
  () {
    return HistoryNotifier();
  },
);
