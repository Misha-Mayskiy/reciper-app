import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/scanner/presentation/scanner_screen.dart';
import '../../features/scanner/presentation/processing_screen.dart';
import '../../features/recipes/presentation/recipe_selection_screen.dart';
import '../../features/recipes/presentation/cooking_mode_screen.dart';
import '../../core/domain/models/recipe.dart';
import '../theme/app_theme.dart';

part 'app_router.g.dart';

/// Главная обёртка с Bottom Navigation Bar
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/scanner');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics_rounded),
              label: 'Прогресс',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner_outlined),
              activeIcon: Icon(Icons.document_scanner_rounded),
              label: 'Сканер',
            ),
          ],
        ),
      ),
    );
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
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
        ],
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
          final recipe = state.extra as Recipe;
          return CookingModeScreen(recipe: recipe);
        },
      ),
    ],
  );
}
