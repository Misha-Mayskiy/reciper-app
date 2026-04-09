import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/domain/models/recipe.dart';

part 'recipes_repository.g.dart';

class RecipesRepository {
  final Dio dio;

  RecipesRepository(this.dio);

  Future<void> consumeRecipe(String recipeId) async {
    try {
      await dio.post('/meals/consume', data: {'recipe_id': recipeId});
    } catch (e) {
      throw Exception('Failed to record consumption: $e');
    }
  }
}

@riverpod
RecipesRepository recipesRepository(RecipesRepositoryRef ref) {
  final dio = ref.read(apiClientProvider);
  return RecipesRepository(dio);
}
