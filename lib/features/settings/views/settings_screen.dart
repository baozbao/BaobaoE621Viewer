import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';
import '../../posts/providers/post_list_provider.dart';
import '../../search/providers/search_history_provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';

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

          // 清空搜索历史放这里而不是搜索下拉层里（PRD-028）：下拉层里它会紧挨
          // 单条删除的 x，误触一次就抹掉 30 条且无法撤销。
          Consumer(
            builder: (context, ref, _) {
              final count = ref.watch(searchHistoryProvider).length;
              return ListTile(
                leading: const Icon(Icons.manage_search),
                title: const Text(Strings.clearSearchHistory),
                subtitle: Text('$count 条记录'),
                enabled: count > 0,
                onTap: count > 0
                    ? () => _confirmClearSearchHistory(context, ref)
                    : null,
              );
            },
          ),

          const Divider(),
          _sectionHeader(context, Strings.sectionDisplay),

          // 主题切换：三套独立主题（E621 / 深色 / 浅色），默认 E621。
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.brightness_6, size: 22),
                    SizedBox(width: 12),
                    Text(Strings.appearance),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<AppThemeVariant>(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: const [
                      ButtonSegment(
                        value: AppThemeVariant.e621,
                        label: Text(Strings.appearanceE621),
                      ),
                      ButtonSegment(
                        value: AppThemeVariant.dark,
                        label: Text(Strings.appearanceDark),
                      ),
                      ButtonSegment(
                        value: AppThemeVariant.light,
                        label: Text(Strings.appearanceLight),
                      ),
                    ],
                    selected: {settings.themeVariant},
                    onSelectionChanged: (s) =>
                        notifier.updateThemeVariant(s.first),
                  ),
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

          ListTile(
            leading: const Icon(Icons.label_outline),
            title: const Text(Strings.previewOverlay),
            subtitle: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: const [
                _ColoredSettingLabel(text: Strings.previewType),
                _ColoredSettingLabel(
                  text: Strings.previewUpvote,
                  color: Color(0xFF35D08A),
                ),
                _ColoredSettingLabel(
                  text: Strings.previewScore,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
          SwitchListTile(
            dense: true,
            secondary: const Icon(Icons.movie_filter_outlined),
            title: const _ColoredSettingLabel(text: Strings.previewType),
            value: settings.showPreviewType,
            onChanged: notifier.updateShowPreviewType,
          ),
          SwitchListTile(
            dense: true,
            secondary: const Icon(Icons.arrow_upward),
            title: const _ColoredSettingLabel(
              text: Strings.previewUpvote,
              color: Color(0xFF35D08A),
            ),
            value: settings.showPreviewUpvote,
            onChanged: notifier.updateShowPreviewUpvote,
          ),
          SwitchListTile(
            dense: true,
            secondary: const Icon(Icons.favorite_border),
            title: const _ColoredSettingLabel(
              text: Strings.previewScore,
              color: Colors.redAccent,
            ),
            value: settings.showPreviewScore,
            onChanged: notifier.updateShowPreviewScore,
          ),

          const Divider(),
          _sectionHeader(context, Strings.sectionDev),

          SwitchListTile(
            dense: true,
            secondary: const Icon(Icons.bug_report),
            title: const Text('卡片诊断模式'),
            subtitle: const Text('开发者选项：卡片显示调试信息'),
            value: settings.showPostCardDiagnostic,
            onChanged: notifier.updateShowPostCardDiagnostic,
          ),

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

  /// 清空搜索历史需二次确认：一次点击抹掉全部记录且无法撤销。
  void _confirmClearSearchHistory(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Strings.clearSearchHistory),
        content: const Text(Strings.clearSearchHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(searchHistoryProvider.notifier).clearHistory();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(Strings.searchHistoryCleared),
                    duration: Duration(seconds: 2),
                  ),
                );
            },
            child: const Text(Strings.confirm),
          ),
        ],
      ),
    );
  }

  // A8:分区标题用主题色，不再硬编码 Colors.blue。
  Widget _sectionHeader(BuildContext context, String text) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          // 一道主色短条：比单纯加粗文字更能把长列表切分成段落。
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: primary,
            ),
          ),
        ],
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

class _ColoredSettingLabel extends StatelessWidget {
  final String text;

  /// null = 跟随主题文字色（浅色主题下白色会隐形，故类型标签传 null）。
  final Color? color;

  const _ColoredSettingLabel({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
