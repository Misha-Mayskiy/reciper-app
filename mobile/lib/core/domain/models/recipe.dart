import 'package:freezed_annotation/freezed_annotation.dart';
import 'recipe_step.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String title,
    required String description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'prep_time_minutes') required int prepTimeMinutes,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
    @Default([]) List<RecipeStep> steps,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}
