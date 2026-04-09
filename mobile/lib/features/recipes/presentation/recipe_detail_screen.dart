import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/domain/models/recipe.dart';
import '../../../core/theme/app_theme.dart';

/// Детальная карточка рецепта.
/// Показывает фото, описание, КБЖУ, сложность, ингредиенты, шаги.
class RecipeDetailScreen extends ConsumerWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  String get _difficulty {
    if (recipe.steps.length <= 3) return 'Легко';
    if (recipe.steps.length <= 5) return 'Средне';
    return 'Сложно';
  }

  Color get _difficultyColor {
    if (recipe.steps.length <= 3) return AppTheme.carbsColor;
    if (recipe.steps.length <= 5) return AppTheme.fatColor;
    return AppTheme.proteinColor;
  }

  IconData get _difficultyIcon {
    if (recipe.steps.length <= 3) return Icons.sentiment_satisfied_rounded;
    if (recipe.steps.length <= 5) return Icons.sentiment_neutral_rounded;
    return Icons.sentiment_dissatisfied_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ──── Hero Image + AppBar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildHeroImage(),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  // Title on image
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Difficulty badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _difficultyColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _difficultyColor.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_difficultyIcon, size: 14, color: _difficultyColor),
                              const SizedBox(width: 4),
                              Text(
                                _difficulty,
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _difficultyColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe.title,
                          style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ──── Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ──── КБЖУ карточки
                  Row(
                    children: [
                      _NutritionCard(label: 'Калории', value: '${recipe.calories}', unit: 'ккал', color: AppTheme.caloriesColor, isDark: isDark),
                      const SizedBox(width: 8),
                      _NutritionCard(label: 'Белки', value: '${recipe.protein}', unit: 'г', color: AppTheme.proteinColor, isDark: isDark),
                      const SizedBox(width: 8),
                      _NutritionCard(label: 'Жиры', value: '${recipe.fat}', unit: 'г', color: AppTheme.fatColor, isDark: isDark),
                      const SizedBox(width: 8),
                      _NutritionCard(label: 'Углеводы', value: '${recipe.carbs}', unit: 'г', color: AppTheme.carbsColor, isDark: isDark),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ──── Время + Шаги
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: GlassmorphismDecoration.card(isDark: isDark, borderRadius: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.timer_rounded, color: AppTheme.accent, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Время', style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                                  Text('${recipe.prepTimeMinutes} мин', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: Theme.of(context).dividerTheme.color),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.list_alt_rounded, color: AppTheme.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Шагов', style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                                    Text('${recipe.steps.length}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ──── Описание
                  Text('Описание', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: GoogleFonts.inter(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // ──── Шаги
                  Text('Этапы приготовления', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...recipe.steps.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final step = entry.value;
                    final isLast = idx == recipe.steps.length - 1;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Вертикальная линия + точка
                          Column(
                            children: [
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${step.stepNumber}',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: AppTheme.primary.withOpacity(0.2),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step.instruction,
                                    style: GoogleFonts.inter(fontSize: 14, height: 1.4),
                                  ),
                                  if (step.timerSeconds != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.timer_outlined, size: 14, color: AppTheme.accent),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${(step.timerSeconds! / 60).ceil()} мин',
                                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: isLast ? 0 : 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      // ──── Кнопка "Начать готовить"
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/cooking', extra: recipe),
                icon: const Icon(Icons.restaurant_rounded, size: 22),
                label: Text('Начать готовить', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: recipe.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade700,
          child: Container(color: Colors.grey.shade800),
        ),
        errorWidget: (_, __, ___) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      color: AppTheme.darkSurfaceCard,
      child: const Center(child: Icon(Icons.restaurant_rounded, size: 64, color: AppTheme.accent)),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool isDark;

  const _NutritionCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.1 : 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            Text(unit, style: GoogleFonts.inter(fontSize: 11, color: color.withOpacity(0.8))),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color)),
          ],
        ),
      ),
    );
  }
}
