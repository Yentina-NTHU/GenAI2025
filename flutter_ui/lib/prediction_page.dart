import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'prediction_result_page.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  double _progress = 0.0;
  String _status = '正在載入資料...';
  final _random = Random();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPrediction();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPrediction() {
    const totalSteps = 100;
    int currentStep = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (currentStep >= totalSteps) {
        timer.cancel();
        setState(() {
          _status = '分析完成！';
          _progress = 1.0;
        });

        // 延遲一下後跳轉到結果頁面
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const PredictionResultPage(),
              ),
            );
          }
        });
        return;
      }

      setState(() {
        // 隨機增加進度
        currentStep += 1 + _random.nextInt(3);
        _progress = min(currentStep / totalSteps, 1.0);

        // 根據進度更新狀態訊息
        if (_progress < 0.3) {
          _status = '正在分析交易模式...';
        } else if (_progress < 0.6) {
          _status = '比對可疑行為特徵...';
        } else if (_progress < 0.9) {
          _status = '計算風險指數...';
        } else {
          _status = '產生分析報告...';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('警示戶分析'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 32),
              Text(
                _status,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
