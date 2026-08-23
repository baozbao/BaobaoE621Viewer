import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/e621_post.dart';
import '../providers/post_list_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/constants/strings.dart';

/// 详情页标签区：按组分色展示，画师组置顶（B3）。
/// 点击 = 以此搜索；长按 = 菜单（加入黑名单 / 追加搜索 / 复制）。
class TagGroupSection extends ConsumerWidget {
  final PostTags tags;

  const TagGroupSection({super.key, required this.tags});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 分组色随主题走：浅色主题下用加深版本，否则浅彩色在白底上对比不足、看不清。
    final light = Theme.of(context).brightness == Brightness.light;
    final artist = light ? const Color(0xFFB56A00) : const Color(0xFFFFB85C);
    final character = light ? const Color(0xFF7B3FBF) : const Color(0xFFC792EA);
    final species = light ? const Color(0xFF2B5FB0) : const Color(0xFF82AAFF);
    final copyright = light ? const Color(0xFF1E8A57) : const Color(0xFF7EE2A8);
    final meta = light ? const Color(0xFF5C6570) : Colors.grey;

    // 画师置顶，其后按 e621 惯例排序。
    final groups = <_TagGroup>[
      _TagGroup(Strings.tagArtist, tags.artist, artist, Icons.brush_outlined),
      _TagGroup(
        Strings.tagCharacter,
        tags.character,
        character,
        Icons.person_outline,
      ),
      _TagGroup(Strings.tagSpecies, tags.species, species, Icons.pets_outlined),
      _TagGroup(
        Strings.tagCopyright,
        tags.copyright,
        copyright,
        Icons.copyright_outlined,
      ),
      _TagGroup(
        Strings.tagGeneral,
        tags.general,
        Theme.of(context).colorScheme.onSurface,
        Icons.sell_outlined,
      ),
      _TagGroup(Strings.tagMeta, tags.meta, meta, Icons.info_outline),
    ].where((g) => g.tags.isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groups.map((g) => _buildGroup(context, ref, g)).toList(),
      ),
    );
  }

  Widget _buildGroup(BuildContext context, WidgetRef ref, _TagGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(group.icon, size: 16, color: group.color),
              const SizedBox(width: 6),
              Text(
                group.title,
                style: TextStyle(
                  color: group.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.tags
                .map((tag) => _TagChip(tag: tag, color: group.color))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TagGroup {
  final String title;
  final List<String> tags;
  final Color color;
  final IconData icon;
  const _TagGroup(this.title, this.tags, this.color, this.icon);
}

class _TagChip extends ConsumerWidget {
  final String tag;
  final Color color;

  const _TagChip({required this.tag, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 暂选状态：与下拉框一致的主题高亮（彩色淡底 + 加粗，不打勾）。
    final pending = ref.watch(postListProvider).pendingTags;
    final selected = pending.contains(tag);
    final light = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      onTap: () {
        // 点击 = 暂选/取消暂选，不返回主页、不立即搜索（可连续多选）。
        ref.read(postListProvider.notifier).togglePendingTag(tag);
      },
      onLongPress: () => _showMenu(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(selected ? 200 : 120)),
          color: selected
              ? color.withAlpha(light ? 46 : 58)
              : Colors.transparent,
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                tag,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text(Strings.selectTag),
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(postListProvider.notifier).togglePendingTag(tag);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text(Strings.addToBlacklist),
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(settingsProvider.notifier).addBlacklistTag(tag);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$tag ${Strings.addToBlacklist}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text(Strings.copy),
              onTap: () {
                Navigator.of(ctx).pop();
                Clipboard.setData(ClipboardData(text: tag));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text(Strings.copied)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
