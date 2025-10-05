# Quick Start Guide

Быстрый старт для разработки Drug Interaction Checker.

## 🚀 Супер-быстрый старт (5 минут)

### Предварительные требования

- ✅ Docker & Docker Compose
- ✅ Flutter 3.16+
- ✅ .NET 8.0 SDK

### Запуск Backend

```bash
# Клонируйте и запустите
git clone <repo-url>
cd drug-interaction-checker/backend
docker-compose up -d

# Проверьте
curl http://localhost:5000/health
```

API работает на: http://localhost:5000  
Swagger UI: http://localhost:5000/swagger

### Запуск Mobile App

```bash
# В новом терминале
cd ../mobile
flutter pub get
flutter pub run build_runner build
flutter run

# Выберите эмулятор/симулятор
```

## 📝 Пошаговое руководство

### 1. Настройка Backend (10 минут)

#### Автоматическая установка

```bash
chmod +x scripts/setup-backend.sh
./scripts/setup-backend.sh
```

#### Ручная установка

```bash
# 1. Клонируйте репозиторий
git clone <repo-url>
cd drug-interaction-checker

# 2. Настройте конфигурацию
cd backend/DrugInteractionAPI
cp appsettings.json appsettings.Development.json

# Отредактируйте appsettings.Development.json:
# - ConnectionString (если не используете Docker)
# - OpenAI API key (optional для теста)
# - Google Client ID (optional для теста)

# 3. Запустите зависимости
cd ..
docker-compose up -d postgres redis

# 4. Применитемиграции
cd DrugInteractionAPI
dotnet ef database update

# 5. Запустите API
dotnet run
```

### 2. Настройка Mobile App (10 минут)

#### Автоматическая установка

```bash
chmod +x scripts/setup-mobile.sh
./scripts/setup-mobile.sh
```

#### Ручная установка

```bash
# 1. Перейдите в mobile директорию
cd mobile

# 2. Установите зависимости
flutter pub get

# 3. Сгенерируйте код
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Обновите API URL
# Отредактируйте lib/services/api_service.dart:
# - Android emulator: http://10.0.2.2:5000/api
# - iOS simulator: http://localhost:5000/api

# 5. Запустите приложение
flutter run
```

### 3. Тестирование интеграции (5 минут)

```bash
# В мобильном приложении:
# 1. Пропустите onboarding
# 2. Войдите как гость (если доступно) или через Google
# 3. Добавьте тестовые лекарства:
#    - Warfarin 5mg
#    - Aspirin 100mg
# 4. Нажмите "Проверить взаимодействия"
# 5. Дождитесь результата (5-10 секунд)
```

## 🔧 Конфигурация для разработки

### Backend Environment Variables

Создайте `.env` файл в `backend/`:

```env
# Database
DATABASE_URL=Host=localhost;Database=druginteraction;Username=postgres;Password=postgres123

# JWT
JWT_KEY=your-development-secret-key-min-32-chars
JWT_ISSUER=DrugInteractionAPI
JWT_AUDIENCE=DrugInteractionMobileApp

# OpenAI (опционально для разработки)
OPENAI_API_KEY=sk-...

# Google OAuth (опционально)
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com

# Redis
REDIS_URL=localhost:6379
```

### Mobile Configuration

Обновите `lib/utils/constants.dart`:

```dart
class AppConstants {
  static const String apiBaseUrl = 'http://10.0.2.2:5000/api'; // Android
  // static const String apiBaseUrl = 'http://localhost:5000/api'; // iOS
}
```

## 🧪 Запуск тестов

```bash
# Все тесты
./scripts/run-tests.sh

# Только backend
cd backend/DrugInteractionAPI.Tests
dotnet test

# Только mobile
cd mobile
flutter test
```

## 🐛 Отладка

### Backend не запускается

```bash
# Проверьте логи Docker
docker-compose logs api

# Проверьте PostgreSQL
docker-compose ps postgres

# Пересоберите
docker-compose down
docker-compose up --build
```

### Mobile не подключается к API

```bash
# Android emulator
adb logcat | grep flutter

# Проверьте API URL в коде
# Проверьте, что backend запущен
curl http://localhost:5000/health

# Попробуйте реальный IP (для физического устройства)
ifconfig | grep inet  # macOS/Linux
ipconfig  # Windows
```

### Google Sign-In не работает

```bash
# 1. Убедитесь, что ClientId настроен
# 2. Для Android: добавьте SHA-1 fingerprint
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# 3. Добавьте fingerprint в Google Console
# 4. Перезапустите приложение
```

## 📊 Полезные команды

### Backend

```bash
# Логи
docker-compose logs -f api

# Перезапуск
docker-compose restart api

# Войти в контейнер
docker-compose exec api bash

# Миграции
dotnet ef migrations add MigrationName
dotnet ef database update

# Swagger
open http://localhost:5000/swagger
```

### Mobile

```bash
# Список устройств
flutter devices

# Горячая перезагрузка
# Нажмите 'r' в терминале где запущено flutter run

# Очистка
flutter clean
flutter pub get

# Обновление зависимостей
flutter pub upgrade

# Проверка
flutter doctor
```

### Docker

```bash
# Статус сервисов
docker-compose ps

# Остановить все
docker-compose down

# Удалить volumes (ВНИМАНИЕ: удалит данные БД)
docker-compose down -v

# Пересобрать
docker-compose up --build
```

## 🎯 Следующие шаги

После успешного запуска:

1. **Изучите код:**
   - Backend: `/backend/DrugInteractionAPI/`
   - Mobile: `/mobile/lib/`

2. **Прочитайте документацию:**
   - API Examples: `/docs/API_EXAMPLES.md`
   - Deployment: `/DEPLOYMENT.md`
   - Contributing: `/CONTRIBUTING.md`

3. **Настройте production:**
   - OpenAI API key
   - Google OAuth credentials
   - AdMob IDs
   - Azure resources

4. **Разработка:**
   - Создайте feature branch
   - Внесите изменения
   - Запустите тесты
   - Создайте PR

## 💡 Подсказки

- **Hot Reload**: В Flutter нажмите `r` для hot reload, `R` для hot restart
- **Swagger**: Используйте Swagger UI для тестирования API без приложения
- **Breakpoints**: Используйте VS Code/Visual Studio для отладки
- **Logs**: Проверяйте логи Docker и Flutter для диагностики
- **Database**: Используйте pgAdmin или TablePlus для просмотра БД

## ❓ Проблемы?

1. Проверьте [TROUBLESHOOTING](./TROUBLESHOOTING.md)
2. Просмотрите GitHub Issues
3. Создайте новый issue с:
   - Описанием проблемы
   - Шагами для воспроизведения
   - Логами
   - Версиями (Flutter, .NET, Docker)

## 📚 Ресурсы

- [Flutter Docs](https://flutter.dev/docs)
- [ASP.NET Core Docs](https://docs.microsoft.com/aspnet/core)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Docker Docs](https://docs.docker.com/)

---

**Готово!** Теперь у вас работает полный stack Drug Interaction Checker! 🎉