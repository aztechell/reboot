import 'dart:io';
import 'dart:typed_data';

import 'download_service.dart';

class PlatformDownloadService implements DownloadService {
  @override
  Future<DownloadResult> save(Uint8List bytes, {String filename = 'ai-style.jpg'}) async {
    try {
      final dir = await Directory.systemTemp.createTemp('ai_style_');
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      return DownloadResult(success: true, message: 'Сохранено: ${file.path}');
    } catch (e) {
      return DownloadResult(success: false, message: 'Ошибка сохранения: $e');
    }
  }
}
