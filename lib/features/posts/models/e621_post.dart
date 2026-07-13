import 'package:freezed_annotation/freezed_annotation.dart';

part 'e621_post.freezed.dart';
part 'e621_post.g.dart';

@freezed
abstract class E621PostResponse with _$E621PostResponse {
  const factory E621PostResponse({
    @Default([]) List<E621Post> posts,
  }) = _E621PostResponse;

  factory E621PostResponse.fromJson(Map<String, dynamic> json) => _$E621PostResponseFromJson(json);
}

@freezed
abstract class E621Post with _$E621Post {
  const factory E621Post({
    required int id,
    @JsonKey(name: 'created_at') required String createdAt,
    required PostFile file,
    required PostPreview preview,
    PostSample? sample,
    required PostScore score,
    required PostTags tags,
    required String rating,
    @JsonKey(name: 'fav_count') required int favCount,
    @Default('') String description,
    @Default([]) List<String> sources,
    @JsonKey(name: 'approver_id') int? approverId,
    required PostFlags flags,
  }) = _E621Post;

  factory E621Post.fromJson(Map<String, dynamic> json) => _$E621PostFromJson(json);
}

/// 视频播放地址选择。
/// e621 的原始视频是 VP9 webm，低端设备/模拟器上软解跟不上会黑屏无限缓冲；
/// `sample.alternates` 里有转码好的 H.264 mp4（全设备硬解、体积小），优先用它。
extension E621PostVideo on E621Post {
  String? get bestVideoUrl {
    final alts = sample?.alternates;
    if (alts != null) {
      String? mp4Of(dynamic entry) {
        if (entry is Map && entry['urls'] is List) {
          for (final u in entry['urls'] as List) {
            if (u is String && u.endsWith('.mp4')) return u;
          }
        }
        return null;
      }

      // 720p 清晰度/流畅度平衡最好；其次 480p；再退原始转码。
      for (final key in const ['720p', '480p', 'original']) {
        final u = mp4Of(alts[key]);
        if (u != null) return u;
      }
      // 键名有变动时兜底扫描全部条目。
      for (final entry in alts.values) {
        final u = mp4Of(entry);
        if (u != null) return u;
      }
    }
    return file.url;
  }
}

@freezed
abstract class PostFlags with _$PostFlags {
  const factory PostFlags({
    required bool pending,
    required bool flagged,
    required bool deleted,
  }) = _PostFlags;

  factory PostFlags.fromJson(Map<String, dynamic> json) => _$PostFlagsFromJson(json);
}

@freezed
abstract class PostFile with _$PostFile {
  const factory PostFile({
    required int width,
    required int height,
    required String ext,
    required int size,
    required String md5,
    String? url,
  }) = _PostFile;

  factory PostFile.fromJson(Map<String, dynamic> json) => _$PostFileFromJson(json);
}

@freezed
abstract class PostPreview with _$PostPreview {
  const factory PostPreview({
    required int width,
    required int height,
    String? url,
  }) = _PostPreview;

  factory PostPreview.fromJson(Map<String, dynamic> json) => _$PostPreviewFromJson(json);
}

@freezed
abstract class PostSample with _$PostSample {
  const factory PostSample({
    @Default(false) bool has,
    int? width,
    int? height,
    String? url,
    /// e621 视频转码表：{'720p': {'type':'video','urls':[...]}, ...}。
    /// 结构不稳定，保留原始 Map 由 [E621PostVideo.bestVideoUrl] 解析。
    Map<String, dynamic>? alternates,
  }) = _PostSample;

  factory PostSample.fromJson(Map<String, dynamic> json) => _$PostSampleFromJson(json);
}

@freezed
abstract class PostScore with _$PostScore {
  const factory PostScore({
    required int up,
    required int down,
    required int total,
  }) = _PostScore;

  factory PostScore.fromJson(Map<String, dynamic> json) => _$PostScoreFromJson(json);
}

@freezed
abstract class PostTags with _$PostTags {
  const factory PostTags({
    @Default([]) List<String> general,
    @Default([]) List<String> artist,
    @Default([]) List<String> copyright,
    @Default([]) List<String> character,
    @Default([]) List<String> species,
    @Default([]) List<String> invalid,
    @Default([]) List<String> meta,
    @Default([]) List<String> lore,
  }) = _PostTags;

  factory PostTags.fromJson(Map<String, dynamic> json) => _$PostTagsFromJson(json);
}
