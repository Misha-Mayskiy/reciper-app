import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/domain/models/daily_stat.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final Dio dio;

  ProfileRepository(this.dio);

  Future<List<DailyStat>> getStats(String userId) async {
    try {
      final response = await dio.get('/users/$userId/stats');
      if (response.statusCode == 200) {
        final today = response.data['today'];
        final history = response.data['history'] as List? ?? [];
        
        final List<DailyStat> stats = history.map((json) => DailyStat(
          id: 'hist_${json["date"]}',
          userId: userId,
          date: json['date'] as String? ?? '',
          totalCalories: json['calories'] ?? 0,
          totalProtein: json['protein'] ?? 0,
          totalFat: json['fat'] ?? 0,
          totalCarbs: json['carbs'] ?? 0,
        )).toList();

        stats.add(DailyStat(
          id: 'today',
          userId: userId,
          date: DateTime.now().toIso8601String(),
          totalCalories: today['calories'] ?? 0,
          totalProtein: today['protein'] ?? 0,
          totalFat: today['fat'] ?? 0,
          totalCarbs: today['carbs'] ?? 0,
        ));
        
        return stats;
      }
      throw Exception('Failed to load stats');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  final dio = ref.read(apiClientProvider);
  return ProfileRepository(dio);
}

@riverpod
Future<List<DailyStat>> profileStats(ProfileStatsRef ref, String userId) {
  return ref.read(profileRepositoryProvider).getStats(userId);
}
