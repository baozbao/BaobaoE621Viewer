import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/providers/settings_provider.dart';

enum LogType { api, image, system }

class LogEntry {
  final DateTime timestamp;
  final String url;
  final String method;
  final int? statusCode;
  final String? errorMessage;
  final LogType type;

  LogEntry({
    required this.timestamp,
    required this.url,
    this.method = 'GET',
    this.statusCode,
    this.errorMessage,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'url': url,
        'method': method,
        'statusCode': statusCode,
        'errorMessage': errorMessage,
        'type': type.index,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        timestamp: DateTime.parse(json['timestamp']),
        url: json['url'],
        method: json['method'] ?? 'GET',
        statusCode: json['statusCode'],
        errorMessage: json['errorMessage'],
        type: LogType.values[json['type']],
      );
}

class LogNotifier extends Notifier<List<LogEntry>> {
  static const _logKey = 'app_logs';

  @override
  List<LogEntry> build() {
    _loadLogs();
    return [];
  }

  void _loadLogs() {
    final prefs = ref.read(sharedPreferencesProvider);
    final String? logsJson = prefs.getString(_logKey);
    if (logsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(logsJson);
        final logs = decoded.map((e) => LogEntry.fromJson(e)).toList();
        
        // Auto-delete older than 24h
        final now = DateTime.now();
        final filteredLogs = logs.where((log) => now.difference(log.timestamp).inHours < 24).toList();
        
        // Save back if any were deleted
        if (logs.length != filteredLogs.length) {
          prefs.setString(_logKey, jsonEncode(filteredLogs.map((e) => e.toJson()).toList()));
        }
        
        state = filteredLogs;
      } catch (e) {
        state = [];
      }
    } else {
      state = [];
    }
  }

  void addLog(LogEntry log) {
    state = [log, ...state];
    _saveLogs();
  }

  void clearLogs() {
    state = [];
    _saveLogs();
  }

  void _saveLogs() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_logKey, jsonEncode(state.map((e) => e.toJson()).toList()));
  }
}

final logProvider = NotifierProvider<LogNotifier, List<LogEntry>>(() {
  return LogNotifier();
});
