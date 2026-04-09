// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskResponseImpl _$$TaskResponseImplFromJson(Map<String, dynamic> json) =>
    _$TaskResponseImpl(
      status: json['status'] as String,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      recipes: (json['recipes'] as List<dynamic>?)
          ?.map((e) => Recipe.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TaskResponseImplToJson(_$TaskResponseImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'ingredients': instance.ingredients,
      'recipes': instance.recipes,
    };
