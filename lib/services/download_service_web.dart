import 'dart:convert';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

import 'download_service.dart';

class PlatformDownloadService implements DownloadService {
  @override
  Future<DownloadResult> save(Uint8List bytes, {String filename = 'ai-style.jpg'}) async {
    final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    final anchor = web.HTMLAnchorElement()
      ..href = dataUrl
      ..download = filename;
    anchor.click();
    return const DownloadResult(success: true, message: 'Файл скачан (web).');
  }
}
// note: Uint8Array accessible via web
