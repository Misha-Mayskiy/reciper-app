import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../data/profile_repository.dart';

/// Провайдер для переключения периода (week / month)
final periodProvider = StateProvider<String>((ref) => 'week');

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(periodProvider);
    final statsAsync = ref.watch(profileStatsProvider('user_1', period));

    return Scaffold(
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) => _buildContent(context, ref, stats, period),
          loading: () => _buildLoadingState(),
          error: (err, stack) => _buildErrorState(context, ref, err),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: 16),
          Text('Загрузка данных...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            Text('Не удалось загрузить данные', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Проверьте подключение к серверу', style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(profileStatsProvider('user_1', ref.read(periodProvider))),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List stats, String period) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasMacroData = stats.isNotEmpty &&
        (stats.last.totalProtein > 0 || stats.last.totalFat > 0 || stats.last.totalCarbs > 0);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ──── Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.black, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Профиль', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
                      Text('Ваш прогресс питания', style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.settings_rounded),
                  tooltip: 'Настройки',
                ),
              ],
            ),
          ),
        ),

        // ──── Макронутриенты сегодня
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text('Сегодня', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ),

        SliverToBoxAdapter(
          child: hasMacroData ? _buildMacroSection(context, stats, isDark) : _buildEmptyMacroState(context, isDark),
        ),

        // ──── Переключатель периода
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Калории', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _PeriodChip(
                        label: 'Неделя',
                        isSelected: period == 'week',
                        onTap: () => ref.read(periodProvider.notifier).state = 'week',
                      ),
                      _PeriodChip(
                        label: 'Месяц',
                        isSelected: period == 'month',
                        onTap: () => ref.read(periodProvider.notifier).state = 'month',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ──── График
        SliverToBoxAdapter(
          child: _buildChart(context, stats, period, isDark),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildEmptyMacroState(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: GlassmorphismDecoration.card(isDark: isDark),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.eco_rounded, size: 36, color: AppTheme.primary),
          ),
          const SizedBox(height: 14),
          Text('Вы ещё ничего не ели сегодня', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Сфотографируйте холодильник и приготовьте что-нибудь!', textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  Widget _buildMacroSection(BuildContext context, List stats, bool isDark) {
    final todayStat = stats.last;
    final protein = todayStat.totalProtein.toDouble();
    final fat = todayStat.totalFat.toDouble();
    final carbs = todayStat.totalCarbs.toDouble();
    final calories = todayStat.totalCalories;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: GlassmorphismDecoration.card(isDark: isDark),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 45,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(color: AppTheme.proteinColor, value: protein, title: '', radius: 24),
                      PieChartSectionData(color: AppTheme.fatColor, value: fat, title: '', radius: 24),
                      PieChartSectionData(color: AppTheme.carbsColor, value: carbs, title: '', radius: 24),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$calories', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800)),
                    Text('ккал', style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MacroChip('Белки', '${protein.toInt()}г', AppTheme.proteinColor),
              _MacroChip('Жиры', '${fat.toInt()}г', AppTheme.fatColor),
              _MacroChip('Углеводы', '${carbs.toInt()}г', AppTheme.carbsColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _MacroChip(String label, String value, Color color) {
    return Column(
      children: [
        Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)])),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
      ],
    );
  }

  Widget _buildChart(BuildContext context, List stats, String period, bool isDark) {
    if (stats.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 200,
        alignment: Alignment.center,
        child: Text('Нет данных за этот период', style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodySmall?.color)),
      );
    }

    final spots = stats.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.totalCalories.toDouble())).toList();
    const targetCalories = 2200.0;
    final maxY = [spots.map((s) => s.y).reduce(max), targetCalories].reduce(max) + 400;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
      decoration: GlassmorphismDecoration.card(isDark: isDark),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 500,
              getDrawingHorizontalLine: (value) => FlLine(
                color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.withOpacity(0.1),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: 500,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}',
                    style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: period == 'month' ? 5 : 1,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= stats.length) return const Text('');
                    final dateStr = stats[idx].date;
                    // Показываем дату кратко
                    if (period == 'month') {
                      final parts = dateStr.split('-');
                      return Text('${parts[2]}.${parts[1]}',
                        style: GoogleFonts.inter(fontSize: 9, color: Theme.of(context).textTheme.bodySmall?.color));
                    } else {
                      final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                      // Используем day of week от даты
                      try {
                        final d = DateTime.parse(dateStr);
                        return Text(days[d.weekday - 1],
                          style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color));
                      } catch (_) {
                        return Text('$idx', style: GoogleFonts.inter(fontSize: 10));
                      }
                    }
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: targetCalories,
                  color: AppTheme.accent.withOpacity(0.5),
                  strokeWidth: 2,
                  dashArray: [8, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: GoogleFonts.inter(fontSize: 10, color: AppTheme.accent, fontWeight: FontWeight.w600),
                    labelResolver: (_) => 'Цель',
                  ),
                ),
              ],
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.25,
                color: AppTheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: period == 'week',
                  getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                    radius: 3,
                    color: AppTheme.primary,
                    strokeWidth: 2,
                    strokeColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [AppTheme.primary.withOpacity(0.25), AppTheme.primary.withOpacity(0.0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                  '${s.y.toInt()} ккал',
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                )).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}
