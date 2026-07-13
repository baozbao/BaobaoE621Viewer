import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class PreviewSettingsScreen extends ConsumerWidget {
  const PreviewSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('预览与网格设置'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '预览与网格设置',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ListTile(
            title: const Text('预览高度 (Preview Height)'),
            subtitle: Text('设置预览图像相对高度 (50-200)'),
          ),
          Slider(
            value: settings.previewHeight.toDouble(),
            min: 50,
            max: 200,
            divisions: 15,
            label: settings.previewHeight.toString(),
            onChanged: (val) => notifier.updatePreviewHeight(val.toInt()),
          ),
          
          ListTile(
            title: const Text('每行作品数 (Works per Row)'),
            subtitle: Text('设置每行显示的作品数 (2-9)'),
          ),
          Slider(
            value: settings.worksPerRow.toDouble(),
            min: 2,
            max: 9,
            divisions: 7,
            label: settings.worksPerRow.toString(),
            onChanged: (val) => notifier.updateWorksPerRow(val.toInt()),
          ),

          ListTile(
            title: const Text('每页作品数量 (Page Size)'),
            subtitle: Text('每一页有多少篇作品 (20-100)'),
          ),
          Slider(
            value: settings.pageSize.toDouble(),
            min: 20,
            max: 100,
            divisions: 8,
            label: settings.pageSize.toString(),
            onChanged: (val) => notifier.updatePageSize(val.toInt()),
          ),
        ],
      ),
    );
  }
}
