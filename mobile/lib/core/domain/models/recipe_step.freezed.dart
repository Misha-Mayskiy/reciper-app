// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecipeStep _$RecipeStepFromJson(Map<String, dynamic> json) {
  return _RecipeStep.fromJson(json);
}

/// @nodoc
mixin _$RecipeStep {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'recipe_id')
  String get recipeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'step_number')
  int get stepNumber => throw _privateConstructorUsedError;
  String get instruction => throw _privateConstructorUsedError;
  @JsonKey(name: 'timer_seconds')
  int? get timerSeconds => throw _privateConstructorUsedError;

  /// Serializes this RecipeStep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecipeStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeStepCopyWith<RecipeStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeStepCopyWith<$Res> {
  factory $RecipeStepCopyWith(
          RecipeStep value, $Res Function(RecipeStep) then) =
      _$RecipeStepCopyWithImpl<$Res, RecipeStep>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'recipe_id') String recipeId,
      @JsonKey(name: 'step_number') int stepNumber,
      String instruction,
      @JsonKey(name: 'timer_seconds') int? timerSeconds});
}

/// @nodoc
class _$RecipeStepCopyWithImpl<$Res, $Val extends RecipeStep>
    implements $RecipeStepCopyWith<$Res> {
  _$RecipeStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecipeStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipeId = null,
    Object? stepNumber = null,
    Object? instruction = null,
    Object? timerSeconds = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      recipeId: null == recipeId
          ? _value.recipeId
          : recipeId // ignore: cast_nullable_to_non_nullable
              as String,
      stepNumber: null == stepNumber
          ? _value.stepNumber
          : stepNumber // ignore: cast_nullable_to_non_nullable
              as int,
      instruction: null == instruction
          ? _value.instruction
          : instruction // ignore: cast_nullable_to_non_nullable
              as String,
      timerSeconds: freezed == timerSeconds
          ? _value.timerSeconds
          : timerSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecipeStepImplCopyWith<$Res>
    implements $RecipeStepCopyWith<$Res> {
  factory _$$RecipeStepImplCopyWith(
          _$RecipeStepImpl value, $Res Function(_$RecipeStepImpl) then) =
      __$$RecipeStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'recipe_id') String recipeId,
      @JsonKey(name: 'step_number') int stepNumber,
      String instruction,
      @JsonKey(name: 'timer_seconds') int? timerSeconds});
}

/// @nodoc
class __$$RecipeStepImplCopyWithImpl<$Res>
    extends _$RecipeStepCopyWithImpl<$Res, _$RecipeStepImpl>
    implements _$$RecipeStepImplCopyWith<$Res> {
  __$$RecipeStepImplCopyWithImpl(
      _$RecipeStepImpl _value, $Res Function(_$RecipeStepImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecipeStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipeId = null,
    Object? stepNumber = null,
    Object? instruction = null,
    Object? timerSeconds = freezed,
  }) {
    return _then(_$RecipeStepImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      recipeId: null == recipeId
          ? _value.recipeId
          : recipeId // ignore: cast_nullable_to_non_nullable
              as String,
      stepNumber: null == stepNumber
          ? _value.stepNumber
          : stepNumber // ignore: cast_nullable_to_non_nullable
              as int,
      instruction: null == instruction
          ? _value.instruction
          : instruction // ignore: cast_nullable_to_non_nullable
              as String,
      timerSeconds: freezed == timerSeconds
          ? _value.timerSeconds
          : timerSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeStepImpl implements _RecipeStep {
  const _$RecipeStepImpl(
      {required this.id,
      @JsonKey(name: 'recipe_id') required this.recipeId,
      @JsonKey(name: 'step_number') required this.stepNumber,
      required this.instruction,
      @JsonKey(name: 'timer_seconds') this.timerSeconds});

  factory _$RecipeStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeStepImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'recipe_id')
  final String recipeId;
  @override
  @JsonKey(name: 'step_number')
  final int stepNumber;
  @override
  final String instruction;
  @override
  @JsonKey(name: 'timer_seconds')
  final int? timerSeconds;

  @override
  String toString() {
    return 'RecipeStep(id: $id, recipeId: $recipeId, stepNumber: $stepNumber, instruction: $instruction, timerSeconds: $timerSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeStepImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.recipeId, recipeId) ||
                other.recipeId == recipeId) &&
            (identical(other.stepNumber, stepNumber) ||
                other.stepNumber == stepNumber) &&
            (identical(other.instruction, instruction) ||
                other.instruction == instruction) &&
            (identical(other.timerSeconds, timerSeconds) ||
                other.timerSeconds == timerSeconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, recipeId, stepNumber, instruction, timerSeconds);

  /// Create a copy of RecipeStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeStepImplCopyWith<_$RecipeStepImpl> get copyWith =>
      __$$RecipeStepImplCopyWithImpl<_$RecipeStepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeStepImplToJson(
      this,
    );
  }
}

abstract class _RecipeStep implements RecipeStep {
  const factory _RecipeStep(
          {required final String id,
          @JsonKey(name: 'recipe_id') required final String recipeId,
          @JsonKey(name: 'step_number') required final int stepNumber,
          required final String instruction,
          @JsonKey(name: 'timer_seconds') final int? timerSeconds}) =
      _$RecipeStepImpl;

  factory _RecipeStep.fromJson(Map<String, dynamic> json) =
      _$RecipeStepImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'recipe_id')
  String get recipeId;
  @override
  @JsonKey(name: 'step_number')
  int get stepNumber;
  @override
  String get instruction;
  @override
  @JsonKey(name: 'timer_seconds')
  int? get timerSeconds;

  /// Create a copy of RecipeStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeStepImplCopyWith<_$RecipeStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
