import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/log_service.dart';

/// 类型筛选状态。null = 全部。
class _LogFilter extends Notifier<LogType?> {
  @override
  LogType? build() => null;

  void set(LogType? type) => state = type;
}

final _logFilterProvider = NotifierProvider<_LogFilter, LogType?>(
  _LogFilter.new,
);

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(logProvider);
    final filter = ref.watch(_logFilterProvider);
    final logs = filter == null
        ? all
        : all.where((e) => e.type == filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('系统日志'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: '清空日志',
            onPressed: () => ref.read(logProvider.notifier).clearLogs(),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(all: all),
          const Divider(height: 1),
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Text(
                      all.isEmpty ? '暂无日志记录' : '当前筛选下没有记录',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) => _LogCard(log: logs[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.all});

  final List<LogEntry> all;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_logFilterProvider);

    // 只显示实际出现过的类型，避免一排永远为 0 的空筛选项。
    final present = LogType.values
        .where((t) => all.any((e) => e.type == t))
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: Text('全部 (${all.length})'),
            selected: filter == null,
            onSelected: (_) => ref.read(_logFilterProvider.notifier).set(null),
          ),
          for (final type in present) ...[
            const SizedBox(width: 8),
            FilterChip(
              label: Text(
                '${type.label} (${all.where((e) => e.type == type).length})',
              ),
              selected: filter == type,
              onSelected: (selected) => ref
                  .read(_logFilterProvider.notifier)
                  .set(selected ? type : null),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.log});

  final LogEntry log;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withAlpha(150);

    final (icon, iconColor) = _visual(scheme);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: Icon(icon, color: iconColor),
        title: Row(
          children: [
            Text(
              log.method,
              style: TextStyle(
                color: log.isError ? scheme.error : scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(log: log),
            if (log.duration != null) ...[
              const SizedBox(width: 8),
              Text(
                _formatDuration(log.duration!),
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${log.timestamp.toString().substring(11, 19)} · ${log.url}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: muted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('类型', log.type.label, muted),
                _row('时间', log.timestamp.toString(), muted),
                if (log.duration != null)
                  _row('耗时', _formatDuration(log.duration!), muted),
                if (log.statusCode != null)
                  _row('状态码', '${log.statusCode}', muted),
                if (log.status == LogStatus.pending)
                  _row('状态', '请求中（未返回）', muted),
                const SizedBox(height: 8),
                SelectableText(log.url),
                if (log.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  SelectableText(
                    log.errorMessage!,
                    style: TextStyle(color: scheme.error),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _visual(ColorScheme scheme) {
    if (log.isError) return (Icons.error_outline, scheme.error);
    if (log.status == LogStatus.pending) {
      return (Icons.hourglass_top, scheme.secondary);
    }
    return switch (log.type) {
      LogType.api => (Icons.api, scheme.primary),
      LogType.autocomplete => (Icons.manage_search, scheme.primary),
      LogType.download => (Icons.download, scheme.secondary),
      LogType.image => (Icons.image, scheme.primary),
      LogType.system => (Icons.computer, scheme.onSurface),
    };
  }

  Widget _row(String label, String value, Color muted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 12, color: muted),
      ),
    );
  }

  static String _formatDuration(Duration d) {
    if (d.inMilliseconds < 1000) return '${d.inMilliseconds}ms';
    return '${(d.inMilliseconds / 1000).toStringAsFixed(1)}s';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.log});

  final LogEntry log;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (text, color) = switch (log.status) {
      LogStatus.pending => ('请求中', scheme.secondary),
      LogStatus.success => ('${log.statusCode ?? ''}', scheme.primary),
      LogStatus.failure => (
        log.statusCode != null ? '${log.statusCode}' : '失败',
        scheme.error,
      ),
    };

    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color)),
    );
  }
}
