import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:reboot/services/services.dart';

class AppState extends ChangeNotifier {
  AppState({
    required this.imageService,
    required this.downloadService,
    required this.modes,
    required this.presets,
  }) : selectedMode = modes.first;

  final ImageService imageService;
  final DownloadService downloadService;
  final List<String> modes;
  final Map<String, Map<String, String>> presets;

  String selectedMode;
  String prompt = '';

  final List<Uint8List> _history = [];
  final List<double> _historyAspects = [];
  int _currentIndex = -1;
  double? _originalAspect;

  bool isLoading = false;

  bool get hasImage => _history.isNotEmpty;
  List<Uint8List> get history => List.unmodifiable(_history);
  List<double> get historyAspects => List.unmodifiable(_historyAspects);
  int get currentIndex => _currentIndex;
  Uint8List? get currentImage => (_currentIndex >= 0 && _currentIndex < _history.length) ? _history[_currentIndex] : null;
  double get currentAspect =>
      (_currentIndex >= 0 && _currentIndex < _historyAspects.length) ? _historyAspects[_currentIndex] : (_originalAspect ?? 3 / 4);
  bool get isOriginal => _currentIndex == 0;

  Future<double?> _calculateAspect(Uint8List bytes) async {
    try {
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      if (image.height == 0) return null;
      return image.width / image.height;
    } catch (_) {
      return null;
    }
  }

  Future<void> setOriginal(Uint8List bytes) async {
    final aspect = await _calculateAspect(bytes) ?? 3 / 4;
    _history
      ..clear()
      ..add(bytes);
    _historyAspects
      ..clear()
      ..add(aspect);
    _originalAspect = aspect;
    _currentIndex = 0;
    notifyListeners();
  }

  Future<void> addVariant(Uint8List bytes) async {
    final aspect = await _calculateAspect(bytes) ?? currentAspect;
    _history.add(bytes);
    _historyAspects.add(aspect);
    _currentIndex = _history.length - 1;
    notifyListeners();
  }

  void setMode(String mode) {
    selectedMode = mode;
    notifyListeners();
  }

  void setPrompt(String value) {
    prompt = value;
  }

  void goTo(int index) {
    if (index < 0 || index >= _history.length || index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }

  void goPrev() => goTo(_currentIndex - 1);
  void goNext() => goTo(_currentIndex + 1);

  void removeCurrent() {
    if (!hasImage || _currentIndex < 0 || _currentIndex >= _history.length) return;
    _history.removeAt(_currentIndex);
    _historyAspects.removeAt(_currentIndex);

    if (_history.isEmpty) {
      _currentIndex = -1;
      _originalAspect = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    if (_currentIndex >= _history.length) {
      _currentIndex = _history.length - 1;
    }
    _originalAspect = _historyAspects.isNotEmpty ? _historyAspects.first : null;
    notifyListeners();
  }

  Future<DownloadResult> downloadCurrent() async {
    if (!hasImage || currentImage == null) {
      return const DownloadResult(success: false, message: 'Нет файла для скачивания.');
    }
    return downloadService.save(currentImage!, filename: 'ai-style.jpg');
  }

  Future<ProcessResult> processImage() async {
    if (!hasImage || currentImage == null) {
      return ProcessResult.error('Нет изображения для обработки.');
    }
    if (imageService.apiKey.trim().isEmpty) {
      return ProcessResult.error('API ключ не задан. Передайте STABILITY_API_KEY через --dart-define.');
    }

    isLoading = true;
    notifyListeners();

    final preset = presets[selectedMode];
    final searchPrompt = preset?['search'] ?? 'person';
    final promptText = prompt.isEmpty ? (preset?['prompt'] ?? 'improved portrait') : prompt;
    final negativePrompt = preset?['negative'] ??
        'overprocessed, plastic skin, unrealistic, distorted face, wrong person, extra limbs, artifacts, cartoon';

    try {
      final resultBytes = await imageService.processImage(
        imageBytes: currentImage!,
        searchPrompt: searchPrompt,
        prompt: promptText,
        negativePrompt: negativePrompt,
      );
      await addVariant(resultBytes);
      isLoading = false;
      notifyListeners();
      return ProcessResult.success();
    } on ImageProcessException catch (e) {
      isLoading = false;
      notifyListeners();
      return ProcessResult.error('Ошибка API: ${e.statusCode}');
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return ProcessResult.error('Ошибка сети: $e');
    }
  }
}

class ProcessResult {
  final bool ok;
  final String? message;

  const ProcessResult._(this.ok, this.message);
  factory ProcessResult.success() => const ProcessResult._(true, null);
  factory ProcessResult.error(String msg) => ProcessResult._(false, msg);
}
