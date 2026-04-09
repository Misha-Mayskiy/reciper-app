// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'daily_calories_target')
  int get dailyCaloriesTarget => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_protein')
  int get targetProtein => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_fat')
  int get targetFat => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_carbs')
  int get targetCarbs => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'daily_calories_target') int dailyCaloriesTarget,
      @JsonKey(name: 'target_protein') int targetProtein,
      @JsonKey(name: 'target_fat') int targetFat,
      @JsonKey(name: 'target_carbs') int targetCarbs});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? dailyCaloriesTarget = null,
    Object? targetProtein = null,
    Object? targetFat = null,
    Object? targetCarbs = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dailyCaloriesTarget: null == dailyCaloriesTarget
          ? _value.dailyCaloriesTarget
          : dailyCaloriesTarget // ignore: cast_nullable_to_non_nullable
              as int,
      targetProtein: null == targetProtein
          ? _value.targetProtein
          : targetProtein // ignore: cast_nullable_to_non_nullable
              as int,
      targetFat: null == targetFat
          ? _value.targetFat
          : targetFat // ignore: cast_nullable_to_non_nullable
              as int,
      targetCarbs: null == targetCarbs
          ? _value.targetCarbs
          : targetCarbs // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'daily_calories_target') int dailyCaloriesTarget,
      @JsonKey(name: 'target_protein') int targetProtein,
      @JsonKey(name: 'target_fat') int targetFat,
      @JsonKey(name: 'target_carbs') int targetCarbs});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? dailyCaloriesTarget = null,
    Object? targetProtein = null,
    Object? targetFat = null,
    Object? targetCarbs = null,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dailyCaloriesTarget: null == dailyCaloriesTarget
          ? _value.dailyCaloriesTarget
          : dailyCaloriesTarget // ignore: cast_nullable_to_non_nullable
              as int,
      targetProtein: null == targetProtein
          ? _value.targetProtein
          : targetProtein // ignore: cast_nullable_to_non_nullable
              as int,
      targetFat: null == targetFat
          ? _value.targetFat
          : targetFat // ignore: cast_nullable_to_non_nullable
              as int,
      targetCarbs: null == targetCarbs
          ? _value.targetCarbs
          : targetCarbs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.id,
      required this.name,
      @JsonKey(name: 'daily_calories_target') required this.dailyCaloriesTarget,
      @JsonKey(name: 'target_protein') required this.targetProtein,
      @JsonKey(name: 'target_fat') required this.targetFat,
      @JsonKey(name: 'target_carbs') required this.targetCarbs});

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'daily_calories_target')
  final int dailyCaloriesTarget;
  @override
  @JsonKey(name: 'target_protein')
  final int targetProtein;
  @override
  @JsonKey(name: 'target_fat')
  final int targetFat;
  @override
  @JsonKey(name: 'target_carbs')
  final int targetCarbs;

  @override
  String toString() {
    return 'User(id: $id, name: $name, dailyCaloriesTarget: $dailyCaloriesTarget, targetProtein: $targetProtein, targetFat: $targetFat, targetCarbs: $targetCarbs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dailyCaloriesTarget, dailyCaloriesTarget) ||
                other.dailyCaloriesTarget == dailyCaloriesTarget) &&
            (identical(other.targetProtein, targetProtein) ||
                other.targetProtein == targetProtein) &&
            (identical(other.targetFat, targetFat) ||
                other.targetFat == targetFat) &&
            (identical(other.targetCarbs, targetCarbs) ||
                other.targetCarbs == targetCarbs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, dailyCaloriesTarget,
      targetProtein, targetFat, targetCarbs);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
          {required final String id,
          required final String name,
          @JsonKey(name: 'daily_calories_target')
          required final int dailyCaloriesTarget,
          @JsonKey(name: 'target_protein') required final int targetProtein,
          @JsonKey(name: 'target_fat') required final int targetFat,
          @JsonKey(name: 'target_carbs') required final int targetCarbs}) =
      _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'daily_calories_target')
  int get dailyCaloriesTarget;
  @override
  @JsonKey(name: 'target_protein')
  int get targetProtein;
  @override
  @JsonKey(name: 'target_fat')
  int get targetFat;
  @override
  @JsonKey(name: 'target_carbs')
  int get targetCarbs;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
