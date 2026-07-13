import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('APP SETTINGS'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('通用设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('语言'),
            subtitle: Text('中文 (简体中文)'),
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Change site/host'),
            subtitle: Text(settings.siteHost),
            onTap: () {
              final newHost = settings.siteHost == 'e621.net' ? 'e926.net' : 'e621.net';
              notifier.updateSiteHost(newHost);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.block),
            title: const Text('启用黑名单'),
            subtitle: const Text('过滤包含黑名单标签的作品'),
            value: settings.enableBlacklist,
            onChanged: (val) {
              notifier.updateEnableBlacklist(val);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('编辑黑名单'),
            subtitle: const Text('添加或删除黑名单标签'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/settings/blacklist');
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('显示设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('预览与网格设置'),
            subtitle: const Text('调整首页缩略图高度、列数与加载数量'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/settings/preview');
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('开发者选项', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('系统日志 (System Logs)'),
            subtitle: const Text('查看网络请求和图片加载的报错日志'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/settings/logs');
            },
          ),
        ],
      ),
    );
  }
}
