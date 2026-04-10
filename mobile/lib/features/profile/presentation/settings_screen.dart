import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../data/profile_repository.dart';

/// Экран настроек с редактируемыми полями.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _userName = 'Дефолтный пользователь';
  int _targetCalories = 2200;
  int _targetProtein = 120;
  int _targetFat = 70;
  int _targetCarbs = 280;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      final statsAsync = ref.read(profileStatsNotifierProvider);
      statsAsync.whenData((data) {
        setState(() {
          _userName = data.userName;
          _targetCalories = data.targetCalories;
          _targetProtein = data.targetProtein;
          _targetFat = data.targetFat;
          _targetCarbs = data.targetCarbs;
          _loaded = true;
        });
      });
    }
  }

  Future<String?> _showEditDialog(String title, String currentValue, {bool isNumber = false}) async {
    final controller = TextEditingController(text: currentValue);
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurfaceCard : AppTheme.lightSurfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
            style: GoogleFonts.inter(fontSize: 18),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.08),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Отмена', style: GoogleFonts.inter(color: Theme.of(ctx).textTheme.bodySmall?.color)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: Text('Настройки', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ──── Внешний вид
          _SectionHeader(title: 'ВНЕШНИЙ ВИД')
              .animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 8),
          Container(
            decoration: GlassmorphismDecoration.card(isDark: isDark, borderRadius: 16),
            child: _SettingsTile(
              icon: Icons.dark_mode_rounded,
              iconColor: const Color(0xFF7C4DFF),
              title: 'Тёмная тема',
              subtitle: isDark ? 'Включена' : 'Выключена',
              trailing: Switch(value: isDark, onChanged: (_) => themeNotifier.toggle()),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 50.ms).slideX(begin: -0.03, end: 0),
          const SizedBox(height: 24),

          // ──── Профиль
          _SectionHeader(title: 'ПРОФИЛЬ')
              .animate().fadeIn(duration: 300.ms, delay: 100.ms),
          const SizedBox(height: 8),
          Container(
            decoration: GlassmorphismDecoration.card(isDark: isDark, borderRadius: 16),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.person_rounded,
                  iconColor: AppTheme.primary,
                  title: 'Имя',
                  subtitle: _userName,
                  trailing: const Icon(Icons.edit_rounded, size: 18),
                  onTap: () async {
                    final result = await _showEditDialog('Ваше имя', _userName);
                    if (result != null && result.isNotEmpty) {
                      setState(() => _userName = result);
                    }
                  },
                ),
                _divider(context),
                _SettingsTile(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppTheme.caloriesColor,
                  title: 'Цель калорий',
                  subtitle: '$_targetCalories ккал / день',
                  trailing: const Icon(Icons.edit_rounded, size: 18),
                  onTap: () async {
                    final result = await _showEditDialog('Цель калорий (ккал)', '$_targetCalories', isNumber: true);
                    if (result != null && result.isNotEmpty) {
                      setState(() => _targetCalories = int.tryParse(result) ?? _targetCalories);
                    }
                  },
                ),
                _divider(context),
                _SettingsTile(
                  icon: Icons.fitness_center_rounded,
                  iconColor: AppTheme.proteinColor,
                  title: 'Цель белков',
                  subtitle: '$_targetProtein г / день',
                  trailing: const Icon(Icons.edit_rounded, size: 18),
                  onTap: () async {
                    final result = await _showEditDialog('Цель белков (г)', '$_targetProtein', isNumber: true);
                    if (result != null && result.isNotEmpty) {
                      setState(() => _targetProtein = int.tryParse(result) ?? _targetProtein);
                    }
                  },
                ),
                _divider(context),
                _SettingsTile(
                  icon: Icons.water_drop_rounded,
                  iconColor: AppTheme.fatColor,
                  title: 'Цель жиров',
                  subtitle: '$_targetFat г / день',
                  trailing: const Icon(Icons.edit_rounded, size: 18),
                  onTap: () async {
                    final result = await _showEditDialog('Цель жиров (г)', '$_targetFat', isNumber: true);
                    if (result != null && result.isNotEmpty) {
                      setState(() => _targetFat = int.tryParse(result) ?? _targetFat);
                    }
                  },
                ),
                _divider(context),
                _SettingsTile(
                  icon: Icons.eco_rounded,
                  iconColor: AppTheme.carbsColor,
                  title: 'Цель углеводов',
                  subtitle: '$_targetCarbs г / день',
                  trailing: const Icon(Icons.edit_rounded, size: 18),
                  onTap: () async {
                    final result = await _showEditDialog('Цель углеводов (г)', '$_targetCarbs', isNumber: true);
                    if (result != null && result.isNotEmpty) {
                      setState(() => _targetCarbs = int.tryParse(result) ?? _targetCarbs);
                    }
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideX(begin: -0.03, end: 0),
          const SizedBox(height: 24),

          // ──── О приложении
          _SectionHeader(title: 'О ПРИЛОЖЕНИИ')
              .animate().fadeIn(duration: 300.ms, delay: 200.ms),
          const SizedBox(height: 8),
          Container(
            decoration: GlassmorphismDecoration.card(isDark: isDark, borderRadius: 16),
            child: Column(
              children: [
                _SettingsTile(icon: Icons.info_outline_rounded, iconColor: AppTheme.accent, title: 'Версия', subtitle: '1.0.0'),
                _divider(context),
                _SettingsTile(icon: Icons.code_rounded, iconColor: AppTheme.fatColor, title: 'Стек', subtitle: 'Flutter + FastAPI + Ollama AI'),
                _divider(context),
                _SettingsTile(icon: Icons.architecture_rounded, iconColor: AppTheme.proteinColor, title: 'Архитектура', subtitle: 'Clean Architecture + Riverpod'),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideX(begin: -0.03, end: 0),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) =>
      Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color);
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1,
        color: Theme.of(context).textTheme.bodySmall?.color),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon, required this.iconColor,
    required this.title, required this.subtitle,
    this.trailing, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
