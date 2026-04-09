import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/domain/models/recipe.dart';

part 'task_response.freezed.dart';
part 'task_response.g.dart';

@freezed
class TaskResponse with _$TaskResponse {
  const factory TaskResponse({
    required String status,
    List<String>? ingredients,
    List<Recipe>? recipes,
  }) = _TaskResponse;

  factory TaskResponse.fromJson(Map<String, dynamic> json) => _$TaskResponseFromJson(json);
}
