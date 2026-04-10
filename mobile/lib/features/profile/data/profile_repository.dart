import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/domain/models/daily_stat.dart';

/// Репозиторий данных профиля
class ProfileRepository {
  final Dio dio;
  ProfileRepository(this.dio);

  Future<Map<String, dynamic>> getRawStats(String userId, {String period = 'week'}) async {
    final response = await dio.get(
      '/users/$userId/stats',
      queryParameters: {'period': period},
    );
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Failed to load stats');
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    // POST to update user profile
    await dio.post('/users/$userId/profile', data: data);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.read(apiClientProvider);
  return ProfileRepository(dio);
});

/// Кэшируемые данные профиля — НЕ AutoDispose, данные сохраняются при навигации
class ProfileStatsNotifier extends StateNotifier<AsyncValue<ProfileData>> {
  final ProfileRepository _repo;
  String _currentPeriod = 'week';
  final String userId;

  ProfileStatsNotifier(this._repo, this.userId) : super(const AsyncValue.loading()) {
    load();
  }

  String get currentPeriod => _currentPeriod;

  Future<void> load({String? period}) async {
    if (period != null && period != _currentPeriod) {
      _currentPeriod = period;
      // Показываем loading только при смене периода
      state = const AsyncValue.loading();
    } else if (state is AsyncData) {
      // Если данные уже есть и период не менялся — не делаем запрос
      return;
    }

    try {
      final raw = await _repo.getRawStats(userId, period: _currentPeriod);
      state = AsyncValue.data(ProfileData.fromJson(raw, userId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    try {
      final raw = await _repo.getRawStats(userId, period: _currentPeriod);
      state = AsyncValue.data(ProfileData.fromJson(raw, userId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void changePeriod(String period) {
    if (period != _currentPeriod) {
      load(period: period);
    }
  }
}

/// Модель данных профиля
class ProfileData {
  final String userId;
  final String userName;
  final String period;
  final int targetCalories;
  final int targetProtein;
  final int targetFat;
  final int targetCarbs;
  final List<DailyStat> history;
  final DailyStat? todayStat;

  ProfileData({
    required this.userId,
    required this.userName,
    required this.period,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetFat,
    required this.targetCarbs,
    required this.history,
    this.todayStat,
  });

  factory ProfileData.fromJson(Map<String, dynamic> raw, String userId) {
    final today = raw['today'] as Map<String, dynamic>;
    final history = (raw['history'] as List? ?? []).map((json) => DailyStat(
      id: 'hist_${json["date"]}',
      userId: userId,
      date: json['date'] as String? ?? '',
      totalCalories: json['calories'] ?? 0,
      totalProtein: json['protein'] ?? 0,
      totalFat: json['fat'] ?? 0,
      totalCarbs: json['carbs'] ?? 0,
    )).toList();

    final todayDate = DateTime.now().toIso8601String().split('T')[0];
    final todayStat = DailyStat(
      id: 'today', userId: userId, date: todayDate,
      totalCalories: today['calories'] ?? 0,
      totalProtein: today['protein'] ?? 0,
      totalFat: today['fat'] ?? 0,
      totalCarbs: today['carbs'] ?? 0,
    );

    if (!history.any((s) => s.date == todayDate)) {
      history.add(todayStat);
    }

    final target = raw['daily_target'] as Map<String, dynamic>? ?? {};

    return ProfileData(
      userId: userId,
      userName: raw['user_name'] ?? 'Пользователь',
      period: raw['period'] ?? 'week',
      targetCalories: target['calories'] ?? 2200,
      targetProtein: target['protein'] ?? 120,
      targetFat: target['fat'] ?? 70,
      targetCarbs: target['carbs'] ?? 280,
      history: history,
      todayStat: todayStat,
    );
  }
}

/// keepAlive-провайдер — данные кэшируются при навигации
final profileStatsNotifierProvider = StateNotifierProvider<ProfileStatsNotifier, AsyncValue<ProfileData>>((ref) {
  final repo = ref.read(profileRepositoryProvider);
  return ProfileStatsNotifier(repo, 'user_1');
});
