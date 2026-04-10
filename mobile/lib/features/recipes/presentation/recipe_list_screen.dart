import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/domain/models/recipe.dart';
import '../../../core/theme/app_theme.dart';
import '../data/saved_recipes_provider.dart';

/// Вкладка "Блюда" — показывает сохранённые рецепты с последнего сканирования.
class RecipeListScreen extends ConsumerWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(savedRecipesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: recipes.isEmpty ? _buildEmptyState(context) : _buildRecipesList(context, recipes, isDark),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant_menu_rounded, size: 56, color: AppTheme.primary),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
            const SizedBox(height: 24),
            Text(
              'Пока нет блюд',
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
            const SizedBox(height: 8),
            Text(
              'Сфотографируйте содержимое холодильника,\nи AI подберёт рецепты для вас',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5),
            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/scanner'),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Сканировать холодильник'),
            ).animate().fadeIn(duration: 400.ms, delay: 350.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipesList(BuildContext context, List<Recipe> recipes, bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              'Ваши блюда',
              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              '${recipes.length} рецептов по вашим продуктам',
              style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final recipe = recipes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _RecipeListCard(recipe: recipe, isDark: isDark)
                      .animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 80 * index)).slideY(begin: 0.08, end: 0),
                );
              },
              childCount: recipes.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecipeListCard extends StatelessWidget {
  final Recipe recipe;
  final bool isDark;

  const _RecipeListCard({required this.recipe, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/recipe-detail', extra: recipe),
      child: Container(
        decoration: GlassmorphismDecoration.card(borderRadius: 20, isDark: isDark),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 110,
              height: 120,
              child: _buildImage(),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.description,
                      style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _MiniChip(icon: Icons.local_fire_department_rounded, text: '${recipe.calories}', color: AppTheme.caloriesColor),
                        const SizedBox(width: 6),
                        _MiniChip(icon: Icons.timer_outlined, text: '${recipe.prepTimeMinutes} мин', color: AppTheme.accent),
                        const SizedBox(width: 6),
                        _MiniChip(icon: Icons.list_alt_rounded, text: '${recipe.steps.length} шагов', color: AppTheme.carbsColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded, color: Theme.of(context).textTheme.bodySmall?.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: recipe.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade700,
          child: Container(color: Colors.grey.shade800),
        ),
        errorWidget: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      color: isDark ? AppTheme.darkSurfaceCard : AppTheme.lightSurfaceLight,
      child: const Center(child: Icon(Icons.restaurant_rounded, size: 32, color: AppTheme.accent)),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MiniChip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
