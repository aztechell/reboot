# Flutter + Firebase Hosting: быстрый старт

## 1. Установить VS Code

Скачать и установить VS Code:
```text
https://code.visualstudio.com/
```

Установить расширения (Extentions):
```text
Flutter (by Dart Code)
Dart (by Dart Code)
```
---

## 2. Установить Flutter

Установить Git для windows.
Для этого написать в командной строке:
```
winget --id Git.Git -e --source winget
```

Перезапустить VS Code.

Скачать Flutter SDK:
```text
https://docs.flutter.dev/install/manual
```

Распаковать скачанный архив и переместить папку flutter в любое место, например:
```
C:\Users\Admin\flutter
```

В командный центр написать:
```
>Flutter: New Project
```

Справа снизу выйдет окно, там выбрать "Locate SDK" и выбрать папку flutter. 


Проверка Flutter:

```bash
flutter --version
flutter doctor
```

---

## 3. Создать проект во Flutter

Создание проекта, в командный центр написать:
```
>Flutter: New Project
```

Установить расширение Codex и вайбкодить.

---

## 4. Билд проекта

Сборка Web-версии:
```bash
flutter build web --release
```

Результат сборки:
```text
build/web
```

---

## 5. Установка Firebase

Установить Node.js:
```text
https://nodejs.org/
```

Перезапустить систему. 

Проверка Node.js и npm:
```bash
node -v
npm -v
```

Установка Firebase CLI:
```bash
npm install -g firebase-tools
firebase --version
```

Если выходит ошибка сертификата:
```
npm config set strict-ssl false
```

Авторизация в Firebase:
```bash
firebase login
```

Инициализация Firebase Hosting:
```bash
firebase init hosting
```

---

## 6. Хостинг на Firebase

Сборка проекта:
```bash
flutter build web --release
```

Деплой:
```bash
firebase deploy
```

---

