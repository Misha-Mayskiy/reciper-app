import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now we hardcode a user_id "user_1" as there's no auth
    final statsAsync = ref.watch(profileStatsProvider('user_1'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваш прогресс', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats.isEmpty) {
            return const Center(child: Text('Нет данных'));
          }
          final todayStat = stats.last; // Assuming last is today

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Макронутриенты сегодня', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (todayStat.totalProtein == 0 && todayStat.totalFat == 0 && todayStat.totalCarbs == 0)
                  Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Text(
                      'Вы еще ничего не ели сегодня 🍏', 
                      style: TextStyle(color: Colors.grey, fontSize: 16)
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            color: Colors.redAccent,
                            value: todayStat.totalProtein.toDouble(),
                            title: 'Белки',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: Colors.yellowAccent.shade700,
                            value: todayStat.totalFat.toDouble(),
                            title: 'Жиры',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: Colors.greenAccent,
                            value: todayStat.totalCarbs.toDouble(),
                            title: 'Углеводы',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                const Text('Калории за неделю', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: stats.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.totalCalories.toDouble())).toList(),
                          isCurved: true,
                          color: Colors.greenAccent,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.greenAccent.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scanner'),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Холодильник'),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
      ),
    );
  }
}
