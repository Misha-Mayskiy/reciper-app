import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../data/scanner_repository.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _scanFridge(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image == null) return;
      setState(() => _isLoading = true);
      final repository = ref.read(scannerRepositoryProvider);
      final taskId = await repository.uploadImage(File(image.path));
      if (!mounted) return;
      context.go('/processing?taskId=$taskId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading ? _buildLoading() : _buildContent(context),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: 16),
          Text('Загрузка...'),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ──── Title
          Text('AI Сканер', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800))
              .animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0),
          const SizedBox(height: 4),
          Text('Сфотографируйте холодильник — AI подберёт рецепты',
            style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.4))
              .animate().fadeIn(duration: 400.ms, delay: 50.ms),

          const SizedBox(height: 32),

          // ──── Illustration
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(scale: _pulseAnimation.value, child: child),
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppTheme.primary.withOpacity(0.15), AppTheme.primary.withOpacity(0.05), Colors.transparent,
                  ]),
                ),
                child: Center(
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [AppTheme.primary.withOpacity(0.2), AppTheme.primary.withOpacity(0.08)]),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.kitchen_rounded, size: 52, color: AppTheme.primary),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          const SizedBox(height: 36),

          // ──── Кнопка Камера (большая вертикальная)
          _ActionCard(
            icon: Icons.camera_alt_rounded,
            title: 'Открыть камеру',
            subtitle: 'Сфотографируйте содержимое холодильника',
            gradient: AppTheme.primaryGradient,
            onTap: () => _scanFridge(ImageSource.camera),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 14),

          // ──── Кнопка Галерея
          _ActionCard(
            icon: Icons.photo_library_rounded,
            title: 'Выбрать из галереи',
            subtitle: 'Загрузите готовое фото продуктов',
            gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)]),
            onTap: () => _scanFridge(ImageSource.gallery),
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // ──── Советы
          Container(
            padding: const EdgeInsets.all(16),
            decoration: GlassmorphismDecoration.card(opacity: 0.05, isDark: isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppTheme.fatColor),
                    const SizedBox(width: 8),
                    Text('Советы', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.fatColor)),
                  ],
                ),
                const SizedBox(height: 10),
                _tip('📸', 'Убедитесь, что продукты хорошо видны'),
                _tip('💡', 'Фотографируйте при хорошем освещении'),
                _tip('🥦', 'Откройте дверцу холодильника полностью'),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
        ],
      ),
    );
  }

  Widget _tip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color))),
        ],
      ),
    );
  }
}

/// Большая вертикальная карточка-кнопка
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: gradient.colors.first.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 26, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: Colors.white.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}
