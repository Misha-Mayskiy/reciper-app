import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../main.dart'; // fallback
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/scanner/presentation/scanner_screen.dart';
import '../../features/scanner/presentation/processing_screen.dart';
import '../../features/recipes/presentation/recipe_selection_screen.dart';
import '../../features/recipes/presentation/cooking_mode_screen.dart';
import '../../core/domain/models/recipe.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/processing',
        name: 'processing',
        builder: (context, state) {
          final taskId = state.uri.queryParameters['taskId'] ?? '';
          return ProcessingScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/recipes',
        name: 'recipes',
        builder: (context, state) {
          final recipes = state.extra as List<Recipe>? ?? [];
          return RecipeSelectionScreen(recipes: recipes);
        },
      ),
      GoRoute(
        path: '/cooking',
        name: 'cooking',
        builder: (context, state) {
          final recipe = state.extra as Recipe; // Assumes it always passed
          return CookingModeScreen(recipe: recipe);
        },
      ),
    ],
  );
}

// TODO: Move PlaceholderScreen to main.dart or remove after screens are ready
