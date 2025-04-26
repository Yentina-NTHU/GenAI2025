import 'package:flutter/material.dart';

class PredictionResultPage extends StatelessWidget {
  const PredictionResultPage({super.key});

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
              _buildSummarySection(),
              const SizedBox(height: 24),
<<<<<<< HEAD
<<<<<<< HEAD
              _buildReportSection(context),
              const SizedBox(height: 24),
              _buildDetailList(),
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
=======
=======
>>>>>>> 8ec415c3b0053254ff218eb4e1ec03df590486a3
              _buildModelMetricsSection(),
              const SizedBox(height: 24),
              _buildReportSection(context),
              const SizedBox(height: 24),
              _buildDetailList(),
<<<<<<< HEAD
>>>>>>> 8ec415c3b0053254ff218eb4e1ec03df590486a3
=======
>>>>>>> 8ec415c3b0053254ff218eb4e1ec03df590486a3
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
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
            onPressed: () {
              // TODO: 實作下載功能
            },
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

<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 8ec415c3b0053254ff218eb4e1ec03df590486a3
  Widget _buildModelMetricsSection() {
    return Card(
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

<<<<<<< HEAD
>>>>>>> 8ec415c3b0053254ff218eb4e1ec03df590486a3
=======
>>>>>>> 8ec415c3b0053254ff218eb4e1ec03df590486a3
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
                    Expanded(
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
