// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e621_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_E621Tag _$E621TagFromJson(Map<String, dynamic> json) => _E621Tag(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  postCount: (json['post_count'] as num).toInt(),
  category: (json['category'] as num).toInt(),
  antecedentName: json['antecedent_name'] as String?,
);

Map<String, dynamic> _$E621TagToJson(_E621Tag instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'post_count': instance.postCount,
  'category': instance.category,
  'antecedent_name': instance.antecedentName,
};
