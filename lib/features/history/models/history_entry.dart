import '../../posts/models/e621_post.dart';

class HistoryEntry {
  final E621Post post;
  final DateTime viewedAt;

  const HistoryEntry({required this.post, required this.viewedAt});

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      post: E621Post.fromJson(json['post'] as Map<String, dynamic>),
      viewedAt: DateTime.parse(json['viewedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'post': post.toJson(), 'viewedAt': viewedAt.toIso8601String()};
  }

  HistoryEntry copyWith({DateTime? viewedAt}) {
    return HistoryEntry(post: post, viewedAt: viewedAt ?? this.viewedAt);
  }
}
