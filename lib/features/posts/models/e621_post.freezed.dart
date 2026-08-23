// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'e621_post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$E621PostResponse {

 List<E621Post> get posts;
/// Create a copy of E621PostResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$E621PostResponseCopyWith<E621PostResponse> get copyWith => _$E621PostResponseCopyWithImpl<E621PostResponse>(this as E621PostResponse, _$identity);

  /// Serializes this E621PostResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is E621PostResponse&&const DeepCollectionEquality().equals(other.posts, posts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(posts));

@override
String toString() {
  return 'E621PostResponse(posts: $posts)';
}


}

/// @nodoc
abstract mixin class $E621PostResponseCopyWith<$Res>  {
  factory $E621PostResponseCopyWith(E621PostResponse value, $Res Function(E621PostResponse) _then) = _$E621PostResponseCopyWithImpl;
@useResult
$Res call({
 List<E621Post> posts
});




}
/// @nodoc
class _$E621PostResponseCopyWithImpl<$Res>
    implements $E621PostResponseCopyWith<$Res> {
  _$E621PostResponseCopyWithImpl(this._self, this._then);

  final E621PostResponse _self;
  final $Res Function(E621PostResponse) _then;

/// Create a copy of E621PostResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? posts = null,}) {
  return _then(_self.copyWith(
posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<E621Post>,
  ));
}

}


/// Adds pattern-matching-related methods to [E621PostResponse].
extension E621PostResponsePatterns on E621PostResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _E621PostResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _E621PostResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _E621PostResponse value)  $default,){
final _that = this;
switch (_that) {
case _E621PostResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _E621PostResponse value)?  $default,){
final _that = this;
switch (_that) {
case _E621PostResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<E621Post> posts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _E621PostResponse() when $default != null:
return $default(_that.posts);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<E621Post> posts)  $default,) {final _that = this;
switch (_that) {
case _E621PostResponse():
return $default(_that.posts);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<E621Post> posts)?  $default,) {final _that = this;
switch (_that) {
case _E621PostResponse() when $default != null:
return $default(_that.posts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _E621PostResponse implements E621PostResponse {
  const _E621PostResponse({final  List<E621Post> posts = const []}): _posts = posts;
  factory _E621PostResponse.fromJson(Map<String, dynamic> json) => _$E621PostResponseFromJson(json);

 final  List<E621Post> _posts;
@override@JsonKey() List<E621Post> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}


/// Create a copy of E621PostResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$E621PostResponseCopyWith<_E621PostResponse> get copyWith => __$E621PostResponseCopyWithImpl<_E621PostResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$E621PostResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _E621PostResponse&&const DeepCollectionEquality().equals(other._posts, _posts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_posts));

@override
String toString() {
  return 'E621PostResponse(posts: $posts)';
}


}

/// @nodoc
abstract mixin class _$E621PostResponseCopyWith<$Res> implements $E621PostResponseCopyWith<$Res> {
  factory _$E621PostResponseCopyWith(_E621PostResponse value, $Res Function(_E621PostResponse) _then) = __$E621PostResponseCopyWithImpl;
@override @useResult
$Res call({
 List<E621Post> posts
});




}
/// @nodoc
class __$E621PostResponseCopyWithImpl<$Res>
    implements _$E621PostResponseCopyWith<$Res> {
  __$E621PostResponseCopyWithImpl(this._self, this._then);

  final _E621PostResponse _self;
  final $Res Function(_E621PostResponse) _then;

/// Create a copy of E621PostResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? posts = null,}) {
  return _then(_E621PostResponse(
posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<E621Post>,
  ));
}


}


/// @nodoc
mixin _$E621Post {

 int get id;@JsonKey(name: 'created_at') String get createdAt; PostFile get file; PostPreview get preview; PostSample? get sample; PostScore get score; PostTags get tags; String get rating;@JsonKey(name: 'fav_count') int get favCount; String get description; List<String> get sources;@JsonKey(name: 'approver_id') int? get approverId; PostFlags get flags;
/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$E621PostCopyWith<E621Post> get copyWith => _$E621PostCopyWithImpl<E621Post>(this as E621Post, _$identity);

  /// Serializes this E621Post to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is E621Post&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.file, file) || other.file == file)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.sample, sample) || other.sample == sample)&&(identical(other.score, score) || other.score == score)&&(identical(other.tags, tags) || other.tags == tags)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.favCount, favCount) || other.favCount == favCount)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.sources, sources)&&(identical(other.approverId, approverId) || other.approverId == approverId)&&(identical(other.flags, flags) || other.flags == flags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,file,preview,sample,score,tags,rating,favCount,description,const DeepCollectionEquality().hash(sources),approverId,flags);

@override
String toString() {
  return 'E621Post(id: $id, createdAt: $createdAt, file: $file, preview: $preview, sample: $sample, score: $score, tags: $tags, rating: $rating, favCount: $favCount, description: $description, sources: $sources, approverId: $approverId, flags: $flags)';
}


}

/// @nodoc
abstract mixin class $E621PostCopyWith<$Res>  {
  factory $E621PostCopyWith(E621Post value, $Res Function(E621Post) _then) = _$E621PostCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'created_at') String createdAt, PostFile file, PostPreview preview, PostSample? sample, PostScore score, PostTags tags, String rating,@JsonKey(name: 'fav_count') int favCount, String description, List<String> sources,@JsonKey(name: 'approver_id') int? approverId, PostFlags flags
});


$PostFileCopyWith<$Res> get file;$PostPreviewCopyWith<$Res> get preview;$PostSampleCopyWith<$Res>? get sample;$PostScoreCopyWith<$Res> get score;$PostTagsCopyWith<$Res> get tags;$PostFlagsCopyWith<$Res> get flags;

}
/// @nodoc
class _$E621PostCopyWithImpl<$Res>
    implements $E621PostCopyWith<$Res> {
  _$E621PostCopyWithImpl(this._self, this._then);

  final E621Post _self;
  final $Res Function(E621Post) _then;

/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? file = null,Object? preview = null,Object? sample = freezed,Object? score = null,Object? tags = null,Object? rating = null,Object? favCount = null,Object? description = null,Object? sources = null,Object? approverId = freezed,Object? flags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as PostFile,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as PostPreview,sample: freezed == sample ? _self.sample : sample // ignore: cast_nullable_to_non_nullable
as PostSample?,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as PostScore,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as PostTags,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as String,favCount: null == favCount ? _self.favCount : favCount // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<String>,approverId: freezed == approverId ? _self.approverId : approverId // ignore: cast_nullable_to_non_nullable
as int?,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as PostFlags,
  ));
}
/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostFileCopyWith<$Res> get file {
  
  return $PostFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostPreviewCopyWith<$Res> get preview {
  
  return $PostPreviewCopyWith<$Res>(_self.preview, (value) {
    return _then(_self.copyWith(preview: value));
  });
}/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostSampleCopyWith<$Res>? get sample {
    if (_self.sample == null) {
    return null;
  }

  return $PostSampleCopyWith<$Res>(_self.sample!, (value) {
    return _then(_self.copyWith(sample: value));
  });
}/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostScoreCopyWith<$Res> get score {
  
  return $PostScoreCopyWith<$Res>(_self.score, (value) {
    return _then(_self.copyWith(score: value));
  });
}/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostTagsCopyWith<$Res> get tags {
  
  return $PostTagsCopyWith<$Res>(_self.tags, (value) {
    return _then(_self.copyWith(tags: value));
  });
}/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostFlagsCopyWith<$Res> get flags {
  
  return $PostFlagsCopyWith<$Res>(_self.flags, (value) {
    return _then(_self.copyWith(flags: value));
  });
}
}


/// Adds pattern-matching-related methods to [E621Post].
extension E621PostPatterns on E621Post {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _E621Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _E621Post() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _E621Post value)  $default,){
final _that = this;
switch (_that) {
case _E621Post():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _E621Post value)?  $default,){
final _that = this;
switch (_that) {
case _E621Post() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'created_at')  String createdAt,  PostFile file,  PostPreview preview,  PostSample? sample,  PostScore score,  PostTags tags,  String rating, @JsonKey(name: 'fav_count')  int favCount,  String description,  List<String> sources, @JsonKey(name: 'approver_id')  int? approverId,  PostFlags flags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _E621Post() when $default != null:
return $default(_that.id,_that.createdAt,_that.file,_that.preview,_that.sample,_that.score,_that.tags,_that.rating,_that.favCount,_that.description,_that.sources,_that.approverId,_that.flags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'created_at')  String createdAt,  PostFile file,  PostPreview preview,  PostSample? sample,  PostScore score,  PostTags tags,  String rating, @JsonKey(name: 'fav_count')  int favCount,  String description,  List<String> sources, @JsonKey(name: 'approver_id')  int? approverId,  PostFlags flags)  $default,) {final _that = this;
switch (_that) {
case _E621Post():
return $default(_that.id,_that.createdAt,_that.file,_that.preview,_that.sample,_that.score,_that.tags,_that.rating,_that.favCount,_that.description,_that.sources,_that.approverId,_that.flags);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'created_at')  String createdAt,  PostFile file,  PostPreview preview,  PostSample? sample,  PostScore score,  PostTags tags,  String rating, @JsonKey(name: 'fav_count')  int favCount,  String description,  List<String> sources, @JsonKey(name: 'approver_id')  int? approverId,  PostFlags flags)?  $default,) {final _that = this;
switch (_that) {
case _E621Post() when $default != null:
return $default(_that.id,_that.createdAt,_that.file,_that.preview,_that.sample,_that.score,_that.tags,_that.rating,_that.favCount,_that.description,_that.sources,_that.approverId,_that.flags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _E621Post implements E621Post {
  const _E621Post({required this.id, @JsonKey(name: 'created_at') required this.createdAt, required this.file, required this.preview, this.sample, required this.score, required this.tags, required this.rating, @JsonKey(name: 'fav_count') required this.favCount, this.description = '', final  List<String> sources = const [], @JsonKey(name: 'approver_id') this.approverId, required this.flags}): _sources = sources;
  factory _E621Post.fromJson(Map<String, dynamic> json) => _$E621PostFromJson(json);

@override final  int id;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override final  PostFile file;
@override final  PostPreview preview;
@override final  PostSample? sample;
@override final  PostScore score;
@override final  PostTags tags;
@override final  String rating;
@override@JsonKey(name: 'fav_count') final  int favCount;
@override@JsonKey() final  String description;
 final  List<String> _sources;
@override@JsonKey() List<String> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}

@override@JsonKey(name: 'approver_id') final  int? approverId;
@override final  PostFlags flags;

/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$E621PostCopyWith<_E621Post> get copyWith => __$E621PostCopyWithImpl<_E621Post>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$E621PostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _E621Post&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.file, file) || other.file == file)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.sample, sample) || other.sample == sample)&&(identical(other.score, score) || other.score == score)&&(identical(other.tags, tags) || other.tags == tags)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.favCount, favCount) || other.favCount == favCount)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._sources, _sources)&&(identical(other.approverId, approverId) || other.approverId == approverId)&&(identical(other.flags, flags) || other.flags == flags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,file,preview,sample,score,tags,rating,favCount,description,const DeepCollectionEquality().hash(_sources),approverId,flags);

@override
String toString() {
  return 'E621Post(id: $id, createdAt: $createdAt, file: $file, preview: $preview, sample: $sample, score: $score, tags: $tags, rating: $rating, favCount: $favCount, description: $description, sources: $sources, approverId: $approverId, flags: $flags)';
}


}

/// @nodoc
abstract mixin class _$E621PostCopyWith<$Res> implements $E621PostCopyWith<$Res> {
  factory _$E621PostCopyWith(_E621Post value, $Res Function(_E621Post) _then) = __$E621PostCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'created_at') String createdAt, PostFile file, PostPreview preview, PostSample? sample, PostScore score, PostTags tags, String rating,@JsonKey(name: 'fav_count') int favCount, String description, List<String> sources,@JsonKey(name: 'approver_id') int? approverId, PostFlags flags
});


@override $PostFileCopyWith<$Res> get file;@override $PostPreviewCopyWith<$Res> get preview;@override $PostSampleCopyWith<$Res>? get sample;@override $PostScoreCopyWith<$Res> get score;@override $PostTagsCopyWith<$Res> get tags;@override $PostFlagsCopyWith<$Res> get flags;

}
/// @nodoc
class __$E621PostCopyWithImpl<$Res>
    implements _$E621PostCopyWith<$Res> {
  __$E621PostCopyWithImpl(this._self, this._then);

  final _E621Post _self;
  final $Res Function(_E621Post) _then;

/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? file = null,Object? preview = null,Object? sample = freezed,Object? score = null,Object? tags = null,Object? rating = null,Object? favCount = null,Object? description = null,Object? sources = null,Object? approverId = freezed,Object? flags = null,}) {
  return _then(_E621Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as PostFile,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as PostPreview,sample: freezed == sample ? _self.sample : sample // ignore: cast_nullable_to_non_nullable
as PostSample?,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as PostScore,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as PostTags,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as String,favCount: null == favCount ? _self.favCount : favCount // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<String>,approverId: freezed == approverId ? _self.approverId : approverId // ignore: cast_nullable_to_non_nullable
as int?,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as PostFlags,
  ));
}

/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostFileCopyWith<$Res> get file {
  
  return $PostFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostPreviewCopyWith<$Res> get preview {
  
  return $PostPreviewCopyWith<$Res>(_self.preview, (value) {
    return _then(_self.copyWith(preview: value));
  });
}/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostSampleCopyWith<$Res>? get sample {
    if (_self.sample == null) {
    return null;
  }

  return $PostSampleCopyWith<$Res>(_self.sample!, (value) {
    return _then(_self.copyWith(sample: value));
  });
}/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostScoreCopyWith<$Res> get score {
  
  return $PostScoreCopyWith<$Res>(_self.score, (value) {
    return _then(_self.copyWith(score: value));
  });
}/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostTagsCopyWith<$Res> get tags {
  
  return $PostTagsCopyWith<$Res>(_self.tags, (value) {
    return _then(_self.copyWith(tags: value));
  });
}/// Create a copy of E621Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostFlagsCopyWith<$Res> get flags {
  
  return $PostFlagsCopyWith<$Res>(_self.flags, (value) {
    return _then(_self.copyWith(flags: value));
  });
}
}


/// @nodoc
mixin _$PostFlags {

 bool get pending; bool get flagged; bool get deleted;
/// Create a copy of PostFlags
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostFlagsCopyWith<PostFlags> get copyWith => _$PostFlagsCopyWithImpl<PostFlags>(this as PostFlags, _$identity);

  /// Serializes this PostFlags to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostFlags&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.flagged, flagged) || other.flagged == flagged)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pending,flagged,deleted);

@override
String toString() {
  return 'PostFlags(pending: $pending, flagged: $flagged, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class $PostFlagsCopyWith<$Res>  {
  factory $PostFlagsCopyWith(PostFlags value, $Res Function(PostFlags) _then) = _$PostFlagsCopyWithImpl;
@useResult
$Res call({
 bool pending, bool flagged, bool deleted
});




}
/// @nodoc
class _$PostFlagsCopyWithImpl<$Res>
    implements $PostFlagsCopyWith<$Res> {
  _$PostFlagsCopyWithImpl(this._self, this._then);

  final PostFlags _self;
  final $Res Function(PostFlags) _then;

/// Create a copy of PostFlags
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pending = null,Object? flagged = null,Object? deleted = null,}) {
  return _then(_self.copyWith(
pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,flagged: null == flagged ? _self.flagged : flagged // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PostFlags].
extension PostFlagsPatterns on PostFlags {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostFlags value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostFlags() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostFlags value)  $default,){
final _that = this;
switch (_that) {
case _PostFlags():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostFlags value)?  $default,){
final _that = this;
switch (_that) {
case _PostFlags() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool pending,  bool flagged,  bool deleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostFlags() when $default != null:
return $default(_that.pending,_that.flagged,_that.deleted);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool pending,  bool flagged,  bool deleted)  $default,) {final _that = this;
switch (_that) {
case _PostFlags():
return $default(_that.pending,_that.flagged,_that.deleted);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool pending,  bool flagged,  bool deleted)?  $default,) {final _that = this;
switch (_that) {
case _PostFlags() when $default != null:
return $default(_that.pending,_that.flagged,_that.deleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostFlags implements PostFlags {
  const _PostFlags({required this.pending, required this.flagged, required this.deleted});
  factory _PostFlags.fromJson(Map<String, dynamic> json) => _$PostFlagsFromJson(json);

@override final  bool pending;
@override final  bool flagged;
@override final  bool deleted;

/// Create a copy of PostFlags
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostFlagsCopyWith<_PostFlags> get copyWith => __$PostFlagsCopyWithImpl<_PostFlags>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostFlagsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostFlags&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.flagged, flagged) || other.flagged == flagged)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pending,flagged,deleted);

@override
String toString() {
  return 'PostFlags(pending: $pending, flagged: $flagged, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class _$PostFlagsCopyWith<$Res> implements $PostFlagsCopyWith<$Res> {
  factory _$PostFlagsCopyWith(_PostFlags value, $Res Function(_PostFlags) _then) = __$PostFlagsCopyWithImpl;
@override @useResult
$Res call({
 bool pending, bool flagged, bool deleted
});




}
/// @nodoc
class __$PostFlagsCopyWithImpl<$Res>
    implements _$PostFlagsCopyWith<$Res> {
  __$PostFlagsCopyWithImpl(this._self, this._then);

  final _PostFlags _self;
  final $Res Function(_PostFlags) _then;

/// Create a copy of PostFlags
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pending = null,Object? flagged = null,Object? deleted = null,}) {
  return _then(_PostFlags(
pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,flagged: null == flagged ? _self.flagged : flagged // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PostFile {

 int get width; int get height; String get ext; int get size; String get md5; String? get url;
/// Create a copy of PostFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostFileCopyWith<PostFile> get copyWith => _$PostFileCopyWithImpl<PostFile>(this as PostFile, _$identity);

  /// Serializes this PostFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostFile&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.ext, ext) || other.ext == ext)&&(identical(other.size, size) || other.size == size)&&(identical(other.md5, md5) || other.md5 == md5)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height,ext,size,md5,url);

@override
String toString() {
  return 'PostFile(width: $width, height: $height, ext: $ext, size: $size, md5: $md5, url: $url)';
}


}

/// @nodoc
abstract mixin class $PostFileCopyWith<$Res>  {
  factory $PostFileCopyWith(PostFile value, $Res Function(PostFile) _then) = _$PostFileCopyWithImpl;
@useResult
$Res call({
 int width, int height, String ext, int size, String md5, String? url
});




}
/// @nodoc
class _$PostFileCopyWithImpl<$Res>
    implements $PostFileCopyWith<$Res> {
  _$PostFileCopyWithImpl(this._self, this._then);

  final PostFile _self;
  final $Res Function(PostFile) _then;

/// Create a copy of PostFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = null,Object? height = null,Object? ext = null,Object? size = null,Object? md5 = null,Object? url = freezed,}) {
  return _then(_self.copyWith(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,ext: null == ext ? _self.ext : ext // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,md5: null == md5 ? _self.md5 : md5 // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostFile].
extension PostFilePatterns on PostFile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostFile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostFile value)  $default,){
final _that = this;
switch (_that) {
case _PostFile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostFile value)?  $default,){
final _that = this;
switch (_that) {
case _PostFile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int width,  int height,  String ext,  int size,  String md5,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostFile() when $default != null:
return $default(_that.width,_that.height,_that.ext,_that.size,_that.md5,_that.url);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int width,  int height,  String ext,  int size,  String md5,  String? url)  $default,) {final _that = this;
switch (_that) {
case _PostFile():
return $default(_that.width,_that.height,_that.ext,_that.size,_that.md5,_that.url);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int width,  int height,  String ext,  int size,  String md5,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _PostFile() when $default != null:
return $default(_that.width,_that.height,_that.ext,_that.size,_that.md5,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostFile implements PostFile {
  const _PostFile({required this.width, required this.height, required this.ext, required this.size, required this.md5, this.url});
  factory _PostFile.fromJson(Map<String, dynamic> json) => _$PostFileFromJson(json);

@override final  int width;
@override final  int height;
@override final  String ext;
@override final  int size;
@override final  String md5;
@override final  String? url;

/// Create a copy of PostFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostFileCopyWith<_PostFile> get copyWith => __$PostFileCopyWithImpl<_PostFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostFile&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.ext, ext) || other.ext == ext)&&(identical(other.size, size) || other.size == size)&&(identical(other.md5, md5) || other.md5 == md5)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height,ext,size,md5,url);

@override
String toString() {
  return 'PostFile(width: $width, height: $height, ext: $ext, size: $size, md5: $md5, url: $url)';
}


}

/// @nodoc
abstract mixin class _$PostFileCopyWith<$Res> implements $PostFileCopyWith<$Res> {
  factory _$PostFileCopyWith(_PostFile value, $Res Function(_PostFile) _then) = __$PostFileCopyWithImpl;
@override @useResult
$Res call({
 int width, int height, String ext, int size, String md5, String? url
});




}
/// @nodoc
class __$PostFileCopyWithImpl<$Res>
    implements _$PostFileCopyWith<$Res> {
  __$PostFileCopyWithImpl(this._self, this._then);

  final _PostFile _self;
  final $Res Function(_PostFile) _then;

/// Create a copy of PostFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? ext = null,Object? size = null,Object? md5 = null,Object? url = freezed,}) {
  return _then(_PostFile(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,ext: null == ext ? _self.ext : ext // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,md5: null == md5 ? _self.md5 : md5 // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PostPreview {

 int get width; int get height; String? get url;
/// Create a copy of PostPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostPreviewCopyWith<PostPreview> get copyWith => _$PostPreviewCopyWithImpl<PostPreview>(this as PostPreview, _$identity);

  /// Serializes this PostPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostPreview&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height,url);

@override
String toString() {
  return 'PostPreview(width: $width, height: $height, url: $url)';
}


}

/// @nodoc
abstract mixin class $PostPreviewCopyWith<$Res>  {
  factory $PostPreviewCopyWith(PostPreview value, $Res Function(PostPreview) _then) = _$PostPreviewCopyWithImpl;
@useResult
$Res call({
 int width, int height, String? url
});




}
/// @nodoc
class _$PostPreviewCopyWithImpl<$Res>
    implements $PostPreviewCopyWith<$Res> {
  _$PostPreviewCopyWithImpl(this._self, this._then);

  final PostPreview _self;
  final $Res Function(PostPreview) _then;

/// Create a copy of PostPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = null,Object? height = null,Object? url = freezed,}) {
  return _then(_self.copyWith(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostPreview].
extension PostPreviewPatterns on PostPreview {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostPreview() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostPreview value)  $default,){
final _that = this;
switch (_that) {
case _PostPreview():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostPreview value)?  $default,){
final _that = this;
switch (_that) {
case _PostPreview() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int width,  int height,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostPreview() when $default != null:
return $default(_that.width,_that.height,_that.url);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int width,  int height,  String? url)  $default,) {final _that = this;
switch (_that) {
case _PostPreview():
return $default(_that.width,_that.height,_that.url);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int width,  int height,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _PostPreview() when $default != null:
return $default(_that.width,_that.height,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostPreview implements PostPreview {
  const _PostPreview({required this.width, required this.height, this.url});
  factory _PostPreview.fromJson(Map<String, dynamic> json) => _$PostPreviewFromJson(json);

@override final  int width;
@override final  int height;
@override final  String? url;

/// Create a copy of PostPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostPreviewCopyWith<_PostPreview> get copyWith => __$PostPreviewCopyWithImpl<_PostPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostPreview&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height,url);

@override
String toString() {
  return 'PostPreview(width: $width, height: $height, url: $url)';
}


}

/// @nodoc
abstract mixin class _$PostPreviewCopyWith<$Res> implements $PostPreviewCopyWith<$Res> {
  factory _$PostPreviewCopyWith(_PostPreview value, $Res Function(_PostPreview) _then) = __$PostPreviewCopyWithImpl;
@override @useResult
$Res call({
 int width, int height, String? url
});




}
/// @nodoc
class __$PostPreviewCopyWithImpl<$Res>
    implements _$PostPreviewCopyWith<$Res> {
  __$PostPreviewCopyWithImpl(this._self, this._then);

  final _PostPreview _self;
  final $Res Function(_PostPreview) _then;

/// Create a copy of PostPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? url = freezed,}) {
  return _then(_PostPreview(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PostSample {

 bool get has; int? get width; int? get height; String? get url;/// e621 视频转码表：{'720p': {'type':'video','urls':[...]}, ...}。
/// 结构不稳定，保留原始 Map 由 [E621PostVideo.bestVideoUrl] 解析。
 Map<String, dynamic>? get alternates;
/// Create a copy of PostSample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostSampleCopyWith<PostSample> get copyWith => _$PostSampleCopyWithImpl<PostSample>(this as PostSample, _$identity);

  /// Serializes this PostSample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostSample&&(identical(other.has, has) || other.has == has)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.alternates, alternates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,has,width,height,url,const DeepCollectionEquality().hash(alternates));

@override
String toString() {
  return 'PostSample(has: $has, width: $width, height: $height, url: $url, alternates: $alternates)';
}


}

/// @nodoc
abstract mixin class $PostSampleCopyWith<$Res>  {
  factory $PostSampleCopyWith(PostSample value, $Res Function(PostSample) _then) = _$PostSampleCopyWithImpl;
@useResult
$Res call({
 bool has, int? width, int? height, String? url, Map<String, dynamic>? alternates
});




}
/// @nodoc
class _$PostSampleCopyWithImpl<$Res>
    implements $PostSampleCopyWith<$Res> {
  _$PostSampleCopyWithImpl(this._self, this._then);

  final PostSample _self;
  final $Res Function(PostSample) _then;

/// Create a copy of PostSample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? has = null,Object? width = freezed,Object? height = freezed,Object? url = freezed,Object? alternates = freezed,}) {
  return _then(_self.copyWith(
has: null == has ? _self.has : has // ignore: cast_nullable_to_non_nullable
as bool,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,alternates: freezed == alternates ? _self.alternates : alternates // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostSample].
extension PostSamplePatterns on PostSample {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostSample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostSample() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostSample value)  $default,){
final _that = this;
switch (_that) {
case _PostSample():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostSample value)?  $default,){
final _that = this;
switch (_that) {
case _PostSample() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool has,  int? width,  int? height,  String? url,  Map<String, dynamic>? alternates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostSample() when $default != null:
return $default(_that.has,_that.width,_that.height,_that.url,_that.alternates);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool has,  int? width,  int? height,  String? url,  Map<String, dynamic>? alternates)  $default,) {final _that = this;
switch (_that) {
case _PostSample():
return $default(_that.has,_that.width,_that.height,_that.url,_that.alternates);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool has,  int? width,  int? height,  String? url,  Map<String, dynamic>? alternates)?  $default,) {final _that = this;
switch (_that) {
case _PostSample() when $default != null:
return $default(_that.has,_that.width,_that.height,_that.url,_that.alternates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostSample implements PostSample {
  const _PostSample({this.has = false, this.width, this.height, this.url, final  Map<String, dynamic>? alternates}): _alternates = alternates;
  factory _PostSample.fromJson(Map<String, dynamic> json) => _$PostSampleFromJson(json);

@override@JsonKey() final  bool has;
@override final  int? width;
@override final  int? height;
@override final  String? url;
/// e621 视频转码表：{'720p': {'type':'video','urls':[...]}, ...}。
/// 结构不稳定，保留原始 Map 由 [E621PostVideo.bestVideoUrl] 解析。
 final  Map<String, dynamic>? _alternates;
/// e621 视频转码表：{'720p': {'type':'video','urls':[...]}, ...}。
/// 结构不稳定，保留原始 Map 由 [E621PostVideo.bestVideoUrl] 解析。
@override Map<String, dynamic>? get alternates {
  final value = _alternates;
  if (value == null) return null;
  if (_alternates is EqualUnmodifiableMapView) return _alternates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PostSample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostSampleCopyWith<_PostSample> get copyWith => __$PostSampleCopyWithImpl<_PostSample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostSampleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostSample&&(identical(other.has, has) || other.has == has)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._alternates, _alternates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,has,width,height,url,const DeepCollectionEquality().hash(_alternates));

@override
String toString() {
  return 'PostSample(has: $has, width: $width, height: $height, url: $url, alternates: $alternates)';
}


}

/// @nodoc
abstract mixin class _$PostSampleCopyWith<$Res> implements $PostSampleCopyWith<$Res> {
  factory _$PostSampleCopyWith(_PostSample value, $Res Function(_PostSample) _then) = __$PostSampleCopyWithImpl;
@override @useResult
$Res call({
 bool has, int? width, int? height, String? url, Map<String, dynamic>? alternates
});




}
/// @nodoc
class __$PostSampleCopyWithImpl<$Res>
    implements _$PostSampleCopyWith<$Res> {
  __$PostSampleCopyWithImpl(this._self, this._then);

  final _PostSample _self;
  final $Res Function(_PostSample) _then;

/// Create a copy of PostSample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? has = null,Object? width = freezed,Object? height = freezed,Object? url = freezed,Object? alternates = freezed,}) {
  return _then(_PostSample(
has: null == has ? _self.has : has // ignore: cast_nullable_to_non_nullable
as bool,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,alternates: freezed == alternates ? _self._alternates : alternates // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$PostScore {

 int get up; int get down; int get total;
/// Create a copy of PostScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostScoreCopyWith<PostScore> get copyWith => _$PostScoreCopyWithImpl<PostScore>(this as PostScore, _$identity);

  /// Serializes this PostScore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostScore&&(identical(other.up, up) || other.up == up)&&(identical(other.down, down) || other.down == down)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,up,down,total);

@override
String toString() {
  return 'PostScore(up: $up, down: $down, total: $total)';
}


}

/// @nodoc
abstract mixin class $PostScoreCopyWith<$Res>  {
  factory $PostScoreCopyWith(PostScore value, $Res Function(PostScore) _then) = _$PostScoreCopyWithImpl;
@useResult
$Res call({
 int up, int down, int total
});




}
/// @nodoc
class _$PostScoreCopyWithImpl<$Res>
    implements $PostScoreCopyWith<$Res> {
  _$PostScoreCopyWithImpl(this._self, this._then);

  final PostScore _self;
  final $Res Function(PostScore) _then;

/// Create a copy of PostScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? up = null,Object? down = null,Object? total = null,}) {
  return _then(_self.copyWith(
up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as int,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PostScore].
extension PostScorePatterns on PostScore {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostScore() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostScore value)  $default,){
final _that = this;
switch (_that) {
case _PostScore():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostScore value)?  $default,){
final _that = this;
switch (_that) {
case _PostScore() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int up,  int down,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostScore() when $default != null:
return $default(_that.up,_that.down,_that.total);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int up,  int down,  int total)  $default,) {final _that = this;
switch (_that) {
case _PostScore():
return $default(_that.up,_that.down,_that.total);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int up,  int down,  int total)?  $default,) {final _that = this;
switch (_that) {
case _PostScore() when $default != null:
return $default(_that.up,_that.down,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostScore implements PostScore {
  const _PostScore({required this.up, required this.down, required this.total});
  factory _PostScore.fromJson(Map<String, dynamic> json) => _$PostScoreFromJson(json);

@override final  int up;
@override final  int down;
@override final  int total;

/// Create a copy of PostScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostScoreCopyWith<_PostScore> get copyWith => __$PostScoreCopyWithImpl<_PostScore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostScoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostScore&&(identical(other.up, up) || other.up == up)&&(identical(other.down, down) || other.down == down)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,up,down,total);

@override
String toString() {
  return 'PostScore(up: $up, down: $down, total: $total)';
}


}

/// @nodoc
abstract mixin class _$PostScoreCopyWith<$Res> implements $PostScoreCopyWith<$Res> {
  factory _$PostScoreCopyWith(_PostScore value, $Res Function(_PostScore) _then) = __$PostScoreCopyWithImpl;
@override @useResult
$Res call({
 int up, int down, int total
});




}
/// @nodoc
class __$PostScoreCopyWithImpl<$Res>
    implements _$PostScoreCopyWith<$Res> {
  __$PostScoreCopyWithImpl(this._self, this._then);

  final _PostScore _self;
  final $Res Function(_PostScore) _then;

/// Create a copy of PostScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? up = null,Object? down = null,Object? total = null,}) {
  return _then(_PostScore(
up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as int,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PostTags {

 List<String> get general; List<String> get artist; List<String> get copyright; List<String> get character; List<String> get species; List<String> get invalid; List<String> get meta; List<String> get lore;
/// Create a copy of PostTags
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostTagsCopyWith<PostTags> get copyWith => _$PostTagsCopyWithImpl<PostTags>(this as PostTags, _$identity);

  /// Serializes this PostTags to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostTags&&const DeepCollectionEquality().equals(other.general, general)&&const DeepCollectionEquality().equals(other.artist, artist)&&const DeepCollectionEquality().equals(other.copyright, copyright)&&const DeepCollectionEquality().equals(other.character, character)&&const DeepCollectionEquality().equals(other.species, species)&&const DeepCollectionEquality().equals(other.invalid, invalid)&&const DeepCollectionEquality().equals(other.meta, meta)&&const DeepCollectionEquality().equals(other.lore, lore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(general),const DeepCollectionEquality().hash(artist),const DeepCollectionEquality().hash(copyright),const DeepCollectionEquality().hash(character),const DeepCollectionEquality().hash(species),const DeepCollectionEquality().hash(invalid),const DeepCollectionEquality().hash(meta),const DeepCollectionEquality().hash(lore));

@override
String toString() {
  return 'PostTags(general: $general, artist: $artist, copyright: $copyright, character: $character, species: $species, invalid: $invalid, meta: $meta, lore: $lore)';
}


}

/// @nodoc
abstract mixin class $PostTagsCopyWith<$Res>  {
  factory $PostTagsCopyWith(PostTags value, $Res Function(PostTags) _then) = _$PostTagsCopyWithImpl;
@useResult
$Res call({
 List<String> general, List<String> artist, List<String> copyright, List<String> character, List<String> species, List<String> invalid, List<String> meta, List<String> lore
});




}
/// @nodoc
class _$PostTagsCopyWithImpl<$Res>
    implements $PostTagsCopyWith<$Res> {
  _$PostTagsCopyWithImpl(this._self, this._then);

  final PostTags _self;
  final $Res Function(PostTags) _then;

/// Create a copy of PostTags
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? general = null,Object? artist = null,Object? copyright = null,Object? character = null,Object? species = null,Object? invalid = null,Object? meta = null,Object? lore = null,}) {
  return _then(_self.copyWith(
general: null == general ? _self.general : general // ignore: cast_nullable_to_non_nullable
as List<String>,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as List<String>,copyright: null == copyright ? _self.copyright : copyright // ignore: cast_nullable_to_non_nullable
as List<String>,character: null == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as List<String>,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as List<String>,invalid: null == invalid ? _self.invalid : invalid // ignore: cast_nullable_to_non_nullable
as List<String>,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as List<String>,lore: null == lore ? _self.lore : lore // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PostTags].
extension PostTagsPatterns on PostTags {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostTags value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostTags() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostTags value)  $default,){
final _that = this;
switch (_that) {
case _PostTags():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostTags value)?  $default,){
final _that = this;
switch (_that) {
case _PostTags() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> general,  List<String> artist,  List<String> copyright,  List<String> character,  List<String> species,  List<String> invalid,  List<String> meta,  List<String> lore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostTags() when $default != null:
return $default(_that.general,_that.artist,_that.copyright,_that.character,_that.species,_that.invalid,_that.meta,_that.lore);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> general,  List<String> artist,  List<String> copyright,  List<String> character,  List<String> species,  List<String> invalid,  List<String> meta,  List<String> lore)  $default,) {final _that = this;
switch (_that) {
case _PostTags():
return $default(_that.general,_that.artist,_that.copyright,_that.character,_that.species,_that.invalid,_that.meta,_that.lore);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> general,  List<String> artist,  List<String> copyright,  List<String> character,  List<String> species,  List<String> invalid,  List<String> meta,  List<String> lore)?  $default,) {final _that = this;
switch (_that) {
case _PostTags() when $default != null:
return $default(_that.general,_that.artist,_that.copyright,_that.character,_that.species,_that.invalid,_that.meta,_that.lore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostTags implements PostTags {
  const _PostTags({final  List<String> general = const [], final  List<String> artist = const [], final  List<String> copyright = const [], final  List<String> character = const [], final  List<String> species = const [], final  List<String> invalid = const [], final  List<String> meta = const [], final  List<String> lore = const []}): _general = general,_artist = artist,_copyright = copyright,_character = character,_species = species,_invalid = invalid,_meta = meta,_lore = lore;
  factory _PostTags.fromJson(Map<String, dynamic> json) => _$PostTagsFromJson(json);

 final  List<String> _general;
@override@JsonKey() List<String> get general {
  if (_general is EqualUnmodifiableListView) return _general;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_general);
}

 final  List<String> _artist;
@override@JsonKey() List<String> get artist {
  if (_artist is EqualUnmodifiableListView) return _artist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_artist);
}

 final  List<String> _copyright;
@override@JsonKey() List<String> get copyright {
  if (_copyright is EqualUnmodifiableListView) return _copyright;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_copyright);
}

 final  List<String> _character;
@override@JsonKey() List<String> get character {
  if (_character is EqualUnmodifiableListView) return _character;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_character);
}

 final  List<String> _species;
@override@JsonKey() List<String> get species {
  if (_species is EqualUnmodifiableListView) return _species;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_species);
}

 final  List<String> _invalid;
@override@JsonKey() List<String> get invalid {
  if (_invalid is EqualUnmodifiableListView) return _invalid;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invalid);
}

 final  List<String> _meta;
@override@JsonKey() List<String> get meta {
  if (_meta is EqualUnmodifiableListView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meta);
}

 final  List<String> _lore;
@override@JsonKey() List<String> get lore {
  if (_lore is EqualUnmodifiableListView) return _lore;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lore);
}


/// Create a copy of PostTags
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostTagsCopyWith<_PostTags> get copyWith => __$PostTagsCopyWithImpl<_PostTags>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostTagsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostTags&&const DeepCollectionEquality().equals(other._general, _general)&&const DeepCollectionEquality().equals(other._artist, _artist)&&const DeepCollectionEquality().equals(other._copyright, _copyright)&&const DeepCollectionEquality().equals(other._character, _character)&&const DeepCollectionEquality().equals(other._species, _species)&&const DeepCollectionEquality().equals(other._invalid, _invalid)&&const DeepCollectionEquality().equals(other._meta, _meta)&&const DeepCollectionEquality().equals(other._lore, _lore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_general),const DeepCollectionEquality().hash(_artist),const DeepCollectionEquality().hash(_copyright),const DeepCollectionEquality().hash(_character),const DeepCollectionEquality().hash(_species),const DeepCollectionEquality().hash(_invalid),const DeepCollectionEquality().hash(_meta),const DeepCollectionEquality().hash(_lore));

@override
String toString() {
  return 'PostTags(general: $general, artist: $artist, copyright: $copyright, character: $character, species: $species, invalid: $invalid, meta: $meta, lore: $lore)';
}


}

/// @nodoc
abstract mixin class _$PostTagsCopyWith<$Res> implements $PostTagsCopyWith<$Res> {
  factory _$PostTagsCopyWith(_PostTags value, $Res Function(_PostTags) _then) = __$PostTagsCopyWithImpl;
@override @useResult
$Res call({
 List<String> general, List<String> artist, List<String> copyright, List<String> character, List<String> species, List<String> invalid, List<String> meta, List<String> lore
});




}
/// @nodoc
class __$PostTagsCopyWithImpl<$Res>
    implements _$PostTagsCopyWith<$Res> {
  __$PostTagsCopyWithImpl(this._self, this._then);

  final _PostTags _self;
  final $Res Function(_PostTags) _then;

/// Create a copy of PostTags
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? general = null,Object? artist = null,Object? copyright = null,Object? character = null,Object? species = null,Object? invalid = null,Object? meta = null,Object? lore = null,}) {
  return _then(_PostTags(
general: null == general ? _self._general : general // ignore: cast_nullable_to_non_nullable
as List<String>,artist: null == artist ? _self._artist : artist // ignore: cast_nullable_to_non_nullable
as List<String>,copyright: null == copyright ? _self._copyright : copyright // ignore: cast_nullable_to_non_nullable
as List<String>,character: null == character ? _self._character : character // ignore: cast_nullable_to_non_nullable
as List<String>,species: null == species ? _self._species : species // ignore: cast_nullable_to_non_nullable
as List<String>,invalid: null == invalid ? _self._invalid : invalid // ignore: cast_nullable_to_non_nullable
as List<String>,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as List<String>,lore: null == lore ? _self._lore : lore // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
