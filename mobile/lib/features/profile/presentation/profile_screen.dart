import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileStatsNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: statsAsync.when(
          data: (data) => _ProfileContent(data: data),
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
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            Text('Не удалось загрузить данные', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Проверьте подключение к серверу', style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(profileStatsNotifierProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final ProfileData data;
  const _ProfileContent({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = data.todayStat;
    final hasMacro = today != null && (today.totalProtein > 0 || today.totalFat > 0 || today.totalCarbs > 0);

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => ref.read(profileStatsNotifierProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // ──── Header with name + settings
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        data.userName.isNotEmpty ? data.userName[0].toUpperCase() : 'U',
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.userName, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
                        Text('Цель: ${data.targetCalories} ккал/день', style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: const Icon(Icons.settings_rounded),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0),
          ),

          // ──── Макронутриенты сегодня
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Сегодня', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ),

          SliverToBoxAdapter(
            child: (hasMacro ? _buildMacroChart(context, today!, isDark) : _buildEmptyMacro(context, isDark))
                .animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),
          ),

          // ──── Переключатель периода
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Калории', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                  _PeriodSwitcher(
                    current: data.period,
                    onChanged: (p) => ref.read(profileStatsNotifierProvider.notifier).changePeriod(p),
                    isDark: isDark,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          ),

          // ──── График
          SliverToBoxAdapter(
            child: _buildChart(context, data, isDark)
                .animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.08, end: 0),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildEmptyMacro(BuildContext context, bool isDark) {
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
          Text('Приготовьте что-нибудь вкусное!', textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  Widget _buildMacroChart(BuildContext context, dynamic todayStat, bool isDark) {
    final protein = todayStat.totalProtein.toDouble();
    final fat = todayStat.totalFat.toDouble();
    final carbs = todayStat.totalCarbs.toDouble();
    final calories = todayStat.totalCalories;
    final pct = data.targetCalories > 0 ? (calories / data.targetCalories * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: GlassmorphismDecoration.card(isDark: isDark),
      child: Column(
        children: [
          // Большой PieChart
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 65,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(color: AppTheme.proteinColor, value: protein, title: '', radius: 30, showTitle: false),
                      PieChartSectionData(color: AppTheme.fatColor, value: fat, title: '', radius: 30, showTitle: false),
                      PieChartSectionData(color: AppTheme.carbsColor, value: carbs, title: '', radius: 30, showTitle: false),
                    ],
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 800),
                  swapAnimationCurve: Curves.easeOutCubic,
                ),
                // Центральный текст
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$calories',
                      style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'ккал',
                      style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (pct >= 100 ? AppTheme.primary : AppTheme.accent).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$pct% от цели',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                          color: pct >= 100 ? AppTheme.primary : AppTheme.accent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Легенда
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MacroLegend('Белки', '${protein.toInt()}г', AppTheme.proteinColor, '${data.targetProtein}г'),
              _MacroLegend('Жиры', '${fat.toInt()}г', AppTheme.fatColor, '${data.targetFat}г'),
              _MacroLegend('Углеводы', '${carbs.toInt()}г', AppTheme.carbsColor, '${data.targetCarbs}г'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _MacroLegend(String label, String value, Color color, String target) {
    return Column(
      children: [
        Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)])),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
        Text('/ $target', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildChart(BuildContext context, ProfileData data, bool isDark) {
    final history = data.history;
    if (history.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 200, alignment: Alignment.center,
        child: Text('Нет данных', style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodySmall?.color)),
      );
    }

    final spots = history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.totalCalories.toDouble())).toList();
    final targetCal = data.targetCalories.toDouble();
    final maxY = [spots.map((s) => s.y).reduce(max), targetCal].reduce(max) + 400;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
      decoration: GlassmorphismDecoration.card(isDark: isDark),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minY: 0, maxY: maxY,
            gridData: FlGridData(
              show: true, drawVerticalLine: false, horizontalInterval: 500,
              getDrawingHorizontalLine: (_) => FlLine(
                color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.withOpacity(0.1), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true, reservedSize: 36, interval: 500,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}', style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: data.period == 'month' ? 5 : 1,
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= history.length) return const Text('');
                    try {
                      final d = DateTime.parse(history[idx].date);
                      if (data.period == 'month') {
                        return Text('${d.day}.${d.month}', style: GoogleFonts.inter(fontSize: 9, color: Theme.of(context).textTheme.bodySmall?.color));
                      }
                      final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                      return Text(days[d.weekday - 1], style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color));
                    } catch (_) { return const Text(''); }
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(horizontalLines: [
              HorizontalLine(y: targetCal, color: AppTheme.accent.withOpacity(0.5), strokeWidth: 2, dashArray: [8, 4],
                label: HorizontalLineLabel(show: true, alignment: Alignment.topRight,
                  style: GoogleFonts.inter(fontSize: 10, color: AppTheme.accent, fontWeight: FontWeight.w600),
                  labelResolver: (_) => 'Цель')),
            ]),
            lineBarsData: [
              LineChartBarData(
                spots: spots, isCurved: true, curveSmoothness: 0.25, color: AppTheme.primary, barWidth: 3, isStrokeCapRound: true,
                dotData: FlDotData(
                  show: data.period == 'week',
                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3, color: AppTheme.primary, strokeWidth: 2, strokeColor: Theme.of(context).scaffoldBackgroundColor),
                ),
                belowBarData: BarAreaData(show: true,
                  gradient: LinearGradient(colors: [AppTheme.primary.withOpacity(0.25), AppTheme.primary.withOpacity(0.0)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots.map((s) => LineTooltipItem('${s.y.toInt()} ккал',
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))).toList(),
              ),
            ),
          ),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }
}

class _PeriodSwitcher extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _PeriodSwitcher({required this.current, required this.onChanged, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _chip('Неделя', 'week'),
          _chip('Месяц', 'month'),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = current == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: selected ? Colors.black : (isDark ? Colors.white54 : Colors.black54),
          ),
        ),
      ),
    );
  }
}
