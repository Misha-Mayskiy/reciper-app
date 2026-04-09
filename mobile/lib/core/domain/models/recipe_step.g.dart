// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeStepImpl _$$RecipeStepImplFromJson(Map<String, dynamic> json) =>
    _$RecipeStepImpl(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      stepNumber: (json['step_number'] as num).toInt(),
      instruction: json['instruction'] as String,
      timerSeconds: (json['timer_seconds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$RecipeStepImplToJson(_$RecipeStepImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipe_id': instance.recipeId,
      'step_number': instance.stepNumber,
      'instruction': instance.instruction,
      'timer_seconds': instance.timerSeconds,
    };
