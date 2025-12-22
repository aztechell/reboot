import 'dart:typed_data';

abstract class DownloadService {
  Future<DownloadResult> save(Uint8List bytes, {String filename = 'ai-style.jpg'});
}

class DownloadResult {
  const DownloadResult({required this.success, this.message});
  final bool success;
  final String? message;
}
