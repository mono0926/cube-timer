// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trivia_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TriviaItem {

 String get content; String get category;// e.g., History, Hardware, Record, Technique
 String? get source;
/// Create a copy of TriviaItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TriviaItemCopyWith<TriviaItem> get copyWith => _$TriviaItemCopyWithImpl<TriviaItem>(this as TriviaItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TriviaItem&&(identical(other.content, content) || other.content == content)&&(identical(other.category, category) || other.category == category)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,content,category,source);

@override
String toString() {
  return 'TriviaItem(content: $content, category: $category, source: $source)';
}


}

/// @nodoc
abstract mixin class $TriviaItemCopyWith<$Res>  {
  factory $TriviaItemCopyWith(TriviaItem value, $Res Function(TriviaItem) _then) = _$TriviaItemCopyWithImpl;
@useResult
$Res call({
 String content, String category, String? source
});




}
/// @nodoc
class _$TriviaItemCopyWithImpl<$Res>
    implements $TriviaItemCopyWith<$Res> {
  _$TriviaItemCopyWithImpl(this._self, this._then);

  final TriviaItem _self;
  final $Res Function(TriviaItem) _then;

/// Create a copy of TriviaItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? category = null,Object? source = freezed,}) {
  return _then(_self.copyWith(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TriviaItem].
extension TriviaItemPatterns on TriviaItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TriviaItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TriviaItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TriviaItem value)  $default,){
final _that = this;
switch (_that) {
case _TriviaItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TriviaItem value)?  $default,){
final _that = this;
switch (_that) {
case _TriviaItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String content,  String category,  String? source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TriviaItem() when $default != null:
return $default(_that.content,_that.category,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String content,  String category,  String? source)  $default,) {final _that = this;
switch (_that) {
case _TriviaItem():
return $default(_that.content,_that.category,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String content,  String category,  String? source)?  $default,) {final _that = this;
switch (_that) {
case _TriviaItem() when $default != null:
return $default(_that.content,_that.category,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _TriviaItem implements TriviaItem {
  const _TriviaItem({required this.content, required this.category, this.source});
  

@override final  String content;
@override final  String category;
// e.g., History, Hardware, Record, Technique
@override final  String? source;

/// Create a copy of TriviaItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TriviaItemCopyWith<_TriviaItem> get copyWith => __$TriviaItemCopyWithImpl<_TriviaItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TriviaItem&&(identical(other.content, content) || other.content == content)&&(identical(other.category, category) || other.category == category)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,content,category,source);

@override
String toString() {
  return 'TriviaItem(content: $content, category: $category, source: $source)';
}


}

/// @nodoc
abstract mixin class _$TriviaItemCopyWith<$Res> implements $TriviaItemCopyWith<$Res> {
  factory _$TriviaItemCopyWith(_TriviaItem value, $Res Function(_TriviaItem) _then) = __$TriviaItemCopyWithImpl;
@override @useResult
$Res call({
 String content, String category, String? source
});




}
/// @nodoc
class __$TriviaItemCopyWithImpl<$Res>
    implements _$TriviaItemCopyWith<$Res> {
  __$TriviaItemCopyWithImpl(this._self, this._then);

  final _TriviaItem _self;
  final $Res Function(_TriviaItem) _then;

/// Create a copy of TriviaItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? category = null,Object? source = freezed,}) {
  return _then(_TriviaItem(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
