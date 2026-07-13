import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../models/history_entry.dart';
import '../providers/history_provider.dart';
import '../widgets/history_list_item.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.historyTitle),
        actions: [
          if (entries.isNotEmpty)
            IconButton(
              tooltip: Strings.clearHistory,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClear(context, ref),
            ),
        ],
      ),
      body: entries.isEmpty
          ? const EmptyStateView(
              icon: Icons.history,
              title: Strings.historyEmpty,
              hint: Strings.historyEmptyHint,
            )
          : ListView.builder(
              itemCount: entries.length + _dayHeaderCount(entries),
              itemBuilder: (context, index) =>
                  _buildRow(context, entries, index),
            ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    List<HistoryEntry> entries,
    int visualIndex,
  ) {
    var passedHeaders = 0;
    for (var i = 0; i < entries.length; i++) {
      final needsHeader =
          i == 0 || !_isSameDay(entries[i - 1].viewedAt, entries[i].viewedAt);
      if (needsHeader) {
        if (i + passedHeaders == visualIndex) {
          return _DayHeader(label: _dayLabel(entries[i].viewedAt));
        }
        passedHeaders++;
      }
      if (i + passedHeaders == visualIndex) {
        return HistoryListItem(entry: entries[i], index: i);
      }
    }
    return const SizedBox.shrink();
  }

  int _dayHeaderCount(List<HistoryEntry> entries) {
    var count = 0;
    for (var i = 0; i < entries.length; i++) {
      if (i == 0 || !_isSameDay(entries[i - 1].viewedAt, entries[i].viewedAt)) {
        count++;
      }
    }
    return count;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  String _dayLabel(DateTime time) {
    final local = time.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) return '今天';
    if (day == today.subtract(const Duration(days: 1))) return '昨天';
    final month = local.month.toString().padLeft(2, '0');
    final date = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$date';
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Strings.clearHistory),
        content: const Text(Strings.clearHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(Strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(Strings.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(historyProvider.notifier).clear();
    }
  }
}

class _DayHeader extends StatelessWidget {
  final String label;

  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
