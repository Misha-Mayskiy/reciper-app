import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/domain/models/recipe.dart';
import '../../../core/domain/models/recipe_step.dart';
import '../../../core/theme/app_theme.dart';
import '../data/recipes_repository.dart';

class CookingModeScreen extends ConsumerStatefulWidget {
  final Recipe recipe;
  const CookingModeScreen({super.key, required this.recipe});

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen> {
  final PageController _pageController = PageController();
  int _currentStepIndex = 0;
  bool _isConsuming = false;

  List<RecipeStep> get steps {
    if (widget.recipe.steps.isNotEmpty) {
      return widget.recipe.steps;
    }
    return [
      RecipeStep(id: '1', recipeId: widget.recipe.id, stepNumber: 1,
        instruction: 'Подготовьте все ингредиенты для блюда «${widget.recipe.title}».', timerSeconds: null),
      RecipeStep(id: '2', recipeId: widget.recipe.id, stepNumber: 2,
        instruction: 'Следуйте рецепту и приготовьте блюдо.', timerSeconds: null),
      RecipeStep(id: '3', recipeId: widget.recipe.id, stepNumber: 3,
        instruction: 'Блюдо готово! Приятного аппетита!', timerSeconds: null),
    ];
  }

  void _finishCooking() async {
    HapticFeedback.heavyImpact();
    setState(() => _isConsuming = true);
    try {
      await ref.read(recipesRepositoryProvider).consumeRecipe(widget.recipe.id);
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) setState(() => _isConsuming = false);
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? AppTheme.darkSurfaceCard : AppTheme.lightSurfaceCard,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 40, color: Colors.black),
              ),
              const SizedBox(height: 24),
              Text(
                'Приятного аппетита! 🎉',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Данные о питании сохранены\nв вашу статистику',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: Theme.of(ctx).textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go('/');
                  },
                  child: const Text('К статистике'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/recipes'),
        ),
        title: Text(
          widget.recipe.title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentStepIndex + 1} / ${steps.length}',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ((_currentStepIndex + 1) / steps.length),
                backgroundColor: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                minHeight: 4,
              ),
            ),
          ),

          // Steps
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: steps.length,
              onPageChanged: (idx) {
                HapticFeedback.selectionClick();
                setState(() => _currentStepIndex = idx);
              },
              itemBuilder: (context, index) {
                final step = steps[index];
                final isLast = index == steps.length - 1;

                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: const BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Text(
                          'Шаг ${step.stepNumber}',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Расширяемая скроллируемая область для текста и таймера
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: GlassmorphismDecoration.card(opacity: 0.06, isDark: isDark),
                                child: Text(
                                  step.instruction,
                                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 32),
                              if (step.timerSeconds != null)
                                _GradientTimer(seconds: step.timerSeconds!),
                            ],
                          ),
                        ),
                      ),
                      
                      // Кнопка всегда внизу
                      if (isLast) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _isConsuming ? null : _finishCooking,
                              icon: _isConsuming
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                  : const Icon(Icons.celebration_rounded, size: 22),
                              label: Text('Приятного аппетита!', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, elevation: 0),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom nav
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentStepIndex > 0
                        ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Назад'),
                  ),
                  Row(
                    children: List.generate(steps.length, (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: index == _currentStepIndex ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: index == _currentStepIndex
                            ? AppTheme.primary
                            : (isDark ? Colors.white.withOpacity(0.15) : Colors.grey.withOpacity(0.2)),
                      ),
                    )),
                  ),
                  TextButton(
                    onPressed: _currentStepIndex < steps.length - 1
                        ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                        : null,
                    child: Row(
                      children: const [
                        Text('Далее'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular timer with gradient
class _GradientTimer extends StatefulWidget {
  final int seconds;
  const _GradientTimer({required this.seconds});

  @override
  State<_GradientTimer> createState() => _GradientTimerState();
}

class _GradientTimerState extends State<_GradientTimer> {
  late int _timeLeft;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.seconds;
  }

  void _toggleTimer() {
    HapticFeedback.mediumImpact();
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          setState(() => _timeLeft--);
        } else {
          timer.cancel();
          setState(() => _isRunning = false);
          HapticFeedback.heavyImpact();
        }
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() { _timeLeft = widget.seconds; _isRunning = false; });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_timeLeft / 60).floor();
    final seconds = _timeLeft % 60;
    final progress = _timeLeft / widget.seconds;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        GestureDetector(
          onTap: _toggleTimer,
          onLongPress: _resetTimer,
          child: SizedBox(
            width: 160, height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150, height: 150,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.15)),
                  ),
                ),
                SizedBox(
                  width: 150, height: 150,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _timeLeft == 0 ? AppTheme.primary : AppTheme.accentLight,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _timeLeft == 0 ? Icons.check_circle_rounded
                            : _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        key: ValueKey(_isRunning),
                        size: 28,
                        color: _timeLeft == 0 ? AppTheme.primary : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _timeLeft == 0 ? 'Готово!'
              : _isRunning ? 'Нажмите для паузы' : 'Нажмите для запуска',
          style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
        ),
      ],
    );
  }
}