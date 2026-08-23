import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/strings.dart';
import '../providers/settings_provider.dart';

/// 下载页网格设置：独立于浏览页的三项参数 + 一键与浏览一致。
class DownloadGridSettingsScreen extends ConsumerWidget {
  const DownloadGridSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.downloadGridSettings)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              Strings.downloadGridSettings,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Center(
            child: FilledButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text(Strings.syncWithBrowse),
              onPressed: () {
                notifier.syncDownloadGridWithBrowse();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(Strings.syncedWithBrowse),
                      duration: Duration(seconds: 2),
                    ),
                  );
              },
            ),
          ),
          ListTile(
            title: const Text('预览高度 (Preview Height)'),
            subtitle: Text('当前 ${settings.downloadPreviewHeight} (50-200)'),
          ),
          Slider(
            value: settings.downloadPreviewHeight.toDouble(),
            min: 50,
            max: 200,
            divisions: 15,
            label: settings.downloadPreviewHeight.toString(),
            onChanged: (val) =>
                notifier.updateDownloadPreviewHeight(val.toInt()),
          ),
          ListTile(
            title: const Text('每行作品数 (Works per Row)'),
            subtitle: Text('当前 ${settings.downloadWorksPerRow} (2-9)'),
          ),
          Slider(
            value: settings.downloadWorksPerRow.toDouble(),
            min: 2,
            max: 9,
            divisions: 7,
            label: settings.downloadWorksPerRow.toString(),
            onChanged: (val) => notifier.updateDownloadWorksPerRow(val.toInt()),
          ),
          ListTile(
            title: const Text('每页作品数量 (Page Size)'),
            subtitle: Text('当前 ${settings.downloadPageSize} (20-100)'),
          ),
          Slider(
            value: settings.downloadPageSize.toDouble(),
            min: 20,
            max: 100,
            divisions: 8,
            label: settings.downloadPageSize.toString(),
            onChanged: (val) => notifier.updateDownloadPageSize(val.toInt()),
          ),
        ],
      ),
    );
  }
}
