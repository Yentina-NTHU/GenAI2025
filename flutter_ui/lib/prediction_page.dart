import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'prediction_result_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    Future.microtask(() => _startPrediction());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startPrediction() async {
    const url =
        'http://ec2-54-191-69-17.us-west-2.compute.amazonaws.com:5000/inference';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print('成功: ${response.body}');
        final data = jsonDecode(response.body); // 👈 把 body 轉成 Dart 物件
        print('拿到的資料是: $data');
      } else {
        print('失敗: 狀態碼 ${response.statusCode}');
      }
    } catch (e) {
      print('錯誤: $e');
    }

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
                builder: (context) => PredictionResultPage(),
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
