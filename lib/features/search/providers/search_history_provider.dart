import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/settings_provider.dart';

class SearchHistoryNotifier extends Notifier<List<String>> {
  static const _key = 'search_history';

  @override
  List<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getStringList(_key) ?? [];
  }

  void addSearch(String query) {
    if (query.trim().isEmpty) return;
    
    final current = List<String>.from(state);
    current.remove(query);
    current.insert(0, query);
    
    // keep max 20 items
    if (current.length > 20) {
      current.removeLast();
    }
    
    state = current;
    ref.read(sharedPreferencesProvider).setStringList(_key, current);
  }

  void removeSearch(String query) {
    final current = List<String>.from(state);
    current.remove(query);
    state = current;
    ref.read(sharedPreferencesProvider).setStringList(_key, current);
  }

  void clearHistory() {
    state = [];
    ref.read(sharedPreferencesProvider).remove(_key);
  }
}

final searchHistoryProvider = NotifierProvider<SearchHistoryNotifier, List<String>>(() {
  return SearchHistoryNotifier();
});
