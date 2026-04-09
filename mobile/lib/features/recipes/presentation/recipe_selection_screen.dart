import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/domain/models/recipe.dart';

class RecipeSelectionScreen extends ConsumerWidget {
  final List<Recipe> recipes;

  const RecipeSelectionScreen({super.key, required this.recipes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (recipes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Рецепты')),
        body: const Center(child: Text('Ничего не найдено.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Выберите блюдо')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (recipe.imageUrl != null)
                  Image.network(
                    recipe.imageUrl!,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallbackImage(),
                  )
                else
                  _buildFallbackImage(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(recipe.description),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        children: [
                          _buildStatItem(Icons.local_fire_department, '${recipe.calories} ккал', Colors.orangeAccent),
                          _buildStatItem(Icons.fitness_center, '${recipe.protein}г бел', Colors.redAccent),
                          _buildStatItem(Icons.water_drop, '${recipe.fat}г жир', Colors.yellowAccent),
                          _buildStatItem(Icons.eco, '${recipe.carbs}г угл', Colors.greenAccent),
                          _buildStatItem(Icons.timer, '${recipe.prepTimeMinutes} мин', Colors.lightBlueAccent),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/cooking', extra: recipe),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                          child: const Text('Готовить'),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 200,
      color: Colors.grey.shade800,
      child: const Center(child: Icon(Icons.restaurant, size: 64, color: Colors.grey)),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
