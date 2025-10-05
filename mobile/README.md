# Drug Interaction Checker - Mobile App

Flutter приложение для проверки взаимодействий лекарств.

## Требования

- Flutter 3.16 или выше
- Dart 3.2 или выше
- Android SDK (для Android)
- Xcode 15+ (для iOS, только на macOS)

## Установка

1. **Клонируйте репозиторий:**
```bash
git clone <repository-url>
cd mobile
```

2. **Установите зависимости:**
```bash
flutter pub get
```

3. **Сгенерируйте код:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Конфигурация

### API URL

Обновите `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-api-url.azurewebsites.net/api';
```

Для локальной разработки:
- Android emulator: `http://10.0.2.2:5000/api`
- iOS simulator: `http://localhost:5000/api`
- Физическое устройство: `http://YOUR_LOCAL_IP:5000/api`

### Google Sign-In

1. Создайте проект в [Google Cloud Console](https://console.cloud.google.com/)
2. Настройте OAuth 2.0 credentials
3. Для Android: добавьте SHA-1 fingerprint
4. Для iOS: добавьте URL scheme

**Android** (`android/app/google-services.json`):
```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "your-project-id"
  }
}
```

**iOS** (`ios/Runner/GoogleService-Info.plist`):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
  <key>CLIENT_ID</key>
  <string>YOUR_CLIENT_ID</string>
  ...
</dict>
</plist>
```

### AdMob

Обновите ID приложения в:
- **Android**: `android/app/src/main/AndroidManifest.xml`
- **iOS**: `ios/Runner/Info.plist`

Замените test IDs на production в `lib/utils/constants.dart`:
```dart
static const String adMobAppId = 'ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX';
static const String adMobInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

## Запуск

### Development

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Конкретное устройство
flutter devices
flutter run -d <device-id>
```

### Release Build

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle (для Google Play):**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Тестирование

```bash
# Запустить все тесты
flutter test

# С coverage
flutter test --coverage

# Конкретный тест
flutter test test/widget_test.dart
```

## Структура проекта

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── medication.dart
│   └── check_result.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── medication_provider.dart
│   └── check_provider.dart
├── screens/                  # UI screens
├── widgets/                  # Reusable widgets
├── services/                 # API & local services
└── utils/                    # Helpers & constants
```

## Debugging

### Android

```bash
# View logs
flutter logs

# Debug на устройстве
flutter run --debug
adb logcat | grep flutter
```

### iOS

```bash
# View logs
flutter logs

# Открыть Xcode
open ios/Runner.xcworkspace
```

## Production Build

### Подготовка

1. **Обновите версию** в `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

2. **Создайте keystore для Android:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

3. **Настройте signing** в `android/key.properties`

4. **Обновите Bundle ID/Package Name**

### Build & Release

**Google Play:**
```bash
flutter build appbundle --release
# Upload to Google Play Console
```

**App Store:**
```bash
flutter build ios --release
# Archive and upload via Xcode
```

## Troubleshooting

### Ошибка сборки Android

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### Ошибка iOS pod install

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### Google Sign-In не работает

- Проверьте SHA-1 fingerprint (Android)
- Проверьте Bundle ID (iOS)
- Проверьте OAuth credentials в Google Console

## Полезные команды

```bash
# Проверить состояние Flutter
flutter doctor

# Обновить зависимости
flutter pub upgrade

# Анализ кода
flutter analyze

# Форматирование
flutter format lib/

# Очистка
flutter clean
```

## Ресурсы

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design](https://material.io/design)

## License

MIT License - см. LICENSE в корне проекта