import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'training_page.dart';

class FileType {
  final String name;
  final IconData icon;
  final String s3Path;

  const FileType({
    required this.name,
    required this.icon,
    required this.s3Path,
  });
}

class S3Uploader extends StatefulWidget {
  const S3Uploader({super.key});

  @override
  State<S3Uploader> createState() => _S3UploaderState();
}

class _S3UploaderState extends State<S3Uploader> {
  bool _isUploading = false;
  final List<PlatformFile?> _selectedFiles = List.filled(4, null);
  final List<double> _uploadProgress = List.filled(4, 0.0);
  final List<FileType> _fileTypes = const [
    FileType(
      name: '帳戶資料',
      icon: Icons.account_balance,
      s3Path: 'account',
    ),
    FileType(
      name: '用戶資料',
      icon: Icons.person,
      s3Path: 'user',
    ),
    FileType(
      name: '交易資料',
      icon: Icons.receipt_long,
      s3Path: 'transaction',
    ),
    FileType(
      name: '警示戶資料',
      icon: Icons.warning,
      s3Path: 'alert',
    ),
  ];

  Future<void> _pickFile(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result == null) return;

      setState(() {
        _selectedFiles[index] = result.files.first;
        _uploadProgress[index] = 0.0;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('選擇檔案失敗：${e.toString()}')),
        );
      }
    }
  }

  Future<void> _startUpload() async {
    if (_selectedFiles.every((file) => file == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請至少選擇一個檔案')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // 模擬上傳進度
      for (var i = 0; i < _selectedFiles.length; i++) {
        if (_selectedFiles[i] == null) continue;

        for (var progress = 0.0; progress <= 1.0; progress += 0.1) {
          if (!mounted) return;
          setState(() {
            _uploadProgress[i] = progress;
          });
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      setState(() {
        _isUploading = false;
        for (var i = 0; i < _selectedFiles.length; i++) {
          _selectedFiles[i] = null;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有檔案上傳完成')),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const TrainingPage(),
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
        title: const Text('訓練資料上傳'),
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
                        : _startUpload,
                icon: const Icon(Icons.upload),
                label: Text(
                  _isUploading ? '上傳中...' : '開始上傳',
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
