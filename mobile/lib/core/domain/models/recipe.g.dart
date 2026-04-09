// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      prepTimeMinutes: (json['prep_time_minutes'] as num).toInt(),
      calories: (json['calories'] as num).toInt(),
      protein: (json['protein'] as num).toInt(),
      fat: (json['fat'] as num).toInt(),
      carbs: (json['carbs'] as num).toInt(),
    );

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'prep_time_minutes': instance.prepTimeMinutes,
      'calories': instance.calories,
      'protein': instance.protein,
      'fat': instance.fat,
      'carbs': instance.carbs,
    };
