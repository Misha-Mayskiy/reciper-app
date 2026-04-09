import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/domain/models/recipe.dart';
import '../../../core/domain/models/recipe_step.dart';
import '../data/recipes_repository.dart';

class CookingModeScreen extends ConsumerStatefulWidget {
  final Recipe recipe;
  const CookingModeScreen({super.key, required this.recipe});

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen> {
  final PageController _pageController = PageController();
  // We'll mock the recipe steps here since it might come from backend differently,
  // or we assume it's loaded with the recipe. For demo, we just extract.
  // Actually, Recipe model lacks 'steps' property in spec, let's create dynamic mocked steps or assume backend handles it.
  // If Recipe model lacks it, we will just use dummy data for presentation.
  List<RecipeStep> get steps {
    // In real scenario, would be fetched from API or included in Recipe object.
    return [
      RecipeStep(id: '1', recipeId: widget.recipe.id, stepNumber: 1, instruction: 'Подготовьте ингредиенты. Нарежьте овощи.', timerSeconds: null),
      RecipeStep(id: '2', recipeId: widget.recipe.id, stepNumber: 2, instruction: 'Обжарьте на сковороде в течение 3 минут.', timerSeconds: 180),
      RecipeStep(id: '3', recipeId: widget.recipe.id, stepNumber: 3, instruction: 'Добавьте специи и тушите до готовности.', timerSeconds: 300),
      RecipeStep(id: '4', recipeId: widget.recipe.id, stepNumber: 4, instruction: 'Блюдо готово, снимайте с огня.', timerSeconds: null),
    ];
  }

  int _currentStepIndex = 0;
  bool _isConsuming = false;

  void _finishCooking() async {
    setState(() => _isConsuming = true);
    try {
      await ref.read(recipesRepositoryProvider).consumeRecipe(widget.recipe.id);
      if (!mounted) return;
      context.go('/'); // Back to profile stats
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Приятного аппетита! Данные сохранены.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) {
        setState(() => _isConsuming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Режим готовки')),
      body: PageView.builder(
        controller: _pageController,
        itemCount: steps.length,
        onPageChanged: (idx) => setState(() => _currentStepIndex = idx),
        itemBuilder: (context, index) {
          final step = steps[index];
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Шаг ${step.stepNumber}', style: const TextStyle(fontSize: 24, color: Colors.greenAccent)),
                const SizedBox(height: 32),
                Text(
                  step.instruction,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (step.timerSeconds != null)
                  _TimerWidget(seconds: step.timerSeconds!),
                if (index == steps.length - 1) ...[
                  const SizedBox(height: 64),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isConsuming ? null : _finishCooking,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                      child: _isConsuming 
                          ? const CircularProgressIndicator() 
                          : const Text('Приятного аппетита!', style: TextStyle(fontSize: 20)),
                    ),
                  )
                ]
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _currentStepIndex > 0 
                  ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) 
                  : null,
              child: const Text('Назад'),
            ),
            Row(
              children: List.generate(
                steps.length, 
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentStepIndex ? Colors.greenAccent : Colors.grey,
                  ),
                )
              ),
            ),
            TextButton(
              onPressed: _currentStepIndex < steps.length - 1 
                  ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) 
                  : null,
              child: const Text('Вперед'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerWidget extends StatefulWidget {
  final int seconds;
  const _TimerWidget({required this.seconds});

  @override
  State<_TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<_TimerWidget> {
  late int _timeLeft;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.seconds;
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          setState(() => _timeLeft--);
        } else {
          timer.cancel();
          setState(() => _isRunning = false);
        }
      });
    }
    setState(() => _isRunning = !_isRunning);
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
    return GestureDetector(
      onTap: _toggleTimer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 150, height: 150,
            child: CircularProgressIndicator(
              value: _timeLeft / widget.seconds,
              strokeWidth: 8,
              backgroundColor: Colors.grey.shade800,
              color: Colors.greenAccent,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 32),
            ],
          )
        ],
      ),
    );
  }
}
