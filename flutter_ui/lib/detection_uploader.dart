import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';
import 'prediction_page.dart';

class FileType {
  final String name;
  final IconData icon;

  const FileType({
    required this.name,
    required this.icon,
  });
}

class DetectionUploader extends StatefulWidget {
  const DetectionUploader({super.key});

  @override
  State<DetectionUploader> createState() => _DetectionUploaderState();
}

class _DetectionUploaderState extends State<DetectionUploader> {
  bool _isUploading = false;
  final List<PlatformFile?> _selectedFiles = List.filled(3, null);
  final List<double> _uploadProgress = List.filled(3, 0.0);
  final _random = Random();

  final List<FileType> _fileTypes = const [
    FileType(
      name: '帳戶資料',
      icon: Icons.account_balance,
    ),
    FileType(
      name: '用戶資料',
      icon: Icons.person,
    ),
    FileType(
      name: '交易資料',
      icon: Icons.receipt_long,
    ),
  ];

  Future<void> _simulateFileUpload(int index, PlatformFile file) async {
    final delay = Duration(milliseconds: 30 + _random.nextInt(70));
    final increment = 0.005 + _random.nextDouble() * 0.015;

    var progress = 0.0;
    while (progress < 1.0) {
      if (!mounted) return;
      progress = min(1.0, progress + increment);
      setState(() {
        _uploadProgress[index] = progress;
      });
      await Future.delayed(delay);
    }
  }

  Future<void> _pickFile(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result == null) return;

      setState(() {
        _selectedFiles[index] = result.files.first;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('選擇檔案失敗：${e.toString()}')),
        );
      }
    }
  }

  Future<void> _simulateUpload() async {
    if (_selectedFiles.every((file) => file == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請至少選擇一個檔案')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      for (var i = 0; i < _uploadProgress.length; i++) {
        _uploadProgress[i] = 0.0;
      }
    });

    try {
      await Future.wait(
        _selectedFiles.asMap().entries.map((entry) async {
          final index = entry.key;
          final file = entry.value;
          if (file == null) return;
          await _simulateFileUpload(index, file);
        }),
      );

      setState(() {
        _isUploading = false;
        for (var i = 0; i < _selectedFiles.length; i++) {
          _selectedFiles[i] = null;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('檔案上傳完成')),
        );

        // 跳轉到預測頁面
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const PredictionPage(),
              ),
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上傳過程發生錯誤：${e.toString()}')),
        );
      }
    }
  }

  Widget _buildFileSelector(int index) {
    final file = _selectedFiles[index];
    final progress = _uploadProgress[index];
    final fileType = _fileTypes[index];

    return ListTile(
      leading: Icon(fileType.icon, size: 28),
      title: Text(fileType.name),
      subtitle: file != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_isUploading) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 2,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            )
          : null,
      trailing: IconButton(
        icon: Icon(file == null ? Icons.upload_file : Icons.change_circle),
        onPressed: _isUploading ? null : () => _pickFile(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('警示戶辨識'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _fileTypes.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => _buildFileSelector(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed:
                    _isUploading || _selectedFiles.every((file) => file == null)
                        ? null
                        : _simulateUpload,
                icon: const Icon(Icons.search),
                label: Text(
                  _isUploading ? '分析中...' : '開始分析',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
