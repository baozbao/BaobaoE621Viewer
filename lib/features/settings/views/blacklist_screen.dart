import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class BlacklistScreen extends ConsumerStatefulWidget {
  const BlacklistScreen({super.key});

  @override
  ConsumerState<BlacklistScreen> createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends ConsumerState<BlacklistScreen> {
  bool _isEditing = false;
  final TextEditingController _textController = TextEditingController();

  void _showAddDialog() {
    _textController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加黑名单标签'),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: '输入标签（如: futa）',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  ref.read(settingsProvider.notifier).addBlacklistTag(_textController.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final tags = settings.blacklistedTags;

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑黑名单'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '添加标签',
            onPressed: _showAddDialog,
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Text(
              _isEditing ? '完成' : '管理',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: tags.isEmpty
          ? const Center(child: Text('暂无黑名单标签'))
          : ListView.builder(
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return ListTile(
                  title: Text(tag),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            ref.read(settingsProvider.notifier).removeBlacklistTag(tag);
                          },
                        )
                      : null,
                );
              },
            ),
    );
  }
}
