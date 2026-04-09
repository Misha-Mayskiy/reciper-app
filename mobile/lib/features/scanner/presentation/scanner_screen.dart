import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../data/scanner_repository.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _scanFridge(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() => _isLoading = true);

      final repository = ref.read(scannerRepositoryProvider);
      final taskId = await repository.uploadImage(File(image.path));
      
      if (!mounted) return;
      // Navigate to processing screen, passing the taskId
      context.go('/processing?taskId=$taskId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сканировании: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поиск рецептов')),
      body: Center(
        child: _isLoading 
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.kitchen, size: 100, color: Colors.greenAccent),
                  const SizedBox(height: 24),
                  const Text('Сфотографируйте содержимое\nхолодильника', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Открыть камеру'),
                    onPressed: () => _scanFridge(ImageSource.camera),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Выбрать из галереи'),
                    onPressed: () => _scanFridge(ImageSource.gallery),
                  ),
                ],
              ),
      ),
    );
  }
}
