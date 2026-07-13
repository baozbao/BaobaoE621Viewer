// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e621_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_E621PostResponse _$E621PostResponseFromJson(Map<String, dynamic> json) =>
    _E621PostResponse(
      posts:
          (json['posts'] as List<dynamic>?)
              ?.map((e) => E621Post.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$E621PostResponseToJson(_E621PostResponse instance) =>
    <String, dynamic>{'posts': instance.posts};

_E621Post _$E621PostFromJson(Map<String, dynamic> json) => _E621Post(
  id: (json['id'] as num).toInt(),
  createdAt: json['created_at'] as String,
  file: PostFile.fromJson(json['file'] as Map<String, dynamic>),
  preview: PostPreview.fromJson(json['preview'] as Map<String, dynamic>),
  score: PostScore.fromJson(json['score'] as Map<String, dynamic>),
  tags: PostTags.fromJson(json['tags'] as Map<String, dynamic>),
  rating: json['rating'] as String,
  favCount: (json['fav_count'] as num).toInt(),
  description: json['description'] as String? ?? '',
  sources:
      (json['sources'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  approverId: (json['approver_id'] as num?)?.toInt(),
  flags: PostFlags.fromJson(json['flags'] as Map<String, dynamic>),
);

Map<String, dynamic> _$E621PostToJson(_E621Post instance) => <String, dynamic>{
  'id': instance.id,
  'created_at': instance.createdAt,
  'file': instance.file,
  'preview': instance.preview,
  'score': instance.score,
  'tags': instance.tags,
  'rating': instance.rating,
  'fav_count': instance.favCount,
  'description': instance.description,
  'sources': instance.sources,
  'approver_id': instance.approverId,
  'flags': instance.flags,
};

_PostFlags _$PostFlagsFromJson(Map<String, dynamic> json) => _PostFlags(
  pending: json['pending'] as bool,
  flagged: json['flagged'] as bool,
  deleted: json['deleted'] as bool,
);

Map<String, dynamic> _$PostFlagsToJson(_PostFlags instance) =>
    <String, dynamic>{
      'pending': instance.pending,
      'flagged': instance.flagged,
      'deleted': instance.deleted,
    };

_PostFile _$PostFileFromJson(Map<String, dynamic> json) => _PostFile(
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  ext: json['ext'] as String,
  size: (json['size'] as num).toInt(),
  md5: json['md5'] as String,
  url: json['url'] as String?,
);

Map<String, dynamic> _$PostFileToJson(_PostFile instance) => <String, dynamic>{
  'width': instance.width,
  'height': instance.height,
  'ext': instance.ext,
  'size': instance.size,
  'md5': instance.md5,
  'url': instance.url,
};

_PostPreview _$PostPreviewFromJson(Map<String, dynamic> json) => _PostPreview(
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  url: json['url'] as String?,
);

Map<String, dynamic> _$PostPreviewToJson(_PostPreview instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'url': instance.url,
    };

_PostScore _$PostScoreFromJson(Map<String, dynamic> json) => _PostScore(
  up: (json['up'] as num).toInt(),
  down: (json['down'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$PostScoreToJson(_PostScore instance) =>
    <String, dynamic>{
      'up': instance.up,
      'down': instance.down,
      'total': instance.total,
    };

_PostTags _$PostTagsFromJson(Map<String, dynamic> json) => _PostTags(
  general:
      (json['general'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  artist:
      (json['artist'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  copyright:
      (json['copyright'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  character:
      (json['character'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  species:
      (json['species'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  invalid:
      (json['invalid'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  meta:
      (json['meta'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  lore:
      (json['lore'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$PostTagsToJson(_PostTags instance) => <String, dynamic>{
  'general': instance.general,
  'artist': instance.artist,
  'copyright': instance.copyright,
  'character': instance.character,
  'species': instance.species,
  'invalid': instance.invalid,
  'meta': instance.meta,
  'lore': instance.lore,
};
