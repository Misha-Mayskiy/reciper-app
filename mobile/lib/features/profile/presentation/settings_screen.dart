import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';

/// Экран настроек: переключение темы, информация о приложении.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Настройки', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ──── Секция: Внешний вид
          _SectionHeader(title: 'Внешний вид'),
          const SizedBox(height: 8),
          Container(
            decoration: GlassmorphismDecoration.card(isDark: isDark, borderRadius: 16),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  iconColor: const Color(0xFF7C4DFF),
                  title: 'Тёмная тема',
                  subtitle: isDark ? 'Включена' : 'Выключена',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => themeNotifier.toggle(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ──── Секция: Профиль
          _SectionHeader(title: 'Профиль'),
          const SizedBox(height: 8),
          Container(
            decoration: GlassmorphismDecoration.card(isDark: isDark, borderRadius: 16),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.person_rounded,
                  iconColor: AppTheme.primary,
                  title: 'Имя',
                  subtitle: 'Дефолтный пользователь',
                  onTap: () {},
                ),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                _SettingsTile(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppTheme.caloriesColor,
                  title: 'Цель калорий',
                  subtitle: '2200 ккал / день',
                  onTap: () {},
                ),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                _SettingsTile(
                  icon: Icons.fitness_center_rounded,
                  iconColor: AppTheme.proteinColor,
                  title: 'Цель белков',
                  subtitle: '120 г / день',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ──── Секция: О приложении
          _SectionHeader(title: 'О приложении'),
          const SizedBox(height: 8),
          Container(
            decoration: GlassmorphismDecoration.card(isDark: isDark, borderRadius: 16),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppTheme.accent,
                  title: 'Версия',
                  subtitle: '1.0.0',
                ),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                _SettingsTile(
                  icon: Icons.code_rounded,
                  iconColor: AppTheme.fatColor,
                  title: 'Технологии',
                  subtitle: 'Flutter + FastAPI + AI',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodySmall?.color,
        letterSpacing: 0.5,
      ),
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
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
