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
        final List data = response.data['stats'] ?? [];
        return data.map((json) => DailyStat.fromJson(json)).toList();
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
