import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../../core/constants/strings.dart';

class BlacklistScreen extends ConsumerStatefulWidget {
  const BlacklistScreen({super.key});

  @override
  ConsumerState<BlacklistScreen> createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends ConsumerState<BlacklistScreen> {
  final TextEditingController _textController = TextEditingController();

  /// e621 官网默认屏蔽集（新用户默认黑名单）。
  static const _preset = [
    'gore',
    'scat',
    'watersports',
    'young -rating:s',
    'loli',
    'shota',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 按空格 / 逗号 / 换行拆分，支持批量粘贴（D4）。
  Iterable<String> _split(String raw) =>
      raw.split(RegExp(r'[\s,，]+')).where((s) => s.trim().isNotEmpty);

  void _showAddDialog() {
    _textController.clear();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(Strings.blacklistAddTitle),
          content: TextField(
            controller: _textController,
            autofocus: true,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: Strings.blacklistAddHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(Strings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final tags = _split(_textController.text).toList();
                if (tags.isNotEmpty) {
                  ref.read(settingsProvider.notifier).addBlacklistTags(tags);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text(Strings.add),
            ),
          ],
        );
      },
    );
  }

  void _importPreset() {
    ref.read(settingsProvider.notifier).addBlacklistTags(_preset);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(Strings.blacklistPresetImported),
          duration: Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(settingsProvider).blacklistedTags;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.blacklistTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: Strings.blacklistImportPreset,
            onPressed: _importPreset,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: Strings.add,
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: tags.isEmpty
          ? const Center(child: Text(Strings.blacklistEmpty))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => ref
                        .read(settingsProvider.notifier)
                        .removeBlacklistTag(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
