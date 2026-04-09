import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    @JsonKey(name: 'daily_calories_target') required int dailyCaloriesTarget,
    @JsonKey(name: 'target_protein') required int targetProtein,
    @JsonKey(name: 'target_fat') required int targetFat,
    @JsonKey(name: 'target_carbs') required int targetCarbs,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
