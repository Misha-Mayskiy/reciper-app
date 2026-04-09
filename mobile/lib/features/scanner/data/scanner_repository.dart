import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/api_client.dart';
import '../domain/task_response.dart';

part 'scanner_repository.g.dart';

class ScannerRepository {
  final Dio dio;

  ScannerRepository(this.dio);

  Future<String> uploadImage(File image) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path),
    });

    try {
      final response = await dio.post('/fridge/scan', data: formData);
      return response.data['task_id'];
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<TaskResponse> checkTaskStatus(String taskId) async {
    try {
      final response = await dio.get('/tasks/$taskId');
      final data = response.data;
      if (data != null && data['result'] != null) {
        data['ingredients'] = data['result']['ingredients'];
        data['recipes'] = data['result']['recipes'];
      }
      return TaskResponse.fromJson(data);
    } catch (e) {
      throw Exception('Failed to check task status: $e');
    }
  }
}

@riverpod
ScannerRepository scannerRepository(ScannerRepositoryRef ref) {
  final dio = ref.read(apiClientProvider);
  return ScannerRepository(dio);
}
