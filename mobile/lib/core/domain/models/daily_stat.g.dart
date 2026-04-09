// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_stat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyStatImpl _$$DailyStatImplFromJson(Map<String, dynamic> json) =>
    _$DailyStatImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: json['date'] as String,
      totalCalories: (json['total_calories'] as num).toInt(),
      totalProtein: (json['total_protein'] as num).toInt(),
      totalFat: (json['total_fat'] as num).toInt(),
      totalCarbs: (json['total_carbs'] as num).toInt(),
    );

Map<String, dynamic> _$$DailyStatImplToJson(_$DailyStatImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'date': instance.date,
      'total_calories': instance.totalCalories,
      'total_protein': instance.totalProtein,
      'total_fat': instance.totalFat,
      'total_carbs': instance.totalCarbs,
    };
