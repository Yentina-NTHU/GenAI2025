import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:aws_s3_upload_lite/aws_s3_upload_lite.dart';
import 'prediction_page.dart';

class UploadFileType {
  final String name;
  final IconData icon;
  final String s3Path;
  final String fileType;

  const UploadFileType({
    required this.name,
    required this.icon,
    required this.s3Path,
    required this.fileType,
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
  final List<String?> _uploadErrors = List.filled(3, null);

  final List<UploadFileType> _fileTypes = const [
    UploadFileType(
      name: '帳戶資料',
      icon: Icons.account_balance,
      s3Path: 'detection/account',
      fileType: 'account',
    ),
    UploadFileType(
      name: '用戶資料',
      icon: Icons.person,
      s3Path: 'detection/user',
      fileType: 'user',
    ),
    UploadFileType(
      name: '交易資料',
      icon: Icons.receipt_long,
      s3Path: 'detection/transaction',
      fileType: 'transaction',
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
      _uploadErrors.fillRange(0, _uploadErrors.length, null);
    });

    bool hasError = false;
    try {
      for (var i = 0; i < _selectedFiles.length; i++) {
        if (_selectedFiles[i] == null) continue;

        final file = _selectedFiles[i]!;
        if (file.bytes == null) {
          setState(() {
            _uploadErrors[i] = '檔案讀取失敗';
          });
          continue;
        }

        final fileType = _fileTypes[i];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filename = '${timestamp}_${file.name}';

        try {
          await AwsS3.uploadUint8List(
            accessKey: _accessKey,
            secretKey: _secretKey,
            file: file.bytes!,
            bucket: _bucket,
            region: _region,
            destDir: fileType.s3Path,
            filename: filename,
            metadata: {
              "uploaded_from": "flutter_app",
              "file_type": fileType.fileType,
              "original_name": file.name,
            },
          );

          if (!mounted) return;
          setState(() {
            _uploadProgress[i] = 1.0;
            _uploadErrors[i] = null;
          });
        } catch (e) {
          hasError = true;
          if (!mounted) return;
          setState(() {
            _uploadErrors[i] = '上傳失敗：${e.toString()}';
          });
        }
      }

      if (!hasError) {
        setState(() {
          _isUploading = false;
          for (var i = 0; i < _selectedFiles.length; i++) {
            _selectedFiles[i] = null;
            _uploadProgress[i] = 0.0;
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
                  builder: (context) => const PredictionPage(),
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上傳過程發生錯誤：${e.toString()}')),
      );
    }
  }

  Widget _buildFileSelector(int index) {
    final file = _selectedFiles[index];
    final progress = _uploadProgress[index];
    final error = _uploadErrors[index];
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
                if (_isUploading && error == null) ...[
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
                if (error != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    error,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
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
                        : _startUpload,
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
