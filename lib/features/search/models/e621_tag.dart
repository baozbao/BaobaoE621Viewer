import 'package:freezed_annotation/freezed_annotation.dart';

part 'e621_tag.freezed.dart';
part 'e621_tag.g.dart';

@freezed
abstract class E621Tag with _$E621Tag {
  const factory E621Tag({
    required int id,
    required String name,
    @JsonKey(name: 'post_count') required int postCount,
    required int category,
    @JsonKey(name: 'antecedent_name') String? antecedentName,
  }) = _E621Tag;

  factory E621Tag.fromJson(Map<String, dynamic> json) =>
      _$E621TagFromJson(json);
}
