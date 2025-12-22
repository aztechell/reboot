# Reboot

AI-приложение для изменения внешнего вида на фото (прическа, стиль, фон) с помощью Stability API. Есть история вариантов, загрузка/скачивание и пресеты для каждого режима.

Авторы: Команда undefined.

100% Вайбкодинг на GPT-5.1-Codex-Max.

Сайт был размещён на firebase [https://reboot-waih.web.app/](https://reboot-waih.web.app/)

## Возможности
- Режимы: поменять прическу, стиль или фон (с отдельными search/prompt/negative пресетами).
- Загрузка фото, обработка, навигация по истории, мини-превью вариантов.
- Скачивание (web/mobile/desktop через платформенный сервис).

## Примеры

| Оригинал | Результат |
|---------|-----------|
| ![](examples/1.jpg) | ![](examples/2.png) |
| ![](examples/3.jpg) | ![](examples/4.png) |


## Технологии / архитектура
- Flutter (web-first, поддерживает mobile/desktop).
- `lib/state/app_state.dart` — ChangeNotifier со стейтом (история, режимы, вызовы API).
- `lib/services/` — абстракции API и скачивания (`ImageService`, `DownloadService` с web/io реализациями).
- UI в `lib/main.dart`, стейт прокидывается через `AppStateProvider`.

## Требования
- Flutter 3.10+ (Dart >=3.10 <4.0).
- Ключ Stability API.
- Для web-деплоя: npm (firebase-tools).

## Установка
```bash
flutter pub get
```

### Ключи
Передайте ключ через `--dart-define`:
```bash
flutter run -d chrome --dart-define=STABILITY_API_KEY=ваш_ключ
```
`chrome` замените на нужное устройство.

## Сборка
- Web release:
```bash
flutter build web --release --dart-define=STABILITY_API_KEY=ваш_ключ
```
Артефакты: `build/web`.

## Firebase Hosting (SPA)
Конфиги: `firebase.json`, `.firebaserc` (`public: build/web`, SPA rewrite на `index.html`).
Деплой:
```bash
flutter build web --release --dart-define=STABILITY_API_KEY=ваш_ключ
firebase deploy --only hosting
```

## Тесты / качество
- Анализ: `flutter analyze`
- (Добавить) Unit-тесты для `AppState` и сервисов (моки HTTP/скачивания).

## Структура
- `lib/main.dart` — UI и композиция.
 - `lib/state/app_state.dart` — стейт: режимы, история, обработка, скачивание.
- `lib/services/image_service.dart` — клиент Stability API.
- `lib/services/download_service_{web,io}.dart` — платформенные реализации скачивания.
- `firebase.json`, `.firebaserc` — хостинг-конфиг.

