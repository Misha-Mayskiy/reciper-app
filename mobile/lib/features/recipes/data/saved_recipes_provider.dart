import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/models/recipe.dart';

/// Провайдер для хранения последних рецептов между сканами.
/// Рецепты сохраняются даже если пользователь не обновляет холодильник.
final savedRecipesProvider = StateNotifierProvider<SavedRecipesNotifier, List<Recipe>>((ref) {
  return SavedRecipesNotifier();
});

class SavedRecipesNotifier extends StateNotifier<List<Recipe>> {
  SavedRecipesNotifier() : super([]);

  void setRecipes(List<Recipe> recipes) {
    state = recipes;
  }

  void addRecipes(List<Recipe> recipes) {
    state = [...state, ...recipes];
  }

  void clear() {
    state = [];
  }
}
