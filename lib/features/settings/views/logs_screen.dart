import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/log_service.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(logProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('系统日志 (System Logs)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear Logs',
            onPressed: () {
              ref.read(logProvider.notifier).clearLogs();
            },
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(child: Text('暂无日志记录 (No logs)'))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final isError = log.errorMessage != null || (log.statusCode != null && log.statusCode! >= 400);

                Color iconColor;
                IconData icon;
                if (log.type == LogType.api) {
                  icon = Icons.api;
                  iconColor = isError ? Colors.redAccent : Colors.blueAccent;
                } else if (log.type == LogType.image) {
                  icon = Icons.image;
                  iconColor = isError ? Colors.redAccent : Colors.green;
                } else {
                  icon = Icons.computer;
                  iconColor = isError ? Colors.redAccent : Colors.grey;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ExpansionTile(
                    leading: Icon(icon, color: iconColor),
                    title: Text(
                      '${log.method} ${log.statusCode ?? ''}',
                      style: TextStyle(color: isError ? Colors.redAccent : Colors.white),
                    ),
                    subtitle: Text(
                      '${log.timestamp.toString().substring(11, 19)} - ${log.url}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time: ${log.timestamp}', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            SelectableText('URL: ${log.url}'),
                            const SizedBox(height: 8),
                            if (log.statusCode != null) ...[
                              Text('Status: ${log.statusCode}', style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                            ],
                            if (log.errorMessage != null)
                              SelectableText(
                                'Error:\n${log.errorMessage}',
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
