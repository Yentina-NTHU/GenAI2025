import 'package:flutter/material.dart';
import 's3_uploader.dart';
import 'detection_uploader.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scam Catch Bot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(
              child: Text(
                '選擇功能',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // 窄螢幕：上下布局
                      return SizedBox(
                        width: 400, // 限制最大寬度
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 240, // 固定高度
                              child: _buildFeatureCard(
                                context,
                                title: '模型訓練',
                                description: '上傳訓練資料以優化模型\n提升警示戶辨識的準確度',
                                gradientColors: const [
                                  Color(0xFF00E5DE),
                                  Color(0xFF00B4B0),
                                  Color(0xFF008380),
                                ],
                                icon: Icons.model_training,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const S3Uploader(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 240, // 固定高度
                              child: _buildFeatureCard(
                                context,
                                title: '警示戶辨識',
                                description: '上傳最新交易資料\n即時偵測潛在的警示戶',
                                gradientColors: const [
                                  Color(0xFFE500E5),
                                  Color(0xFFB000B4),
                                  Color(0xFF800080),
                                ],
                                icon: Icons.security,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DetectionUploader(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // 寬螢幕：左右布局
                      return SizedBox(
                        width: 900, // 限制最大寬度
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildFeatureCard(
                                context,
                                title: '模型訓練',
                                description: '上傳訓練資料以優化模型\n提升警示戶辨識的準確度',
                                gradientColors: const [
                                  Color(0xFF00E5DE),
                                  Color(0xFF00B4B0),
                                  Color(0xFF008380),
                                ],
                                icon: Icons.model_training,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const S3Uploader(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFeatureCard(
                                context,
                                title: '警示戶辨識',
                                description: '上傳最新交易資料\n即時偵測潛在的警示戶',
                                gradientColors: const [
                                  Color(0xFFE500E5),
                                  Color(0xFFB000B4),
                                  Color(0xFF800080),
                                ],
                                icon: Icons.security,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DetectionUploader(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required List<Color> gradientColors,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: -5,
                offset: const Offset(0, -5),
              ),
              BoxShadow(
                color: gradientColors[2].withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: -5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
