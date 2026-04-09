// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TaskResponse _$TaskResponseFromJson(Map<String, dynamic> json) {
  return _TaskResponse.fromJson(json);
}

/// @nodoc
mixin _$TaskResponse {
  String get status => throw _privateConstructorUsedError;
  List<String>? get ingredients => throw _privateConstructorUsedError;
  List<Recipe>? get recipes => throw _privateConstructorUsedError;

  /// Serializes this TaskResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskResponseCopyWith<TaskResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskResponseCopyWith<$Res> {
  factory $TaskResponseCopyWith(
          TaskResponse value, $Res Function(TaskResponse) then) =
      _$TaskResponseCopyWithImpl<$Res, TaskResponse>;
  @useResult
  $Res call({String status, List<String>? ingredients, List<Recipe>? recipes});
}

/// @nodoc
class _$TaskResponseCopyWithImpl<$Res, $Val extends TaskResponse>
    implements $TaskResponseCopyWith<$Res> {
  _$TaskResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? ingredients = freezed,
    Object? recipes = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      ingredients: freezed == ingredients
          ? _value.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      recipes: freezed == recipes
          ? _value.recipes
          : recipes // ignore: cast_nullable_to_non_nullable
              as List<Recipe>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskResponseImplCopyWith<$Res>
    implements $TaskResponseCopyWith<$Res> {
  factory _$$TaskResponseImplCopyWith(
          _$TaskResponseImpl value, $Res Function(_$TaskResponseImpl) then) =
      __$$TaskResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String status, List<String>? ingredients, List<Recipe>? recipes});
}

/// @nodoc
class __$$TaskResponseImplCopyWithImpl<$Res>
    extends _$TaskResponseCopyWithImpl<$Res, _$TaskResponseImpl>
    implements _$$TaskResponseImplCopyWith<$Res> {
  __$$TaskResponseImplCopyWithImpl(
      _$TaskResponseImpl _value, $Res Function(_$TaskResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? ingredients = freezed,
    Object? recipes = freezed,
  }) {
    return _then(_$TaskResponseImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      ingredients: freezed == ingredients
          ? _value._ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      recipes: freezed == recipes
          ? _value._recipes
          : recipes // ignore: cast_nullable_to_non_nullable
              as List<Recipe>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskResponseImpl implements _TaskResponse {
  const _$TaskResponseImpl(
      {required this.status,
      final List<String>? ingredients,
      final List<Recipe>? recipes})
      : _ingredients = ingredients,
        _recipes = recipes;

  factory _$TaskResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskResponseImplFromJson(json);

  @override
  final String status;
  final List<String>? _ingredients;
  @override
  List<String>? get ingredients {
    final value = _ingredients;
    if (value == null) return null;
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Recipe>? _recipes;
  @override
  List<Recipe>? get recipes {
    final value = _recipes;
    if (value == null) return null;
    if (_recipes is EqualUnmodifiableListView) return _recipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'TaskResponse(status: $status, ingredients: $ingredients, recipes: $recipes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskResponseImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._ingredients, _ingredients) &&
            const DeepCollectionEquality().equals(other._recipes, _recipes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      const DeepCollectionEquality().hash(_ingredients),
      const DeepCollectionEquality().hash(_recipes));

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskResponseImplCopyWith<_$TaskResponseImpl> get copyWith =>
      __$$TaskResponseImplCopyWithImpl<_$TaskResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskResponseImplToJson(
      this,
    );
  }
}

abstract class _TaskResponse implements TaskResponse {
  const factory _TaskResponse(
      {required final String status,
      final List<String>? ingredients,
      final List<Recipe>? recipes}) = _$TaskResponseImpl;

  factory _TaskResponse.fromJson(Map<String, dynamic> json) =
      _$TaskResponseImpl.fromJson;

  @override
  String get status;
  @override
  List<String>? get ingredients;
  @override
  List<Recipe>? get recipes;

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskResponseImplCopyWith<_$TaskResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
