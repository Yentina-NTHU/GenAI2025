import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  double _trainingProgress = 0.0;
  String _status = '正在準備訓練資料...';
  final _random = Random();
  Timer? _timer;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _startTraining();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTraining() {
    const totalSteps = 100;
    int currentStep = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (currentStep >= totalSteps) {
        timer.cancel();
        setState(() {
          _status = '訓練完成！';
          _trainingProgress = 1.0;
          _isCompleted = true;
        });
        return;
      }

      setState(() {
        // 隨機增加進度
        currentStep += 1 + _random.nextInt(3);
        _trainingProgress = min(currentStep / totalSteps, 1.0);

        // 根據進度更新狀態訊息
        if (_trainingProgress < 0.3) {
          _status = '正在處理訓練資料...';
        } else if (_trainingProgress < 0.6) {
          _status = '模型訓練中...';
        } else if (_trainingProgress < 0.9) {
          _status = '優化模型參數...';
        } else {
          _status = '即將完成...';
        }
      });
    });
  }

  Widget _buildMetricCard({
    required String title,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('模型訓練'),
        automaticallyImplyLeading: false, // 禁用返回按鈕
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isCompleted) const CircularProgressIndicator(),
              if (_isCompleted)
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 64,
                ),
              const SizedBox(height: 32),
              Text(
                _status,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: _trainingProgress),
              const SizedBox(height: 8),
              Text(
                '${(_trainingProgress * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (_isCompleted) ...[
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'F1 Score',
                        value: 0.92,
                        color: Colors.blue,
                        icon: Icons.score,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Precision',
                        value: 0.89,
                        color: Colors.green,
                        icon: Icons.precision_manufacturing,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Recall',
                        value: 0.95,
                        color: Colors.orange,
                        icon: Icons.replay_circle_filled,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'ROC AUC',
                        value: 0.97,
                        color: Colors.purple,
                        icon: Icons.area_chart,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('回首頁'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
