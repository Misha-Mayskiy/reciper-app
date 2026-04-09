import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileStatsProvider('user_1'));

    return Scaffold(
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) => _buildContent(context, stats),
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
          Text('Загрузка данных...', style: TextStyle(color: AppTheme.textSecondary)),
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
            Text(
              'Не удалось загрузить данные',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Проверьте подключение к серверу',
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(profileStatsProvider('user_1')),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List stats) {
    // Для демо: если данных нет — показываем приветственное состояние
    final hasMacroData = stats.isNotEmpty &&
        (stats.last.totalProtein > 0 || stats.last.totalFat > 0 || stats.last.totalCarbs > 0);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ──── Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.restaurant_rounded, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reciper',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Ваш AI-ассистент питания',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ──── Макронутриенты сегодня
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Макронутриенты сегодня',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: hasMacroData
              ? _buildMacroSection(stats)
              : _buildEmptyMacroState(),
        ),

        // ──── Калории за неделю
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'Калории за неделю',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: _buildWeeklyChart(stats),
        ),

        // ──── Быстрые действия
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'Быстрые действия',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: _buildQuickActions(context),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildEmptyMacroState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: GlassmorphismDecoration.card(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, size: 40, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Вы ещё ничего не ели сегодня',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Сфотографируйте холодильник,\nчтобы найти рецепт!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSection(List stats) {
    final todayStat = stats.last;
    final protein = todayStat.totalProtein.toDouble();
    final fat = todayStat.totalFat.toDouble();
    final carbs = todayStat.totalCarbs.toDouble();
    final calories = todayStat.totalCalories;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: GlassmorphismDecoration.card(),
      child: Column(
        children: [
          // Pie chart + калории по центру
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 50,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: AppTheme.proteinColor,
                        value: protein,
                        title: '',
                        radius: 28,
                      ),
                      PieChartSectionData(
                        color: AppTheme.fatColor,
                        value: fat,
                        title: '',
                        radius: 28,
                      ),
                      PieChartSectionData(
                        color: AppTheme.carbsColor,
                        value: carbs,
                        title: '',
                        radius: 28,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$calories',
                      style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'ккал',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Легенда
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroChip('Белки', '${protein.toInt()}г', AppTheme.proteinColor),
              _buildMacroChip('Жиры', '${fat.toInt()}г', AppTheme.fatColor),
              _buildMacroChip('Углеводы', '${carbs.toInt()}г', AppTheme.carbsColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)],
          ),
        ),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildWeeklyChart(List stats) {
    // Prepare data points
    final spots = stats.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.totalCalories.toDouble());
    }).toList();

    // Target line at 2200 kcal
    const targetCalories = 2200.0;

    final maxY = spots.isEmpty
        ? targetCalories + 500
        : [spots.map((s) => s.y).reduce(max), targetCalories].reduce(max) + 300;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(12, 24, 20, 12),
      decoration: GlassmorphismDecoration.card(),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 500,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withOpacity(0.05),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 500,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}',
                    style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                    final idx = value.toInt();
                    return Text(
                      idx < days.length ? days[idx] : '',
                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted),
                    );
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
                curveSmoothness: 0.3,
                color: AppTheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.primary,
                    strokeWidth: 2,
                    strokeColor: AppTheme.background,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.3),
                      AppTheme.primary.withOpacity(0.0),
                    ],
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
                  GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                )).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              icon: Icons.camera_alt_rounded,
              label: 'Сканировать\nхолодильник',
              gradient: AppTheme.primaryGradient,
              onTap: () => context.go('/scanner'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.auto_awesome_rounded,
              label: 'AI генерация\nрецептов',
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
              ),
              onTap: () => context.go('/scanner'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
