import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class PredictionResultPage extends StatelessWidget {
  const PredictionResultPage({super.key});

  Future<void> downloadFile(String fileUrl, String fileName) async {
    final anchor = web.HTMLAnchorElement()
      ..href = fileUrl
      ..download = fileName
      ..style.display = 'none';

    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  }

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
              // const SizedBox(height: 24),
              // _buildModelMetricsSection(),
              const SizedBox(height: 24),
              // _buildReportSection(context),
              const SizedBox(height: 24),
              _buildDetailList(),
              const SizedBox(height: 24),
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
            onPressed: () => downloadFile(
                'https://hackthon0426.s3.us-west-2.amazonaws.com/prediction_result.csv',
                'prediction_result.csv'),
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
    List<String> accounts = ["ACCT11576", "ACCT7590", "ACCT3474", "ACCT31036"];
    List<String> reasons = [
      "雖然帳戶的每日交易筆數並非極高，但出現以下重點高風險組合：金額不匹配入金：一次或數次相對較大筆的進帳，與帳戶既有資產水準明顯不符；資金快速分拆：大額進帳後立即以多筆小額出金形式迅速分散，吻合洗錢「分層」（layering）階段手法；持續餘額抽空循環：每次資金進出後，帳戶餘額幾乎被抽空到極低水位，反覆重演。",
      "這個帳戶在短短十天內雖只有兩筆大額入金（最高 4,651 元），卻隨即分拆成 36 筆微額出金（多為 59–369 元 的「卡片消費」），形成典型的「多筆小額快速洗出」（layering）手法；整體交易量（9,384 元）遠超過其動帳餘額（270 元）與客戶收入水準，顯著違背常理；且所有操作全部集中在凌晨 1:00 和 4:00 等非營業時段，顯示高度程式化或自動化的異常活躍，符合資金洗錢分層階段的重大風險特徵。",
      "此帳戶在僅兩天內產生超過 20 筆交易，遠遠超過正常每日交易頻率，且所有交易全在非營業時間（Risk 2 & 7）；同時出現典型的「大額進 → 馬上同額出」分層手法（Risk 3、4、8），顯示資金被快速洗出；其交易總額（263,200 TWD）更是遠遠超過帳戶僅有的 979 TWD 餘額及客戶收入水準（Risk 5），明顯與該客戶正常理財行為不符，極具洗錢風險。",
      "資金在短時間內被快速匯入再沖出，帳戶餘額多次回落至極低水準。同日相同金額的環回流動，典型的分層或對敲手法，淨流入與淨流出近乎抵銷，卻產生巨額交易量。深夜、凌晨及假日皆有大量交易，明顯異於一般消費行為。大量近似金額的小額入金，頻繁出現相同或極接近的微額存款，疑似自動化程式或批次交易。",
    ];
    List<String> recommend = [
      "向客戶索取完整資金來源與去向說明，並檢視真實交易憑證。針對大額或可疑進出款項設定警示門檻，必要時暫時凍結帳戶。",
      "立即向客戶索取大額進出資金來源、用途與真實交易憑證，確認資金鏈條。對該帳戶設定日交易上限或暫時凍結可疑資金，防止資金持續流動。",
      "立即向客戶索取大額進出資金來源、用途與真實交易憑證，確認資金鏈條。對該帳戶設定日交易上限或暫時凍結可疑資金，防止資金持續流動。",
      "立刻向客戶取得資金來源證明（如轉帳憑證、交易合約、商業發票等）及入金用途說明。設定可疑交易警示條件，對超過一定金額或頻率的交易自動阻擋，必要時暫停帳戶出金功能。"
    ];
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
          itemCount: accounts.length,
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
                            accounts[index],
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
                            reasons[index],
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
                          Text(
                            '建議採取行動',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            recommend[index],
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
