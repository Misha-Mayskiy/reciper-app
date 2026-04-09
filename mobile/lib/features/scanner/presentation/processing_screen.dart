import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../data/scanner_repository.dart';
import '../../recipes/data/saved_recipes_provider.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final String taskId;
  const ProcessingScreen({super.key, required this.taskId});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen>
    with TickerProviderStateMixin {
  Timer? _pollingTimer;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  int _dotCount = 0;
  Timer? _dotsTimer;

  final List<String> _funMessages = [
    'Нейросеть изучает холодильник',
    'Анализируем продукты',
    'Подбираем лучшие рецепты',
    'Считаем калории',
    'Скоро будет готово',
  ];
  int _messageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _dotsTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (mounted) setState(() => _dotCount = (_dotCount + 1) % 4);
    });

    _messageTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => _messageIndex = (_messageIndex + 1) % _funMessages.length);
    });

    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final repository = ref.read(scannerRepositoryProvider);
      try {
        final resp = await repository.checkTaskStatus(widget.taskId);
        if (resp.status == 'done') {
          timer.cancel();
          if (!mounted) return;
          // Сохраняем рецепты в providerе для вкладки "Блюда"
          final recipes = resp.recipes ?? [];
          ref.read(savedRecipesProvider.notifier).setRecipes(recipes);
          context.go('/recipes');
        } else if (resp.status == 'error') {
          timer.cancel();
          if (!mounted) return;
          context.go('/scanner');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка сервера ИИ')),
          );
        }
      } catch (e) {
        timer.cancel();
        if (!mounted) return;
        context.go('/scanner');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _dotsTimer?.cancel();
    _messageTimer?.cancel();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.primaryGradient.scale(0.1) : null,
          color: isDark ? null : Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ──── Animated AI
              AnimatedBuilder(
                animation: Listenable.merge([_rotationController, _pulseController]),
                builder: (context, child) {
                  final pulse = 1.0 + (_pulseController.value * 0.1);
                  return Transform.scale(
                    scale: pulse,
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: CustomPaint(
                        painter: _AIPainter(
                          rotation: _rotationController.value,
                          color: AppTheme.primary,
                        ),
                        child: const Center(
                          child: Icon(Icons.auto_awesome_rounded, size: 48, color: AppTheme.primary),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  '${_funMessages[_messageIndex]}${'.' * _dotCount}',
                  key: ValueKey('$_messageIndex-$_dotCount'),
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Это может занять несколько секунд',
                style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    backgroundColor: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AI orbiting animation painter
class _AIPainter extends CustomPainter {
  final double rotation;
  final Color color;

  _AIPainter({required this.rotation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final outerPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 65, outerPaint);

    final innerPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 45, innerPaint);

    final dotPaint = Paint()..color = color;
    for (int i = 0; i < 3; i++) {
      final angle = rotation * 2 * pi + (i * 2 * pi / 3);
      final x = center.dx + 65 * cos(angle);
      final y = center.dy + 65 * sin(angle);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    for (int i = 0; i < 2; i++) {
      final angle = -rotation * 2 * pi + (i * pi);
      final x = center.dx + 45 * cos(angle);
      final y = center.dy + 45 * sin(angle);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = color.withOpacity(0.6));
    }

    final glowPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, 30, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _AIPainter oldDelegate) => oldDelegate.rotation != rotation;
}
