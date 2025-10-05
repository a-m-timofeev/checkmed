# Troubleshooting Guide

Решения распространённых проблем при разработке Drug Interaction Checker.

## Backend проблемы

### 1. API не запускается

**Симптомы:**
- Ошибка при `dotnet run`
- Port already in use

**Решение:**
```bash
# Проверьте, что порт свободен
lsof -i :5000  # macOS/Linux
netstat -ano | findstr :5000  # Windows

# Убейте процесс или измените порт в launchSettings.json

# Очистите и пересоберите
dotnet clean
dotnet build
```

### 2. Database connection failed

**Симптомы:**
- `Npgsql.NpgsqlException: Connection refused`
- `Could not connect to database`

**Решение:**
```bash
# Проверьте, что PostgreSQL запущен
docker ps | grep postgres

# Если не запущен:
docker-compose up -d postgres

# Проверьте connection string
# appsettings.json должен иметь правильные credentials

# Проверьте подключение
psql -h localhost -U postgres -d druginteraction
```

### 3. JWT Authentication ошибки

**Симптомы:**
- `401 Unauthorized` на защищённых endpoints
- `Invalid token`

**Решение:**
```bash
# 1. Убедитесь, что ключ >= 32 символов
# 2. Проверьте Issuer и Audience совпадают в конфиге
# 3. Проверьте время на сервере (JWT проверяет exp)
date  # Время должно быть правильным

# 4. Получите новый токен
curl -X POST http://localhost:5000/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{"id_token":"..."}'
```

### 4. OpenAI API ошибки

**Симптомы:**
- `429 Too Many Requests`
- `Invalid API key`
- `Rate limit exceeded`

**Решение:**
```bash
# 1. Проверьте API key в конфигурации
# 2. Проверьте квоты в OpenAI dashboard: https://platform.openai.com/usage
# 3. Для разработки можно временно закомментировать вызов OpenAI

# Временное решение - мок сервис:
# В OpenAIService.cs вместо реального вызова возвращайте тестовые данные
```

### 5. Redis connection ошибки

**Симптомы:**
- `StackExchange.Redis.RedisConnectionException`

**Решение:**
```bash
# Redis опционален для разработки
# Просто убедитесь, что он запущен:
docker-compose up -d redis

# Или закомментируйте Redis в Program.cs для локальной разработки
```

### 6. Migration ошибки

**Симптомы:**
- `Build failed` при создании миграции
- `A migration with the name already exists`

**Решение:**
```bash
# Если миграция существует
dotnet ef migrations remove

# Создайте новую
dotnet ef migrations add InitialCreate

# Если база уже существует
dotnet ef database drop
dotnet ef database update
```

## Mobile проблемы

### 1. Flutter pub get fails

**Симптомы:**
- `pub get failed`
- `version solving failed`

**Решение:**
```bash
# Очистите кэш
flutter clean
rm pubspec.lock

# Обновите Flutter
flutter upgrade

# Попробуйте снова
flutter pub get

# Если конкретный пакет проблема, обновите версию в pubspec.yaml
```

### 2. Не компилируется Android

**Симптомы:**
- Gradle build failures
- `Execution failed for task ':app:compileDebugKotlin'`

**Решение:**
```bash
# 1. Очистите Gradle кэш
cd android
./gradlew clean
cd ..

# 2. Инвалидируйте Flutter кэш
flutter clean

# 3. Обновите зависимости
flutter pub get

# 4. Пересоберите
flutter build apk

# 5. Если не помогло, удалите build папки
rm -rf android/app/build
rm -rf android/.gradle
```

### 3. iOS build ошибки

**Симптомы:**
- Pod install failures
- Xcode build errors

**Решение:**
```bash
# 1. Обновите pods
cd ios
pod deintegrate
pod install
cd ..

# 2. Если не помогло, обновите репозиторий pods
pod repo update
pod install

# 3. Очистите Xcode (если используете Xcode)
# Product > Clean Build Folder

# 4. Проверьте минимальную версию iOS в Podfile
# platform :ios, '12.0'  # или выше
```

### 4. Google Sign-In не работает

**Android:**
```bash
# 1. Получите SHA-1
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android

# 2. Добавьте SHA-1 в Google Cloud Console
# https://console.cloud.google.com/

# 3. Скачайте google-services.json
# Поместите в android/app/

# 4. Перезапустите приложение
flutter clean
flutter run
```

**iOS:**
```bash
# 1. Проверьте Bundle ID в Xcode совпадает с Google Console
# 2. Скачайте GoogleService-Info.plist
# 3. Поместите в ios/Runner/
# 4. Добавьте URL scheme в Info.plist
# 5. Перезапустите
```

### 5. API connection ошибки

**Симптомы:**
- `SocketException: Connection refused`
- `Failed host lookup`

**Решение:**
```bash
# Android emulator
# Используйте 10.0.2.2 вместо localhost
static const String apiBaseUrl = 'http://10.0.2.2:5000/api';

# iOS simulator
# Используйте localhost
static const String apiBaseUrl = 'http://localhost:5000/api';

# Физическое устройство
# Используйте реальный IP компьютера
# Найдите IP:
ifconfig | grep inet  # macOS/Linux
ipconfig  # Windows

static const String apiBaseUrl = 'http://192.168.1.100:5000/api';

# Убедитесь, что backend запущен
curl http://localhost:5000/health
```

### 6. AdMob не показывает рекламу

**Симптомы:**
- Реклама не появляется
- AdMob errors в логах

**Решение:**
```bash
# 1. Убедитесь, что используете test IDs для разработки
# В constants.dart используйте test IDs

# 2. Проверьте App ID в манифестах
# Android: AndroidManifest.xml
# iOS: Info.plist

# 3. Для production - замените на реальные IDs
# Создайте приложение в AdMob console

# 4. Тестирование может занять время
# Реклама может не появляться сразу

# 5. Проверьте логи
adb logcat | grep "Ads"  # Android
```

### 7. Build Runner ошибки

**Симптомы:**
- `build_runner` не генерирует файлы
- `.g.dart` файлы не создаются

**Решение:**
```bash
# Удалите старые генерированные файлы
flutter packages pub run build_runner clean

# Сгенерируйте заново с перезаписью
flutter packages pub run build_runner build --delete-conflicting-outputs

# Если ошибки компиляции, проверьте модели
# Убедитесь, что у вас есть:
# - @JsonSerializable() аннотация
# - part 'filename.g.dart';
# - factory fromJson и toJson методы
```

## Docker проблемы

### 1. Docker Compose не запускается

**Симптомы:**
- `docker-compose up` fails
- Containers не запускаются

**Решение:**
```bash
# Проверьте логи
docker-compose logs

# Остановите и удалите контейнеры
docker-compose down

# Пересоберите
docker-compose up --build

# Если проблемы с портами
docker-compose ps  # Проверьте конфликты портов
lsof -i :5000  # Убейте процесс на порту
```

### 2. PostgreSQL container ошибки

**Симптомы:**
- Database container keeps restarting
- `FATAL: password authentication failed`

**Решение:**
```bash
# Удалите volumes и пересоздайте
docker-compose down -v
docker-compose up -d postgres

# Проверьте логи
docker-compose logs postgres

# Если нужно изменить пароль, удалите volume:
docker volume ls
docker volume rm backend_postgres_data
```

### 3. Недостаточно памяти/диска

**Симптомы:**
- `no space left on device`
- Out of memory errors

**Решение:**
```bash
# Очистите неиспользуемые образы
docker system prune -a

# Очистите volumes
docker volume prune

# Проверьте использование
docker system df

# Увеличьте лимиты Docker Desktop
# Settings > Resources > увеличьте Memory/Disk
```

## CI/CD проблемы

### 1. GitHub Actions fails

**Симптомы:**
- CI pipeline fails
- Tests не проходят в CI

**Решение:**
```bash
# 1. Проверьте логи в GitHub Actions tab
# 2. Запустите локально те же команды:

# Backend
dotnet restore
dotnet build
dotnet test

# Mobile
flutter pub get
flutter analyze
flutter test

# 3. Убедитесь, что secrets настроены в GitHub:
# Settings > Secrets and variables > Actions
```

### 2. Azure deployment fails

**Симптомы:**
- Deployment успешный но приложение не работает
- 500 Internal Server Error

**Решение:**
```bash
# 1. Проверьте логи App Service
az webapp log tail --name your-app --resource-group your-rg

# 2. Проверьте environment variables в Portal
# Configuration > Application settings

# 3. Проверьте connection strings
# Убедитесь, что PostgreSQL доступен из App Service

# 4. Проверьте health endpoint
curl https://your-app.azurewebsites.net/health

# 5. Перезапустите App Service
az webapp restart --name your-app --resource-group your-rg
```

## Performance проблемы

### 1. API медленно отвечает

**Решение:**
```bash
# 1. Проверьте Application Insights для bottlenecks
# 2. Включите Redis кэширование
# 3. Оптимизируйте DB queries (добавьте индексы)
# 4. Увеличьте App Service tier
# 5. Настройте auto-scaling
```

### 2. Mobile app лагает

**Решение:**
```dart
// 1. Профилируйте приложение
flutter run --profile
// В DevTools проверьте CPU usage

// 2. Оптимизируйте билд методы
// Используйте const constructors где возможно

// 3. Ленивая загрузка списков
// Используйте ListView.builder вместо ListView

// 4. Оптимизируйте изображения
// Кэшируйте network images
```

## General Tips

### Логирование

**Backend:**
```bash
# Development
dotnet run  # Логи в консоли

# Production
az webapp log tail --name your-app --resource-group your-rg
```

**Mobile:**
```bash
# Android
adb logcat | grep flutter

# iOS
flutter logs
```

### Debugging

**Backend:**
```bash
# Используйте VS Code или Visual Studio
# Установите breakpoints в .cs файлах
# F5 для запуска с отладкой
```

**Mobile:**
```bash
# Используйте VS Code с Flutter extension
# Установите breakpoints в .dart файлах
# F5 для запуска с отладкой
```

### Health Checks

```bash
# Backend
curl http://localhost:5000/health

# Database
psql -h localhost -U postgres -d druginteraction -c "SELECT 1"

# Redis
redis-cli ping
```

## Получение помощи

Если проблема не решена:

1. **Проверьте документацию:**
   - README.md
   - Backend README
   - Mobile README

2. **Поищите в Issues:**
   - GitHub Issues
   - Stack Overflow

3. **Создайте Issue:**
   - Опишите проблему
   - Приложите логи
   - Укажите версии (Flutter, .NET, Docker)
   - Шаги для воспроизведения

4. **Контакты:**
   - GitHub Discussions
   - Email: support@example.com

---

**Совет:** Всегда проверяйте логи первым делом! 90% проблем становятся очевидными при просмотре логов.