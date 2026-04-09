// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      dailyCaloriesTarget: (json['daily_calories_target'] as num).toInt(),
      targetProtein: (json['target_protein'] as num).toInt(),
      targetFat: (json['target_fat'] as num).toInt(),
      targetCarbs: (json['target_carbs'] as num).toInt(),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'daily_calories_target': instance.dailyCaloriesTarget,
      'target_protein': instance.targetProtein,
      'target_fat': instance.targetFat,
      'target_carbs': instance.targetCarbs,
    };
