import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/domain/models/recipe.dart';
import '../../../core/theme/app_theme.dart';

class RecipeSelectionScreen extends ConsumerWidget {
  final List<Recipe> recipes;

  const RecipeSelectionScreen({super.key, required this.recipes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (recipes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              Text('Рецепты не найдены', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text('Попробуйте сфотографировать снова', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ──── App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppTheme.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/'),
            ),
            title: Text(
              'Выберите блюдо',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(32),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${recipes.length} рецептов найдено',
                    style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ),
              ),
            ),
          ),

          // ──── Recipe Cards
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recipe = recipes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _RecipeCard(recipe: recipe),
                  );
                },
                childCount: recipes.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/cooking', extra: recipe),
      child: Container(
        decoration: GlassmorphismDecoration.card(borderRadius: 24),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ──── Image
            SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Time badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppTheme.accentLight),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.prepTimeMinutes} мин',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Title on image
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: Text(
                      recipe.title,
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // ──── Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.description,
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // ──── Macro chips
                  Row(
                    children: [
                      _MacroChip(icon: Icons.local_fire_department_rounded, value: '${recipe.calories}', unit: 'ккал', color: AppTheme.caloriesColor),
                      const SizedBox(width: 8),
                      _MacroChip(icon: Icons.fitness_center_rounded, value: '${recipe.protein}г', unit: 'бел', color: AppTheme.proteinColor),
                      const SizedBox(width: 8),
                      _MacroChip(icon: Icons.water_drop_rounded, value: '${recipe.fat}г', unit: 'жир', color: AppTheme.fatColor),
                      const SizedBox(width: 8),
                      _MacroChip(icon: Icons.eco_rounded, value: '${recipe.carbs}г', unit: 'угл', color: AppTheme.carbsColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ──── Cook button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/cooking', extra: recipe),
                        icon: const Icon(Icons.restaurant_rounded, size: 18),
                        label: Text('Готовить', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
          baseColor: AppTheme.surfaceLight,
          highlightColor: AppTheme.surfaceCard,
          child: Container(color: AppTheme.surfaceLight),
        ),
        errorWidget: (_, __, ___) => _buildFallbackImage(),
      );
    }
    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    return Container(
      color: AppTheme.surfaceCard,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_rounded, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 8),
            Text('Нет фото', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final Color color;

  const _MacroChip({
    required this.icon,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            Text(
              unit,
              style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
