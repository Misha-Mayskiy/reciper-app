import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/scanner_repository.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final String taskId;
  const ProcessingScreen({super.key, required this.taskId});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    // Poll every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final repository = ref.read(scannerRepositoryProvider);
      try {
        final resp = await repository.checkTaskStatus(widget.taskId);
        if (resp.status == 'done') {
          timer.cancel();
          if (!mounted) return;
          // pass recipes into state or routing extra parameter.
          // Due to GoRouter limitations we can pass complex objects via go/push extra.
          context.go('/recipes', extra: resp.recipes);
        } else if (resp.status == 'error') {
          timer.cancel();
          if (!mounted) return;
          context.go('/scanner');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка сервера ИИ')));
        }
      } catch (e) {
        timer.cancel();
        if (!mounted) return;
        context.go('/scanner');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dummy network lottie or use default loading if lottie is not loaded
            const CircularProgressIndicator(color: Colors.greenAccent),
            const SizedBox(height: 32),
            const Text(
              'Нейросеть изучает холодильник...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
