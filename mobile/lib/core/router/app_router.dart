import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/scanner/presentation/scanner_screen.dart';
import '../../features/scanner/presentation/processing_screen.dart';
import '../../features/recipes/presentation/recipe_list_screen.dart';
import '../../features/recipes/presentation/recipe_detail_screen.dart';
import '../../features/recipes/presentation/cooking_mode_screen.dart';
import '../../core/domain/models/recipe.dart';

part 'app_router.g.dart';

/// Обёртка с 3-tab Bottom Navigation Bar
class MainShell extends StatefulWidget {
  final Widget child;
  final String location;
  const MainShell({super.key, required this.child, required this.location});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Синхронизируем tab index с текущим маршрутом
    if (widget.location.startsWith('/scanner')) {
      _currentIndex = 0;
    } else if (widget.location.startsWith('/recipes')) {
      _currentIndex = 1;
    } else if (widget.location == '/' || widget.location.startsWith('/profile')) {
      _currentIndex = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Синхронизация при начальной отрисовке
    if (widget.location.startsWith('/scanner')) {
      _currentIndex = 0;
    } else if (widget.location.startsWith('/recipes')) {
      _currentIndex = 1;
    } else if (widget.location == '/' || widget.location.startsWith('/profile')) {
      _currentIndex = 2;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerTheme.color ?? Colors.grey.withOpacity(0.1),
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
                context.go('/scanner');
                break;
              case 1:
                context.go('/recipes');
                break;
              case 2:
                context.go('/');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner_outlined),
              activeIcon: Icon(Icons.document_scanner_rounded),
              label: 'Сканер',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu_rounded),
              label: 'Блюда',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Профиль',
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
    initialLocation: '/scanner',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/scanner',
            name: 'scanner',
            builder: (context, state) => const ScannerScreen(),
          ),
          GoRoute(
            path: '/recipes',
            name: 'recipes',
            builder: (context, state) => const RecipeListScreen(),
          ),
          GoRoute(
            path: '/',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Экраны без Bottom Nav
      GoRoute(
        path: '/processing',
        name: 'processing',
        builder: (context, state) {
          final taskId = state.uri.queryParameters['taskId'] ?? '';
          return ProcessingScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/recipe-detail',
        name: 'recipe-detail',
        builder: (context, state) {
          final recipe = state.extra as Recipe;
          return RecipeDetailScreen(recipe: recipe);
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
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
