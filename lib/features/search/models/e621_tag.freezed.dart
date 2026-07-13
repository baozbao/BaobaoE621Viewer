// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'e621_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$E621Tag {

 int get id; String get name;@JsonKey(name: 'post_count') int get postCount; int get category;@JsonKey(name: 'antecedent_name') String? get antecedentName;
/// Create a copy of E621Tag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$E621TagCopyWith<E621Tag> get copyWith => _$E621TagCopyWithImpl<E621Tag>(this as E621Tag, _$identity);

  /// Serializes this E621Tag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is E621Tag&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.category, category) || other.category == category)&&(identical(other.antecedentName, antecedentName) || other.antecedentName == antecedentName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,postCount,category,antecedentName);

@override
String toString() {
  return 'E621Tag(id: $id, name: $name, postCount: $postCount, category: $category, antecedentName: $antecedentName)';
}


}

/// @nodoc
abstract mixin class $E621TagCopyWith<$Res>  {
  factory $E621TagCopyWith(E621Tag value, $Res Function(E621Tag) _then) = _$E621TagCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'post_count') int postCount, int category,@JsonKey(name: 'antecedent_name') String? antecedentName
});




}
/// @nodoc
class _$E621TagCopyWithImpl<$Res>
    implements $E621TagCopyWith<$Res> {
  _$E621TagCopyWithImpl(this._self, this._then);

  final E621Tag _self;
  final $Res Function(E621Tag) _then;

/// Create a copy of E621Tag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? postCount = null,Object? category = null,Object? antecedentName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as int,antecedentName: freezed == antecedentName ? _self.antecedentName : antecedentName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [E621Tag].
extension E621TagPatterns on E621Tag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _E621Tag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _E621Tag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _E621Tag value)  $default,){
final _that = this;
switch (_that) {
case _E621Tag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _E621Tag value)?  $default,){
final _that = this;
switch (_that) {
case _E621Tag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'post_count')  int postCount,  int category, @JsonKey(name: 'antecedent_name')  String? antecedentName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _E621Tag() when $default != null:
return $default(_that.id,_that.name,_that.postCount,_that.category,_that.antecedentName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'post_count')  int postCount,  int category, @JsonKey(name: 'antecedent_name')  String? antecedentName)  $default,) {final _that = this;
switch (_that) {
case _E621Tag():
return $default(_that.id,_that.name,_that.postCount,_that.category,_that.antecedentName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'post_count')  int postCount,  int category, @JsonKey(name: 'antecedent_name')  String? antecedentName)?  $default,) {final _that = this;
switch (_that) {
case _E621Tag() when $default != null:
return $default(_that.id,_that.name,_that.postCount,_that.category,_that.antecedentName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _E621Tag implements E621Tag {
  const _E621Tag({required this.id, required this.name, @JsonKey(name: 'post_count') required this.postCount, required this.category, @JsonKey(name: 'antecedent_name') this.antecedentName});
  factory _E621Tag.fromJson(Map<String, dynamic> json) => _$E621TagFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'post_count') final  int postCount;
@override final  int category;
@override@JsonKey(name: 'antecedent_name') final  String? antecedentName;

/// Create a copy of E621Tag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$E621TagCopyWith<_E621Tag> get copyWith => __$E621TagCopyWithImpl<_E621Tag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$E621TagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _E621Tag&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.category, category) || other.category == category)&&(identical(other.antecedentName, antecedentName) || other.antecedentName == antecedentName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,postCount,category,antecedentName);

@override
String toString() {
  return 'E621Tag(id: $id, name: $name, postCount: $postCount, category: $category, antecedentName: $antecedentName)';
}


}

/// @nodoc
abstract mixin class _$E621TagCopyWith<$Res> implements $E621TagCopyWith<$Res> {
  factory _$E621TagCopyWith(_E621Tag value, $Res Function(_E621Tag) _then) = __$E621TagCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'post_count') int postCount, int category,@JsonKey(name: 'antecedent_name') String? antecedentName
});




}
/// @nodoc
class __$E621TagCopyWithImpl<$Res>
    implements _$E621TagCopyWith<$Res> {
  __$E621TagCopyWithImpl(this._self, this._then);

  final _E621Tag _self;
  final $Res Function(_E621Tag) _then;

/// Create a copy of E621Tag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? postCount = null,Object? category = null,Object? antecedentName = freezed,}) {
  return _then(_E621Tag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as int,antecedentName: freezed == antecedentName ? _self.antecedentName : antecedentName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
