import 'package:flutter/material.dart';
import 'package:minio/minio.dart';
import 'dart:io';

class PredictionResultPage extends StatelessWidget {
  PredictionResultPage({super.key});

  // 將 minio 定義為 final
  final Minio minio = Minio(
    endPoint: 'your-s3-endpoint-url.com',
    accessKey: 'your-access-key',
    secretKey: 'your-secret-key',
    useSSL: false, // Set to true if your S3 server uses HTTPS
  );

  Future<File> downloadFromS3(String bucketName, String objectName) async {
    try {
      final response = await minio.getObject(bucketName, objectName);
      final file = File('path_to_save_downloaded_file'); // 替換為您希望保存的文件路徑。

      await response.pipe(file.openWrite());
      return file;
    } catch (e) {
      print('Error downloading file: $e');
      return Future.error(e); // 返回錯誤
    }
  }

  Future<void> _downloadAndShare(BuildContext context) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('預測結果'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummarySection(context),
              const SizedBox(height: 24),
              _buildModelMetricsSection(),
              const SizedBox(height: 24),
              _buildReportSection(context),
              const SizedBox(height: 24),
              _buildDetailList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '共找出 20 位警示戶',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: () => _downloadAndShare(context),
            icon: const Icon(Icons.download),
            label: const Text('下載 .csv檔'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModelMetricsSection() {
    return const Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, size: 24),
                SizedBox(width: 8),
                Text(
                  '模型評估指標',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assessment, size: 24),
                SizedBox(width: 8),
                Text(
                  '分析報告',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReportItem(
              title: '高風險交易模式',
              content: '發現多筆可疑的小額轉帳，交易頻率異常',
              icon: Icons.warning,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _buildReportItem(
              title: '地理位置分析',
              content: '交易地點分散，且多在非營業時間進行',
              icon: Icons.location_on,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildReportItem(
              title: '關聯帳戶分析',
              content: '與多個已知警示戶有資金往來',
              icon: Icons.account_tree,
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildReportItem(
              title: '風險評估',
              content: '建議加強監控並通知相關單位進行調查',
              icon: Icons.security,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '警示戶清單',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 20,
          itemBuilder: (context, index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '帳戶',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'ACCT${(index + 1).toString().padLeft(4, '0')}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '可能原因',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '頻繁小額轉帳、異常交易模式',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '建議採取行動',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            '加強監控、通知相關單位',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
