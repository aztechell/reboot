// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'services/services.dart';
import 'state/app_state.dart';

void main() {
  final appState = AppState(
    imageService: ImageService(apiKey: const String.fromEnvironment('STABILITY_API_KEY', defaultValue: '')),
    downloadService: PlatformDownloadService(),
    modes: const ['Поменять прическу', 'Поменять стиль', 'Поменять фон'],
    presets: const {
      'Поменять прическу': {
        'search': 'hair, hairstyle, bangs, fringe',
        'prompt': 'subtle hairstyle refresh, realistic hair texture, neat edges, keep the same face and background',
        'negative': 'overprocessed, plastic skin, heavy makeup, different person, distorted face, cartoon'
      },
      'Поменять стиль': {
        'search': 'clothing, outfit, wardrobe, style',
        'prompt': 'soft outfit restyle, cohesive palette, natural fabric look, keep face and body proportions, same background',
        'negative': 'extravagant costume, armor, fantasy, distorted body, different person, cartoon, noisy background'
      },
      'Поменять фон': {
        'search': 'background, backdrop, environment',
        'prompt': 'replace background with clean minimal studio backdrop, keep person identity, lighting consistent',
        'negative': 'wrong person, distorted face, extra limbs, busy background, artifacts, mismatched lighting'
      },
    },
  );
  runApp(AppStateProvider(notifier: appState, child: const MyApp()));
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({super.key, required super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF8A3D),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFFFF7F0),
        textTheme: ThemeData.light().textTheme.apply(bodyColor: Colors.black87, displayColor: Colors.black87),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.25)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Future<void> _pickImage(BuildContext context, AppState state) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      await state.setOriginal(bytes);
    }
  }

  Future<void> _runProcess(BuildContext context, AppState state) async {
    final result = await state.processImage();
    if (!context.mounted) return;
    if (!result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'Ошибка обработки')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Готово!')));
    }
  }

  Future<void> _download(BuildContext context, AppState state) async {
    final res = await state.downloadCurrent();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message ?? (res.success ? 'Сохранено' : 'Не удалось сохранить'))));
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isWide = MediaQuery.of(context).size.width > 900;
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF4E6), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _Header(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: isWide ? 2 : 1,
                            child: _FrostedCard(
                              padding: const EdgeInsets.all(18),
                              child: _ChatPanel(
                                appState: appState,
                                onProcess: () => _runProcess(context, appState),
                              ),
                            ),
                          ),
                          SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
                          Expanded(
                            flex: isWide ? 3 : 2,
                            child: _FrostedCard(
                              padding: const EdgeInsets.all(18),
                              child: _PreviewPanel(
                                appState: appState,
                                onPickImage: () => _pickImage(context, appState),
                                onProcess: () => _runProcess(context, appState),
                                onDownload: () => _download(context, appState),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Reboot', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text('Перезагрузка самоощущения', style: TextStyle(color: Colors.black54, fontSize: 13), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ChatPanel extends StatefulWidget {
  const _ChatPanel({required this.appState, required this.onProcess});
  final AppState appState;
  final VoidCallback onProcess;

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.appState.prompt);
    _controller.addListener(() => widget.appState.setPrompt(_controller.text));
  }

  @override
  void didUpdateWidget(covariant _ChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appState != widget.appState) {
      _controller.text = widget.appState.prompt;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appState = widget.appState;
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: appState.selectedMode,
          isExpanded: true,
          dropdownColor: Colors.white,
          decoration: const InputDecoration(labelText: 'Режим', prefixIcon: Icon(Icons.auto_awesome)),
          items: appState.modes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (val) {
            if (val != null) appState.setMode(val);
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(hintText: 'Что изменить?'),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: (!appState.hasImage || appState.isLoading) ? null : widget.onProcess,
              icon: appState.isLoading
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send, size: 16),
              label: Text(appState.isLoading ? 'Обработка...' : 'Пуск'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                appState.selectedMode,
                style: TextStyle(color: scheme.primary.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.appState,
    required this.onPickImage,
    required this.onProcess,
    required this.onDownload,
  });

  final AppState appState;
  final VoidCallback onPickImage;
  final VoidCallback onProcess;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final displayBytes = appState.currentImage;
    final aspect = appState.currentAspect;
    final hasImage = appState.hasImage && displayBytes != null;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onPickImage,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                        maxHeight: constraints.maxHeight,
                      ),
                      child: AspectRatio(
                        aspectRatio: aspect,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.brown.withOpacity(0.4), width: 2),
                            color: Colors.white.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              children: [
                              if (!hasImage)
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.brown),
                                      SizedBox(height: 8),
                                      Text('Нажмите, чтобы загрузить', style: TextStyle(color: Colors.brown)),
                                    ],
                                  ),
                                )
                              else
                                  Image.memory(displayBytes, fit: BoxFit.contain),
                                if (appState.isOriginal && hasImage)
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Оригинал',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                if (hasImage)
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                child: Row(
                                  children: [
                                    _squareIconButton(
                                      icon: Icons.auto_fix_high_rounded,
                                      onTap: appState.isLoading ? null : onProcess,
                                      loading: appState.isLoading,
                                    ),
                                    const SizedBox(width: 8),
                                    _squareIconButton(
                                      icon: Icons.download_rounded,
                                      onTap: onDownload,
                                    ),
                                    const SizedBox(width: 8),
                                    _squareIconButton(
                                      icon: Icons.delete_outline_rounded,
                                      onTap: appState.isLoading ? null : appState.removeCurrent,
                                    ),
                                  ],
                                ),
                              ),
                                if (appState.isLoading)
                                  Container(
                                    color: Colors.black45,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (appState.hasImage)
          Row(
            children: [
              _roundBtn(Icons.chevron_left, appState.goPrev),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: appState.history.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isActive = index == appState.currentIndex;
                      return GestureDetector(
                        onTap: () => appState.goTo(index),
                        child: Container(
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isActive ? scheme.primary : Colors.black26, width: isActive ? 2 : 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              appState.history[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _roundBtn(Icons.chevron_right, appState.goNext),
            ],
          ),
      ],
    );
  }
}

Widget _roundBtn(IconData icon, VoidCallback? onTap) {
  return IconButton.filledTonal(
    onPressed: onTap,
    icon: Icon(icon),
    style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  );
}

Widget _squareIconButton({required IconData icon, required VoidCallback? onTap, bool loading = false}) {
  return SizedBox(
    width: 44,
    height: 44,
    child: Material(
      color: onTap == null ? Colors.grey.shade200 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: onTap == null ? Colors.grey.shade300 : Colors.black12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: loading ? null : onTap,
        child: Center(
          child: loading
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(icon, color: onTap == null ? Colors.grey : Colors.brown),
        ),
      ),
    ),
  );
}

class _FrostedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _FrostedCard({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: child,
        ),
      ),
    );
  }
}
