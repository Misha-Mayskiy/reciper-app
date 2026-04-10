import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../recipes/data/saved_recipes_provider.dart';
import '../../../core/domain/models/recipe.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});
  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  final _goalCtrl = TextEditingController(text: 'Хочу похудеть, но вкусно есть');
  final _allergiesCtrl = TextEditingController(text: 'Нет');
  final _prefCtrl = TextEditingController(text: 'Люблю курицу и творог');
  bool _isLoading = false;

  Future<void> _generatePlan() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.post('/users/user_1/plan', data: {
        'goal': _goalCtrl.text,
        'allergies': _allergiesCtrl.text,
        'preferences': _prefCtrl.text,
      });
      
      final List<dynamic> recipesJson = response.data['recipes'] ?? [];
      final recipes = recipesJson.map((e) => Recipe.fromJson(e)).toList();
      
      ref.read(savedRecipesProvider.notifier).setRecipes(recipes);
      
      if (mounted) {
        context.go('/recipes');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка генерации плана: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _goalCtrl.dispose();
    _allergiesCtrl.dispose();
    _prefCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppTheme.primary),
                const SizedBox(height: 24),
                Text('ИИ составляет ваше меню...', style: GoogleFonts.inter(fontSize: 16)),
              ],
            ),
          ) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Мой план питания', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Расскажите ИИ о своих целях, и мы составим вам меню на день.',
                  style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
                
                const SizedBox(height: 32),
                _buildInputTile('🎯 Ваша цель', 'Например: похудеть, набрать массу', _goalCtrl, isDark),
                const SizedBox(height: 16),
                _buildInputTile('🚫 Аллергии', 'Например: лактоза, орехи', _allergiesCtrl, isDark),
                const SizedBox(height: 16),
                _buildInputTile('❤️ Предпочтения', 'Любимые продукты или ограничения', _prefCtrl, isDark, maxLines: 3),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: ElevatedButton(
                      onPressed: _generatePlan,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                      child: Text('Сгенерировать ИИ-меню', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildInputTile(String title, String hint, TextEditingController ctrl, bool isDark, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.08),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}