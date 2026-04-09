import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_stat.freezed.dart';
part 'daily_stat.g.dart';

@freezed
class DailyStat with _$DailyStat {
  const factory DailyStat({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String date, // Storing as String YYYY-MM-DD to be simple or DateTime
    @JsonKey(name: 'total_calories') required int totalCalories,
    @JsonKey(name: 'total_protein') required int totalProtein,
    @JsonKey(name: 'total_fat') required int totalFat,
    @JsonKey(name: 'total_carbs') required int totalCarbs,
  }) = _DailyStat;

  factory DailyStat.fromJson(Map<String, dynamic> json) => _$DailyStatFromJson(json);
}
