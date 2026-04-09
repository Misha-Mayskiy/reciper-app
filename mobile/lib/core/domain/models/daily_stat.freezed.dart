// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_stat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyStat _$DailyStatFromJson(Map<String, dynamic> json) {
  return _DailyStat.fromJson(json);
}

/// @nodoc
mixin _$DailyStat {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get date =>
      throw _privateConstructorUsedError; // Storing as String YYYY-MM-DD to be simple or DateTime
  @JsonKey(name: 'total_calories')
  int get totalCalories => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_protein')
  int get totalProtein => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_fat')
  int get totalFat => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_carbs')
  int get totalCarbs => throw _privateConstructorUsedError;

  /// Serializes this DailyStat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyStat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyStatCopyWith<DailyStat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyStatCopyWith<$Res> {
  factory $DailyStatCopyWith(DailyStat value, $Res Function(DailyStat) then) =
      _$DailyStatCopyWithImpl<$Res, DailyStat>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String date,
      @JsonKey(name: 'total_calories') int totalCalories,
      @JsonKey(name: 'total_protein') int totalProtein,
      @JsonKey(name: 'total_fat') int totalFat,
      @JsonKey(name: 'total_carbs') int totalCarbs});
}

/// @nodoc
class _$DailyStatCopyWithImpl<$Res, $Val extends DailyStat>
    implements $DailyStatCopyWith<$Res> {
  _$DailyStatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyStat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? totalCalories = null,
    Object? totalProtein = null,
    Object? totalFat = null,
    Object? totalCarbs = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      totalCalories: null == totalCalories
          ? _value.totalCalories
          : totalCalories // ignore: cast_nullable_to_non_nullable
              as int,
      totalProtein: null == totalProtein
          ? _value.totalProtein
          : totalProtein // ignore: cast_nullable_to_non_nullable
              as int,
      totalFat: null == totalFat
          ? _value.totalFat
          : totalFat // ignore: cast_nullable_to_non_nullable
              as int,
      totalCarbs: null == totalCarbs
          ? _value.totalCarbs
          : totalCarbs // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyStatImplCopyWith<$Res>
    implements $DailyStatCopyWith<$Res> {
  factory _$$DailyStatImplCopyWith(
          _$DailyStatImpl value, $Res Function(_$DailyStatImpl) then) =
      __$$DailyStatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String date,
      @JsonKey(name: 'total_calories') int totalCalories,
      @JsonKey(name: 'total_protein') int totalProtein,
      @JsonKey(name: 'total_fat') int totalFat,
      @JsonKey(name: 'total_carbs') int totalCarbs});
}

/// @nodoc
class __$$DailyStatImplCopyWithImpl<$Res>
    extends _$DailyStatCopyWithImpl<$Res, _$DailyStatImpl>
    implements _$$DailyStatImplCopyWith<$Res> {
  __$$DailyStatImplCopyWithImpl(
      _$DailyStatImpl _value, $Res Function(_$DailyStatImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyStat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? totalCalories = null,
    Object? totalProtein = null,
    Object? totalFat = null,
    Object? totalCarbs = null,
  }) {
    return _then(_$DailyStatImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      totalCalories: null == totalCalories
          ? _value.totalCalories
          : totalCalories // ignore: cast_nullable_to_non_nullable
              as int,
      totalProtein: null == totalProtein
          ? _value.totalProtein
          : totalProtein // ignore: cast_nullable_to_non_nullable
              as int,
      totalFat: null == totalFat
          ? _value.totalFat
          : totalFat // ignore: cast_nullable_to_non_nullable
              as int,
      totalCarbs: null == totalCarbs
          ? _value.totalCarbs
          : totalCarbs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyStatImpl implements _DailyStat {
  const _$DailyStatImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.date,
      @JsonKey(name: 'total_calories') required this.totalCalories,
      @JsonKey(name: 'total_protein') required this.totalProtein,
      @JsonKey(name: 'total_fat') required this.totalFat,
      @JsonKey(name: 'total_carbs') required this.totalCarbs});

  factory _$DailyStatImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyStatImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String date;
// Storing as String YYYY-MM-DD to be simple or DateTime
  @override
  @JsonKey(name: 'total_calories')
  final int totalCalories;
  @override
  @JsonKey(name: 'total_protein')
  final int totalProtein;
  @override
  @JsonKey(name: 'total_fat')
  final int totalFat;
  @override
  @JsonKey(name: 'total_carbs')
  final int totalCarbs;

  @override
  String toString() {
    return 'DailyStat(id: $id, userId: $userId, date: $date, totalCalories: $totalCalories, totalProtein: $totalProtein, totalFat: $totalFat, totalCarbs: $totalCarbs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyStatImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalCalories, totalCalories) ||
                other.totalCalories == totalCalories) &&
            (identical(other.totalProtein, totalProtein) ||
                other.totalProtein == totalProtein) &&
            (identical(other.totalFat, totalFat) ||
                other.totalFat == totalFat) &&
            (identical(other.totalCarbs, totalCarbs) ||
                other.totalCarbs == totalCarbs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, date, totalCalories,
      totalProtein, totalFat, totalCarbs);

  /// Create a copy of DailyStat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyStatImplCopyWith<_$DailyStatImpl> get copyWith =>
      __$$DailyStatImplCopyWithImpl<_$DailyStatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyStatImplToJson(
      this,
    );
  }
}

abstract class _DailyStat implements DailyStat {
  const factory _DailyStat(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          required final String date,
          @JsonKey(name: 'total_calories') required final int totalCalories,
          @JsonKey(name: 'total_protein') required final int totalProtein,
          @JsonKey(name: 'total_fat') required final int totalFat,
          @JsonKey(name: 'total_carbs') required final int totalCarbs}) =
      _$DailyStatImpl;

  factory _DailyStat.fromJson(Map<String, dynamic> json) =
      _$DailyStatImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get date; // Storing as String YYYY-MM-DD to be simple or DateTime
  @override
  @JsonKey(name: 'total_calories')
  int get totalCalories;
  @override
  @JsonKey(name: 'total_protein')
  int get totalProtein;
  @override
  @JsonKey(name: 'total_fat')
  int get totalFat;
  @override
  @JsonKey(name: 'total_carbs')
  int get totalCarbs;

  /// Create a copy of DailyStat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyStatImplCopyWith<_$DailyStatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
