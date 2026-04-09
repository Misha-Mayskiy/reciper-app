import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_step.freezed.dart';
part 'recipe_step.g.dart';

@freezed
class RecipeStep with _$RecipeStep {
  const factory RecipeStep({
    required String id,
    @JsonKey(name: 'recipe_id') required String recipeId,
    @JsonKey(name: 'step_number') required int stepNumber,
    required String instruction,
    @JsonKey(name: 'timer_seconds') int? timerSeconds,
  }) = _RecipeStep;

  factory RecipeStep.fromJson(Map<String, dynamic> json) => _$RecipeStepFromJson(json);
}
