import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';
import '../../posts/providers/post_list_provider.dart';
import '../../../core/constants/strings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.settingsTitle),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _sectionHeader(context, Strings.sectionGeneral),

          // D3:内容源改为明确的选择对话框。
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text(Strings.contentSource),
            subtitle: Text(
              settings.siteHost == 'e621.net'
                  ? Strings.contentSourceFull
                  : Strings.contentSourceSafe,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSourceDialog(context, ref, settings.siteHost),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.block),
            title: const Text(Strings.enableBlacklist),
            subtitle: const Text(Strings.enableBlacklistSub),
            value: settings.enableBlacklist,
            onChanged: notifier.updateEnableBlacklist,
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text(Strings.editBlacklist),
            subtitle: const Text(Strings.editBlacklistSub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/blacklist'),
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text(Strings.historyTitle),
            subtitle: const Text(Strings.historySub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/history'),
          ),

          const Divider(),
          _sectionHeader(context, Strings.sectionDisplay),

          // D1:补上主题切换入口（此前功能已实现但无 UI）。
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.brightness_6, size: 22),
                const SizedBox(width: 12),
                const Text(Strings.appearance),
                const Spacer(),
                SegmentedButton<ThemeMode>(
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(Strings.appearanceSystem),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(Strings.appearanceLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(Strings.appearanceDark),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) => notifier.updateThemeMode(s.first),
                ),
              ],
            ),
          ),

          // A1:布局模式（瀑布流 / 等高网格）。
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text(Strings.layoutMode),
            trailing: SegmentedButton<LayoutMode>(
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: const [
                ButtonSegment(
                  value: LayoutMode.masonry,
                  label: Text(Strings.layoutMasonry),
                ),
                ButtonSegment(
                  value: LayoutMode.grid,
                  label: Text(Strings.layoutGrid),
                ),
              ],
              selected: {settings.layoutMode},
              onSelectionChanged: (s) => notifier.updateLayoutMode(s.first),
            ),
          ),

          // A3:浏览模式（无限滚动 / 分页）。
          ListTile(
            leading: const Icon(Icons.swap_vert),
            title: const Text(Strings.browseMode),
            trailing: SegmentedButton<BrowseMode>(
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: const [
                ButtonSegment(
                  value: BrowseMode.infinite,
                  label: Text(Strings.browseModeInfinite),
                ),
                ButtonSegment(
                  value: BrowseMode.paged,
                  label: Text(Strings.browseModePaged),
                ),
              ],
              selected: {settings.browseMode},
              onSelectionChanged: (s) => notifier.updateBrowseMode(s.first),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text(Strings.previewGrid),
            subtitle: const Text(Strings.previewGridSub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/preview'),
          ),

          const Divider(),
          _sectionHeader(context, Strings.sectionDev),

          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text(Strings.systemLogs),
            subtitle: const Text(Strings.systemLogsSub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/logs'),
          ),
        ],
      ),
    );
  }

  // A8:分区标题用主题色，不再硬编码 Colors.blue。
  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showSourceDialog(BuildContext context, WidgetRef ref, String current) {
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text(Strings.contentSource),
        children: [
          _sourceOption(
            ctx,
            ref,
            'e621.net',
            Strings.contentSourceFull,
            current,
          ),
          _sourceOption(
            ctx,
            ref,
            'e926.net',
            Strings.contentSourceSafe,
            current,
          ),
        ],
      ),
    );
  }

  Widget _sourceOption(
    BuildContext ctx,
    WidgetRef ref,
    String host,
    String label,
    String current,
  ) {
    final selected = host == current;
    return SimpleDialogOption(
      onPressed: () {
        Navigator.of(ctx).pop();
        if (selected) return;
        ref.read(settingsProvider.notifier).updateSiteHost(host);
        ref.read(postListProvider.notifier).reloadCurrentSearch();
        ScaffoldMessenger.of(ctx)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(Strings.contentSourceSwitched),
              duration: Duration(seconds: 1),
            ),
          );
      },
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (selected)
            Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary),
        ],
      ),
    );
  }
}
