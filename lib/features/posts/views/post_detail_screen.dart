import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/e621_post.dart';
import '../utils/download_helper.dart';
import '../../../core/services/log_service.dart';
import '../../../core/widgets/native_web_image.dart';
import '../../../core/widgets/media_player.dart';
import '../providers/post_list_provider.dart';
import 'package:go_router/go_router.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final E621Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  bool _isTagsExpanded = false;

  final Set<String> _selectedTags = {};

  void _applyTagsAndPop() {
    if (_selectedTags.isNotEmpty) {
      final currentTags = ref.read(postListProvider).currentTags;
      // Filter out tags that are already in the current search query
      final existingTagsList = currentTags.split(' ');
      final tagsToAdd = _selectedTags.where((t) => !existingTagsList.contains(t)).join(' ');
      
      if (tagsToAdd.isNotEmpty) {
        final newTags = currentTags.trim().isEmpty ? tagsToAdd : '${currentTags.trim()} $tagsToAdd';
        // Delay slightly so the pop animation starts smoothly
        Future.microtask(() {
          ref.read(postListProvider.notifier).search(newTags);
        });
      }
    }
    if (context.canPop()) {
      context.pop();
    }
  }

  void _handleLongPress() {
    if (widget.post.file.url == null) return;
    final filename = '${widget.post.id}.${widget.post.file.ext}';
    DownloadHelper.showDownloadDialog(context, widget.post.file.url!, filename);
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _getStatus() {
    if (widget.post.flags.deleted) return 'Deleted';
    if (widget.post.flags.pending) return 'Pending';
    if (widget.post.flags.flagged) return 'Flagged';
    return 'Active';
  }

  String _getRating() {
    switch (widget.post.rating) {
      case 'e': return 'Explicit';
      case 'q': return 'Questionable';
      case 's': return 'Safe';
      default: return 'Unknown';
    }
  }

  Color _getRatingColor() {
    switch (widget.post.rating) {
      case 'e': return Colors.red;
      case 'q': return Colors.orange;
      case 's': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _applyTagsAndPop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: _applyTagsAndPop,
          ),
          title: const Text('Detail'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              if (post.file.url != null)
                Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: GestureDetector(
                      onLongPress: _handleLongPress,
                      child: AspectRatio(
                        aspectRatio: post.file.width / post.file.height,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (post.file.ext == 'webm' || post.file.ext == 'mp4')
                              MediaPlayer(
                                videoUrl: post.file.url!,
                                aspectRatio: post.file.width / post.file.height,
                              )
                            else if (post.file.ext == 'swf')
                              const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.flash_off, size: 50, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Flash 动画 (.swf) 现已停止支持', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              )
                            else
                              NativeWebImage(
                                imageUrl: post.file.url!,
                                fit: BoxFit.contain,
                              ),
                            
                            if (post.file.ext != 'webm' && post.file.ext != 'mp4' && post.file.ext != 'swf')
                              Positioned.fill(
                                child: Container(color: Colors.transparent),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(
                  height: 300,
                  child: Center(child: Icon(Icons.broken_image, size: 50)),
                ),

              const SizedBox(height: 16),

              // Tags Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text(
                      'Tags',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isTagsExpanded = !_isTagsExpanded;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isTagsExpanded ? 'COLLAPSE' : 'EXPAND'),
                    ),
                  ],
                ),
              ),
              
              if (!_isTagsExpanded)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('Click Expand to view and select tags...', style: TextStyle(color: Colors.grey)),
                ),

              // Expanded Tags List
              if (_isTagsExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTagGroup('ARTIST', post.tags.artist, Colors.amber),
                      _buildTagGroup('COPYRIGHT', post.tags.copyright, Colors.purpleAccent),
                      _buildTagGroup('SPECIES', post.tags.species, Colors.orange),
                      _buildTagGroup('CHARACTERS', post.tags.character, Colors.green),
                      _buildTagGroup('GENERAL', post.tags.general, Colors.white),
                    ],
                  ),
                ),

              const Divider(height: 32),

              // Image Info Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'IMAGE INFO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DefaultTextStyle(
                  style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                  child: Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('ID'),
                          Text('MD5'),
                          Text('Size'),
                          Text('Type'),
                          Text('Status'),
                          SizedBox(height: 8),
                          Text('Rating'),
                          Text('Score'),
                          Text('Faves'),
                          SizedBox(height: 8),
                          Text('Posted'),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${post.id}', style: const TextStyle(color: Colors.white)),
                          Text(post.file.md5, style: const TextStyle(color: Colors.white)),
                          Text('${post.file.width}x${post.file.height} (${_formatSize(post.file.size)})', style: const TextStyle(color: Colors.white)),
                          Text(post.file.ext.toUpperCase(), style: const TextStyle(color: Colors.white)),
                          Text(_getStatus(), style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(_getRating(), style: TextStyle(color: _getRatingColor())),
                          Text('${post.score.total}', style: const TextStyle(color: Colors.green)),
                          Text('${post.favCount}', style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(post.createdAt, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 32),

              // Description and Source
              if (post.description.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'DESCRIPTION',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(post.description, style: const TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 16),
              ],

              if (post.sources.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'SOURCE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
                ...post.sources.map((source) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                      child: Text(source, style: const TextStyle(color: Colors.lightBlueAccent)),
                    )),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagGroup(String title, List<String> tags, Color color) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Made Category Title bigger, bolder, and more distinct
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: tags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag);
                    } else {
                      _selectedTags.add(tag);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.lightBlueAccent.withAlpha(50) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.lightBlueAccent : Colors.white12,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag, 
                    style: TextStyle(
                      color: isSelected ? Colors.lightBlueAccent : color, 
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
