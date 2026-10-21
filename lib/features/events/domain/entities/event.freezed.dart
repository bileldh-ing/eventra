// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TicketTier {

 String get id; String get name; double get price; int get capacity; int get sold; List<String> get perks;
/// Create a copy of TicketTier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketTierCopyWith<TicketTier> get copyWith => _$TicketTierCopyWithImpl<TicketTier>(this as TicketTier, _$identity);

  /// Serializes this TicketTier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketTier&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.sold, sold) || other.sold == sold)&&const DeepCollectionEquality().equals(other.perks, perks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,capacity,sold,const DeepCollectionEquality().hash(perks));

@override
String toString() {
  return 'TicketTier(id: $id, name: $name, price: $price, capacity: $capacity, sold: $sold, perks: $perks)';
}


}

/// @nodoc
abstract mixin class $TicketTierCopyWith<$Res>  {
  factory $TicketTierCopyWith(TicketTier value, $Res Function(TicketTier) _then) = _$TicketTierCopyWithImpl;
@useResult
$Res call({
 String id, String name, double price, int capacity, int sold, List<String> perks
});




}
/// @nodoc
class _$TicketTierCopyWithImpl<$Res>
    implements $TicketTierCopyWith<$Res> {
  _$TicketTierCopyWithImpl(this._self, this._then);

  final TicketTier _self;
  final $Res Function(TicketTier) _then;

/// Create a copy of TicketTier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? capacity = null,Object? sold = null,Object? perks = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,sold: null == sold ? _self.sold : sold // ignore: cast_nullable_to_non_nullable
as int,perks: null == perks ? _self.perks : perks // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketTier].
extension TicketTierPatterns on TicketTier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketTier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketTier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketTier value)  $default,){
final _that = this;
switch (_that) {
case _TicketTier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketTier value)?  $default,){
final _that = this;
switch (_that) {
case _TicketTier() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double price,  int capacity,  int sold,  List<String> perks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketTier() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.capacity,_that.sold,_that.perks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double price,  int capacity,  int sold,  List<String> perks)  $default,) {final _that = this;
switch (_that) {
case _TicketTier():
return $default(_that.id,_that.name,_that.price,_that.capacity,_that.sold,_that.perks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double price,  int capacity,  int sold,  List<String> perks)?  $default,) {final _that = this;
switch (_that) {
case _TicketTier() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.capacity,_that.sold,_that.perks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TicketTier extends TicketTier {
  const _TicketTier({required this.id, required this.name, required this.price, required this.capacity, required this.sold, final  List<String> perks = const <String>[]}): _perks = perks,super._();
  factory _TicketTier.fromJson(Map<String, dynamic> json) => _$TicketTierFromJson(json);

@override final  String id;
@override final  String name;
@override final  double price;
@override final  int capacity;
@override final  int sold;
 final  List<String> _perks;
@override@JsonKey() List<String> get perks {
  if (_perks is EqualUnmodifiableListView) return _perks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_perks);
}


/// Create a copy of TicketTier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketTierCopyWith<_TicketTier> get copyWith => __$TicketTierCopyWithImpl<_TicketTier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketTierToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketTier&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.sold, sold) || other.sold == sold)&&const DeepCollectionEquality().equals(other._perks, _perks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,capacity,sold,const DeepCollectionEquality().hash(_perks));

@override
String toString() {
  return 'TicketTier(id: $id, name: $name, price: $price, capacity: $capacity, sold: $sold, perks: $perks)';
}


}

/// @nodoc
abstract mixin class _$TicketTierCopyWith<$Res> implements $TicketTierCopyWith<$Res> {
  factory _$TicketTierCopyWith(_TicketTier value, $Res Function(_TicketTier) _then) = __$TicketTierCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double price, int capacity, int sold, List<String> perks
});




}
/// @nodoc
class __$TicketTierCopyWithImpl<$Res>
    implements _$TicketTierCopyWith<$Res> {
  __$TicketTierCopyWithImpl(this._self, this._then);

  final _TicketTier _self;
  final $Res Function(_TicketTier) _then;

/// Create a copy of TicketTier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? capacity = null,Object? sold = null,Object? perks = null,}) {
  return _then(_TicketTier(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,sold: null == sold ? _self.sold : sold // ignore: cast_nullable_to_non_nullable
as int,perks: null == perks ? _self._perks : perks // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$Organizer {

 String get id; String get name; String get avatarUrl; bool get verified; int get followers;
/// Create a copy of Organizer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizerCopyWith<Organizer> get copyWith => _$OrganizerCopyWithImpl<Organizer>(this as Organizer, _$identity);

  /// Serializes this Organizer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Organizer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.followers, followers) || other.followers == followers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,verified,followers);

@override
String toString() {
  return 'Organizer(id: $id, name: $name, avatarUrl: $avatarUrl, verified: $verified, followers: $followers)';
}


}

/// @nodoc
abstract mixin class $OrganizerCopyWith<$Res>  {
  factory $OrganizerCopyWith(Organizer value, $Res Function(Organizer) _then) = _$OrganizerCopyWithImpl;
@useResult
$Res call({
 String id, String name, String avatarUrl, bool verified, int followers
});




}
/// @nodoc
class _$OrganizerCopyWithImpl<$Res>
    implements $OrganizerCopyWith<$Res> {
  _$OrganizerCopyWithImpl(this._self, this._then);

  final Organizer _self;
  final $Res Function(Organizer) _then;

/// Create a copy of Organizer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatarUrl = null,Object? verified = null,Object? followers = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,followers: null == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Organizer].
extension OrganizerPatterns on Organizer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Organizer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Organizer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Organizer value)  $default,){
final _that = this;
switch (_that) {
case _Organizer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Organizer value)?  $default,){
final _that = this;
switch (_that) {
case _Organizer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String avatarUrl,  bool verified,  int followers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Organizer() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.verified,_that.followers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String avatarUrl,  bool verified,  int followers)  $default,) {final _that = this;
switch (_that) {
case _Organizer():
return $default(_that.id,_that.name,_that.avatarUrl,_that.verified,_that.followers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String avatarUrl,  bool verified,  int followers)?  $default,) {final _that = this;
switch (_that) {
case _Organizer() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.verified,_that.followers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Organizer implements Organizer {
  const _Organizer({required this.id, required this.name, required this.avatarUrl, this.verified = false, this.followers = 0});
  factory _Organizer.fromJson(Map<String, dynamic> json) => _$OrganizerFromJson(json);

@override final  String id;
@override final  String name;
@override final  String avatarUrl;
@override@JsonKey() final  bool verified;
@override@JsonKey() final  int followers;

/// Create a copy of Organizer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizerCopyWith<_Organizer> get copyWith => __$OrganizerCopyWithImpl<_Organizer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Organizer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.followers, followers) || other.followers == followers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,verified,followers);

@override
String toString() {
  return 'Organizer(id: $id, name: $name, avatarUrl: $avatarUrl, verified: $verified, followers: $followers)';
}


}

/// @nodoc
abstract mixin class _$OrganizerCopyWith<$Res> implements $OrganizerCopyWith<$Res> {
  factory _$OrganizerCopyWith(_Organizer value, $Res Function(_Organizer) _then) = __$OrganizerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String avatarUrl, bool verified, int followers
});




}
/// @nodoc
class __$OrganizerCopyWithImpl<$Res>
    implements _$OrganizerCopyWith<$Res> {
  __$OrganizerCopyWithImpl(this._self, this._then);

  final _Organizer _self;
  final $Res Function(_Organizer) _then;

/// Create a copy of Organizer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatarUrl = null,Object? verified = null,Object? followers = null,}) {
  return _then(_Organizer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,followers: null == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LineupItem {

 DateTime get time; String get title;
/// Create a copy of LineupItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineupItemCopyWith<LineupItem> get copyWith => _$LineupItemCopyWithImpl<LineupItem>(this as LineupItem, _$identity);

  /// Serializes this LineupItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineupItem&&(identical(other.time, time) || other.time == time)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,time,title);

@override
String toString() {
  return 'LineupItem(time: $time, title: $title)';
}


}

/// @nodoc
abstract mixin class $LineupItemCopyWith<$Res>  {
  factory $LineupItemCopyWith(LineupItem value, $Res Function(LineupItem) _then) = _$LineupItemCopyWithImpl;
@useResult
$Res call({
 DateTime time, String title
});




}
/// @nodoc
class _$LineupItemCopyWithImpl<$Res>
    implements $LineupItemCopyWith<$Res> {
  _$LineupItemCopyWithImpl(this._self, this._then);

  final LineupItem _self;
  final $Res Function(LineupItem) _then;

/// Create a copy of LineupItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? title = null,}) {
  return _then(_self.copyWith(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LineupItem].
extension LineupItemPatterns on LineupItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineupItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineupItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineupItem value)  $default,){
final _that = this;
switch (_that) {
case _LineupItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineupItem value)?  $default,){
final _that = this;
switch (_that) {
case _LineupItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime time,  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineupItem() when $default != null:
return $default(_that.time,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime time,  String title)  $default,) {final _that = this;
switch (_that) {
case _LineupItem():
return $default(_that.time,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime time,  String title)?  $default,) {final _that = this;
switch (_that) {
case _LineupItem() when $default != null:
return $default(_that.time,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LineupItem implements LineupItem {
  const _LineupItem({required this.time, required this.title});
  factory _LineupItem.fromJson(Map<String, dynamic> json) => _$LineupItemFromJson(json);

@override final  DateTime time;
@override final  String title;

/// Create a copy of LineupItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineupItemCopyWith<_LineupItem> get copyWith => __$LineupItemCopyWithImpl<_LineupItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LineupItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineupItem&&(identical(other.time, time) || other.time == time)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,time,title);

@override
String toString() {
  return 'LineupItem(time: $time, title: $title)';
}


}

/// @nodoc
abstract mixin class _$LineupItemCopyWith<$Res> implements $LineupItemCopyWith<$Res> {
  factory _$LineupItemCopyWith(_LineupItem value, $Res Function(_LineupItem) _then) = __$LineupItemCopyWithImpl;
@override @useResult
$Res call({
 DateTime time, String title
});




}
/// @nodoc
class __$LineupItemCopyWithImpl<$Res>
    implements _$LineupItemCopyWith<$Res> {
  __$LineupItemCopyWithImpl(this._self, this._then);

  final _LineupItem _self;
  final $Res Function(_LineupItem) _then;

/// Create a copy of LineupItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? title = null,}) {
  return _then(_LineupItem(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$EventReview {

 String get author; String get avatarUrl; int get rating; String get text; DateTime get date;
/// Create a copy of EventReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventReviewCopyWith<EventReview> get copyWith => _$EventReviewCopyWithImpl<EventReview>(this as EventReview, _$identity);

  /// Serializes this EventReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventReview&&(identical(other.author, author) || other.author == author)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.text, text) || other.text == text)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,author,avatarUrl,rating,text,date);

@override
String toString() {
  return 'EventReview(author: $author, avatarUrl: $avatarUrl, rating: $rating, text: $text, date: $date)';
}


}

/// @nodoc
abstract mixin class $EventReviewCopyWith<$Res>  {
  factory $EventReviewCopyWith(EventReview value, $Res Function(EventReview) _then) = _$EventReviewCopyWithImpl;
@useResult
$Res call({
 String author, String avatarUrl, int rating, String text, DateTime date
});




}
/// @nodoc
class _$EventReviewCopyWithImpl<$Res>
    implements $EventReviewCopyWith<$Res> {
  _$EventReviewCopyWithImpl(this._self, this._then);

  final EventReview _self;
  final $Res Function(EventReview) _then;

/// Create a copy of EventReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? author = null,Object? avatarUrl = null,Object? rating = null,Object? text = null,Object? date = null,}) {
  return _then(_self.copyWith(
author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [EventReview].
extension EventReviewPatterns on EventReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventReview value)  $default,){
final _that = this;
switch (_that) {
case _EventReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventReview value)?  $default,){
final _that = this;
switch (_that) {
case _EventReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String author,  String avatarUrl,  int rating,  String text,  DateTime date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventReview() when $default != null:
return $default(_that.author,_that.avatarUrl,_that.rating,_that.text,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String author,  String avatarUrl,  int rating,  String text,  DateTime date)  $default,) {final _that = this;
switch (_that) {
case _EventReview():
return $default(_that.author,_that.avatarUrl,_that.rating,_that.text,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String author,  String avatarUrl,  int rating,  String text,  DateTime date)?  $default,) {final _that = this;
switch (_that) {
case _EventReview() when $default != null:
return $default(_that.author,_that.avatarUrl,_that.rating,_that.text,_that.date);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventReview implements EventReview {
  const _EventReview({required this.author, required this.avatarUrl, required this.rating, required this.text, required this.date});
  factory _EventReview.fromJson(Map<String, dynamic> json) => _$EventReviewFromJson(json);

@override final  String author;
@override final  String avatarUrl;
@override final  int rating;
@override final  String text;
@override final  DateTime date;

/// Create a copy of EventReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventReviewCopyWith<_EventReview> get copyWith => __$EventReviewCopyWithImpl<_EventReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventReview&&(identical(other.author, author) || other.author == author)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.text, text) || other.text == text)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,author,avatarUrl,rating,text,date);

@override
String toString() {
  return 'EventReview(author: $author, avatarUrl: $avatarUrl, rating: $rating, text: $text, date: $date)';
}


}

/// @nodoc
abstract mixin class _$EventReviewCopyWith<$Res> implements $EventReviewCopyWith<$Res> {
  factory _$EventReviewCopyWith(_EventReview value, $Res Function(_EventReview) _then) = __$EventReviewCopyWithImpl;
@override @useResult
$Res call({
 String author, String avatarUrl, int rating, String text, DateTime date
});




}
/// @nodoc
class __$EventReviewCopyWithImpl<$Res>
    implements _$EventReviewCopyWith<$Res> {
  __$EventReviewCopyWithImpl(this._self, this._then);

  final _EventReview _self;
  final $Res Function(_EventReview) _then;

/// Create a copy of EventReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? author = null,Object? avatarUrl = null,Object? rating = null,Object? text = null,Object? date = null,}) {
  return _then(_EventReview(
author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Event {

 String get id; String get title; EventCategory get category; String get description; DateTime get startAt; DateTime get endAt; List<TicketTier> get tiers; int get capacity; int get soldCount; String get venue; String get address; double get latitude; double get longitude; Organizer get organizer; double get rating; int get reviewCount; int get participantsCount; String get coverImageUrl; List<String> get gallery; String get policy; List<String> get participantAvatars; List<String> get tags; List<LineupItem> get lineup; List<EventReview> get reviews; String? get imageCredit;
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCopyWith<Event> get copyWith => _$EventCopyWithImpl<Event>(this as Event, _$identity);

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Event&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&const DeepCollectionEquality().equals(other.tiers, tiers)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.soldCount, soldCount) || other.soldCount == soldCount)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.organizer, organizer) || other.organizer == organizer)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.participantsCount, participantsCount) || other.participantsCount == participantsCount)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&const DeepCollectionEquality().equals(other.gallery, gallery)&&(identical(other.policy, policy) || other.policy == policy)&&const DeepCollectionEquality().equals(other.participantAvatars, participantAvatars)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.lineup, lineup)&&const DeepCollectionEquality().equals(other.reviews, reviews)&&(identical(other.imageCredit, imageCredit) || other.imageCredit == imageCredit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,category,description,startAt,endAt,const DeepCollectionEquality().hash(tiers),capacity,soldCount,venue,address,latitude,longitude,organizer,rating,reviewCount,participantsCount,coverImageUrl,const DeepCollectionEquality().hash(gallery),policy,const DeepCollectionEquality().hash(participantAvatars),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(lineup),const DeepCollectionEquality().hash(reviews),imageCredit]);

@override
String toString() {
  return 'Event(id: $id, title: $title, category: $category, description: $description, startAt: $startAt, endAt: $endAt, tiers: $tiers, capacity: $capacity, soldCount: $soldCount, venue: $venue, address: $address, latitude: $latitude, longitude: $longitude, organizer: $organizer, rating: $rating, reviewCount: $reviewCount, participantsCount: $participantsCount, coverImageUrl: $coverImageUrl, gallery: $gallery, policy: $policy, participantAvatars: $participantAvatars, tags: $tags, lineup: $lineup, reviews: $reviews, imageCredit: $imageCredit)';
}


}

/// @nodoc
abstract mixin class $EventCopyWith<$Res>  {
  factory $EventCopyWith(Event value, $Res Function(Event) _then) = _$EventCopyWithImpl;
@useResult
$Res call({
 String id, String title, EventCategory category, String description, DateTime startAt, DateTime endAt, List<TicketTier> tiers, int capacity, int soldCount, String venue, String address, double latitude, double longitude, Organizer organizer, double rating, int reviewCount, int participantsCount, String coverImageUrl, List<String> gallery, String policy, List<String> participantAvatars, List<String> tags, List<LineupItem> lineup, List<EventReview> reviews, String? imageCredit
});


$OrganizerCopyWith<$Res> get organizer;

}
/// @nodoc
class _$EventCopyWithImpl<$Res>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._self, this._then);

  final Event _self;
  final $Res Function(Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? category = null,Object? description = null,Object? startAt = null,Object? endAt = null,Object? tiers = null,Object? capacity = null,Object? soldCount = null,Object? venue = null,Object? address = null,Object? latitude = null,Object? longitude = null,Object? organizer = null,Object? rating = null,Object? reviewCount = null,Object? participantsCount = null,Object? coverImageUrl = null,Object? gallery = null,Object? policy = null,Object? participantAvatars = null,Object? tags = null,Object? lineup = null,Object? reviews = null,Object? imageCredit = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as EventCategory,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,tiers: null == tiers ? _self.tiers : tiers // ignore: cast_nullable_to_non_nullable
as List<TicketTier>,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,soldCount: null == soldCount ? _self.soldCount : soldCount // ignore: cast_nullable_to_non_nullable
as int,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,organizer: null == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as Organizer,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,participantsCount: null == participantsCount ? _self.participantsCount : participantsCount // ignore: cast_nullable_to_non_nullable
as int,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,gallery: null == gallery ? _self.gallery : gallery // ignore: cast_nullable_to_non_nullable
as List<String>,policy: null == policy ? _self.policy : policy // ignore: cast_nullable_to_non_nullable
as String,participantAvatars: null == participantAvatars ? _self.participantAvatars : participantAvatars // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,lineup: null == lineup ? _self.lineup : lineup // ignore: cast_nullable_to_non_nullable
as List<LineupItem>,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<EventReview>,imageCredit: freezed == imageCredit ? _self.imageCredit : imageCredit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizerCopyWith<$Res> get organizer {
  
  return $OrganizerCopyWith<$Res>(_self.organizer, (value) {
    return _then(_self.copyWith(organizer: value));
  });
}
}


/// Adds pattern-matching-related methods to [Event].
extension EventPatterns on Event {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Event value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Event value)  $default,){
final _that = this;
switch (_that) {
case _Event():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Event value)?  $default,){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  EventCategory category,  String description,  DateTime startAt,  DateTime endAt,  List<TicketTier> tiers,  int capacity,  int soldCount,  String venue,  String address,  double latitude,  double longitude,  Organizer organizer,  double rating,  int reviewCount,  int participantsCount,  String coverImageUrl,  List<String> gallery,  String policy,  List<String> participantAvatars,  List<String> tags,  List<LineupItem> lineup,  List<EventReview> reviews,  String? imageCredit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.title,_that.category,_that.description,_that.startAt,_that.endAt,_that.tiers,_that.capacity,_that.soldCount,_that.venue,_that.address,_that.latitude,_that.longitude,_that.organizer,_that.rating,_that.reviewCount,_that.participantsCount,_that.coverImageUrl,_that.gallery,_that.policy,_that.participantAvatars,_that.tags,_that.lineup,_that.reviews,_that.imageCredit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  EventCategory category,  String description,  DateTime startAt,  DateTime endAt,  List<TicketTier> tiers,  int capacity,  int soldCount,  String venue,  String address,  double latitude,  double longitude,  Organizer organizer,  double rating,  int reviewCount,  int participantsCount,  String coverImageUrl,  List<String> gallery,  String policy,  List<String> participantAvatars,  List<String> tags,  List<LineupItem> lineup,  List<EventReview> reviews,  String? imageCredit)  $default,) {final _that = this;
switch (_that) {
case _Event():
return $default(_that.id,_that.title,_that.category,_that.description,_that.startAt,_that.endAt,_that.tiers,_that.capacity,_that.soldCount,_that.venue,_that.address,_that.latitude,_that.longitude,_that.organizer,_that.rating,_that.reviewCount,_that.participantsCount,_that.coverImageUrl,_that.gallery,_that.policy,_that.participantAvatars,_that.tags,_that.lineup,_that.reviews,_that.imageCredit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  EventCategory category,  String description,  DateTime startAt,  DateTime endAt,  List<TicketTier> tiers,  int capacity,  int soldCount,  String venue,  String address,  double latitude,  double longitude,  Organizer organizer,  double rating,  int reviewCount,  int participantsCount,  String coverImageUrl,  List<String> gallery,  String policy,  List<String> participantAvatars,  List<String> tags,  List<LineupItem> lineup,  List<EventReview> reviews,  String? imageCredit)?  $default,) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.title,_that.category,_that.description,_that.startAt,_that.endAt,_that.tiers,_that.capacity,_that.soldCount,_that.venue,_that.address,_that.latitude,_that.longitude,_that.organizer,_that.rating,_that.reviewCount,_that.participantsCount,_that.coverImageUrl,_that.gallery,_that.policy,_that.participantAvatars,_that.tags,_that.lineup,_that.reviews,_that.imageCredit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Event extends Event {
  const _Event({required this.id, required this.title, required this.category, required this.description, required this.startAt, required this.endAt, required final  List<TicketTier> tiers, required this.capacity, required this.soldCount, required this.venue, required this.address, required this.latitude, required this.longitude, required this.organizer, required this.rating, required this.reviewCount, required this.participantsCount, required this.coverImageUrl, required final  List<String> gallery, required this.policy, final  List<String> participantAvatars = const <String>[], final  List<String> tags = const <String>[], final  List<LineupItem> lineup = const <LineupItem>[], final  List<EventReview> reviews = const <EventReview>[], this.imageCredit}): _tiers = tiers,_gallery = gallery,_participantAvatars = participantAvatars,_tags = tags,_lineup = lineup,_reviews = reviews,super._();
  factory _Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

@override final  String id;
@override final  String title;
@override final  EventCategory category;
@override final  String description;
@override final  DateTime startAt;
@override final  DateTime endAt;
 final  List<TicketTier> _tiers;
@override List<TicketTier> get tiers {
  if (_tiers is EqualUnmodifiableListView) return _tiers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tiers);
}

@override final  int capacity;
@override final  int soldCount;
@override final  String venue;
@override final  String address;
@override final  double latitude;
@override final  double longitude;
@override final  Organizer organizer;
@override final  double rating;
@override final  int reviewCount;
@override final  int participantsCount;
@override final  String coverImageUrl;
 final  List<String> _gallery;
@override List<String> get gallery {
  if (_gallery is EqualUnmodifiableListView) return _gallery;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gallery);
}

@override final  String policy;
 final  List<String> _participantAvatars;
@override@JsonKey() List<String> get participantAvatars {
  if (_participantAvatars is EqualUnmodifiableListView) return _participantAvatars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantAvatars);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<LineupItem> _lineup;
@override@JsonKey() List<LineupItem> get lineup {
  if (_lineup is EqualUnmodifiableListView) return _lineup;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lineup);
}

 final  List<EventReview> _reviews;
@override@JsonKey() List<EventReview> get reviews {
  if (_reviews is EqualUnmodifiableListView) return _reviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviews);
}

@override final  String? imageCredit;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCopyWith<_Event> get copyWith => __$EventCopyWithImpl<_Event>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Event&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&const DeepCollectionEquality().equals(other._tiers, _tiers)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.soldCount, soldCount) || other.soldCount == soldCount)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.organizer, organizer) || other.organizer == organizer)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.participantsCount, participantsCount) || other.participantsCount == participantsCount)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&const DeepCollectionEquality().equals(other._gallery, _gallery)&&(identical(other.policy, policy) || other.policy == policy)&&const DeepCollectionEquality().equals(other._participantAvatars, _participantAvatars)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._lineup, _lineup)&&const DeepCollectionEquality().equals(other._reviews, _reviews)&&(identical(other.imageCredit, imageCredit) || other.imageCredit == imageCredit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,category,description,startAt,endAt,const DeepCollectionEquality().hash(_tiers),capacity,soldCount,venue,address,latitude,longitude,organizer,rating,reviewCount,participantsCount,coverImageUrl,const DeepCollectionEquality().hash(_gallery),policy,const DeepCollectionEquality().hash(_participantAvatars),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_lineup),const DeepCollectionEquality().hash(_reviews),imageCredit]);

@override
String toString() {
  return 'Event(id: $id, title: $title, category: $category, description: $description, startAt: $startAt, endAt: $endAt, tiers: $tiers, capacity: $capacity, soldCount: $soldCount, venue: $venue, address: $address, latitude: $latitude, longitude: $longitude, organizer: $organizer, rating: $rating, reviewCount: $reviewCount, participantsCount: $participantsCount, coverImageUrl: $coverImageUrl, gallery: $gallery, policy: $policy, participantAvatars: $participantAvatars, tags: $tags, lineup: $lineup, reviews: $reviews, imageCredit: $imageCredit)';
}


}

/// @nodoc
abstract mixin class _$EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$EventCopyWith(_Event value, $Res Function(_Event) _then) = __$EventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, EventCategory category, String description, DateTime startAt, DateTime endAt, List<TicketTier> tiers, int capacity, int soldCount, String venue, String address, double latitude, double longitude, Organizer organizer, double rating, int reviewCount, int participantsCount, String coverImageUrl, List<String> gallery, String policy, List<String> participantAvatars, List<String> tags, List<LineupItem> lineup, List<EventReview> reviews, String? imageCredit
});


@override $OrganizerCopyWith<$Res> get organizer;

}
/// @nodoc
class __$EventCopyWithImpl<$Res>
    implements _$EventCopyWith<$Res> {
  __$EventCopyWithImpl(this._self, this._then);

  final _Event _self;
  final $Res Function(_Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? category = null,Object? description = null,Object? startAt = null,Object? endAt = null,Object? tiers = null,Object? capacity = null,Object? soldCount = null,Object? venue = null,Object? address = null,Object? latitude = null,Object? longitude = null,Object? organizer = null,Object? rating = null,Object? reviewCount = null,Object? participantsCount = null,Object? coverImageUrl = null,Object? gallery = null,Object? policy = null,Object? participantAvatars = null,Object? tags = null,Object? lineup = null,Object? reviews = null,Object? imageCredit = freezed,}) {
  return _then(_Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as EventCategory,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,tiers: null == tiers ? _self._tiers : tiers // ignore: cast_nullable_to_non_nullable
as List<TicketTier>,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,soldCount: null == soldCount ? _self.soldCount : soldCount // ignore: cast_nullable_to_non_nullable
as int,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,organizer: null == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as Organizer,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,participantsCount: null == participantsCount ? _self.participantsCount : participantsCount // ignore: cast_nullable_to_non_nullable
as int,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,gallery: null == gallery ? _self._gallery : gallery // ignore: cast_nullable_to_non_nullable
as List<String>,policy: null == policy ? _self.policy : policy // ignore: cast_nullable_to_non_nullable
as String,participantAvatars: null == participantAvatars ? _self._participantAvatars : participantAvatars // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,lineup: null == lineup ? _self._lineup : lineup // ignore: cast_nullable_to_non_nullable
as List<LineupItem>,reviews: null == reviews ? _self._reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<EventReview>,imageCredit: freezed == imageCredit ? _self.imageCredit : imageCredit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizerCopyWith<$Res> get organizer {
  
  return $OrganizerCopyWith<$Res>(_self.organizer, (value) {
    return _then(_self.copyWith(organizer: value));
  });
}
}

// dart format on
