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
