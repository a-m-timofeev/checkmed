# Drug Interaction Checker

Мобильное приложение для проверки взаимодействий лекарственных препаратов с использованием AI и проверенных медицинских источников.

## 🎯 Цель проекта

Разработать мобильное приложение (Android/iOS) с backend-сервисом для проверки совместимости лекарств. Приложение использует внешние медицинские источники (RxNorm, OpenFDA) и OpenAI для анализа и предоставления понятных рекомендаций пользователям.

## 📋 Основные возможности

### Mobile App (Flutter)
- ✅ Onboarding с информацией о функционале и согласием на политику конфиденциальности
- ✅ Авторизация через Google Sign-In
- ✅ Управление списком принимаемых лекарств (добавление, удаление, редактирование)
- ✅ Проверка взаимодействий с показом результатов по категориям:
  - 🔴 **Опасно** - требуется немедленная консультация врача
  - 🟡 **С осторожностью** - необходим контроль симптомов
  - 🟢 **Рекомендация** - безопасно или нет значимых взаимодействий
- ✅ История проверок
- ✅ Интеграция AdMob (монетизация)
- ✅ Настройки и управление аккаунтом (GDPR compliance)

### Backend (ASP.NET Core)
- ✅ RESTful API с JWT аутентификацией
- ✅ Интеграция с Google OAuth для верификации пользователей
- ✅ Асинхронная обработка проверок через Background Worker
- ✅ Интеграция с RxNorm API для нормализации названий лекарств
- ✅ Интеграция с OpenAI для анализа и синтеза взаимодействий
- ✅ Кэширование результатов (Redis)
- ✅ Rate limiting (лимиты для бесплатных/премиум пользователей)
- ✅ PostgreSQL для хранения данных
- ✅ Docker поддержка
- ✅ Azure готовность (Key Vault, App Service)

## 🏗️ Архитектура

```
┌─────────────────┐
│  Mobile App     │
│  (Flutter)      │
└────────┬────────┘
         │
         │ HTTPS/JWT
         ▼
┌─────────────────────────────────────┐
│  Backend API (ASP.NET Core)         │
│  ├─ Controllers                     │
│  ├─ Services                        │
│  │  ├─ AuthService                  │
│  │  ├─ MedicationService            │
│  │  ├─ InteractionCheckService      │
│  │  ├─ OpenAIService               │
│  │  └─ RxNormService                │
│  └─ Background Worker               │
└────────┬────────────────────────────┘
         │
    ┌────┴────┬────────┬──────────┐
    ▼         ▼        ▼          ▼
┌────────┐ ┌────┐  ┌────────┐  ┌──────┐
│Postgres│ │Redis│ │RxNorm  │  │OpenAI│
│   DB   │ │Cache│ │  API   │  │ API  │
└────────┘ └────┘  └────────┘  └──────┘
```

## 🚀 Быстрый старт

### Требования

**Backend:**
- .NET 8.0 SDK
- PostgreSQL 16+
- Redis (опционально для кэша)
- Docker (для контейнеризации)

**Mobile:**
- Flutter 3.16+
- Android SDK (для Android)
- Xcode 15+ (для iOS)

### Запуск Backend локально

1. **Установите зависимости:**
```bash
cd backend/DrugInteractionAPI
dotnet restore
```

2. **Настройте `appsettings.json`:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=druginteraction;Username=postgres;Password=yourpassword"
  },
  "Jwt": {
    "Key": "your-secret-key-min-32-characters"
  },
  "Google": {
    "ClientId": "your-google-client-id.apps.googleusercontent.com"
  },
  "OpenAI": {
    "ApiKey": "your-openai-api-key"
  }
}
```

3. **Запустите базу данных:**
```bash
docker run -d \
  --name postgres-drug \
  -e POSTGRES_DB=druginteraction \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:16-alpine
```

4. **Запустите приложение:**
```bash
dotnet run
```

API будет доступен по адресу: `https://localhost:5001`

### Запуск Backend через Docker Compose

```bash
cd backend
docker-compose up -d
```

Это запустит:
- API сервис на порту 5000
- PostgreSQL на порту 5432
- Redis на порту 6379

### Запуск Mobile приложения

1. **Установите зависимости:**
```bash
cd mobile
flutter pub get
```

2. **Сгенерируйте модели (если требуется):**
```bash
flutter pub run build_runner build
```

3. **Настройте API URL в `lib/services/api_service.dart`:**
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
// или
static const String baseUrl = 'http://localhost:5000/api'; // iOS simulator
```

4. **Настройте Google Sign-In:**
   - Создайте проект в [Google Cloud Console](https://console.cloud.google.com/)
   - Настройте OAuth 2.0 credentials
   - Добавьте Client ID в код

5. **Запустите приложение:**
```bash
flutter run
```

## 📡 API Endpoints

### Authentication
- `POST /api/auth/google` - Аутентификация через Google
- `POST /api/auth/refresh` - Обновление токена

### Medications
- `GET /api/medications` - Получить список лекарств
- `POST /api/medications` - Добавить лекарство
- `PUT /api/medications/{id}` - Обновить лекарство
- `DELETE /api/medications/{id}` - Удалить лекарство

### Check Interactions
- `POST /api/check` - Создать проверку (возвращает job_id)
- `GET /api/check/results/{jobId}` - Получить результат проверки
- `GET /api/check/history` - История проверок
- `DELETE /api/check/{jobId}` - Удалить проверку

## 🔐 Безопасность

- ✅ TLS/HTTPS everywhere
- ✅ JWT токены с коротким TTL
- ✅ Google OAuth верификация на сервере
- ✅ Azure Key Vault для секретов (production)
- ✅ Rate limiting для защиты от abuse
- ✅ Field-level encryption для PII
- ✅ GDPR compliance (удаление данных, экспорт)

## 💰 Монетизация

1. **AdMob интеграция:**
   - Баннерная реклама на экране ожидания
   - Межстраничная реклама между проверками

2. **Premium подписка:**
   - Отключение рекламы
   - Увеличенный лимит проверок (100 vs 5 в день)
   - Приоритетная обработка
   - Расширенные отчёты с PDF экспортом

## 🚢 Развертывание в Azure

### Backend

1. **Создайте ресурсы Azure:**
```bash
# Resource Group
az group create --name drug-interaction-rg --location eastus

# PostgreSQL Database
az postgres flexible-server create \
  --name drug-interaction-db \
  --resource-group drug-interaction-rg \
  --location eastus \
  --admin-user pgadmin \
  --admin-password YourSecurePassword

# Redis Cache
az redis create \
  --name drug-interaction-cache \
  --resource-group drug-interaction-rg \
  --location eastus \
  --sku Basic \
  --vm-size c0

# Container Registry
az acr create \
  --name druginteractionacr \
  --resource-group drug-interaction-rg \
  --sku Basic

# Key Vault
az keyvault create \
  --name drug-interaction-kv \
  --resource-group drug-interaction-rg \
  --location eastus
```

2. **Настройте секреты в Key Vault:**
```bash
az keyvault secret set --vault-name drug-interaction-kv --name OpenAI-ApiKey --value "your-key"
az keyvault secret set --vault-name drug-interaction-kv --name Jwt-Key --value "your-jwt-key"
```

3. **Соберите и отправьте Docker образ:**
```bash
cd backend
docker build -t druginteractionacr.azurecr.io/drug-interaction-api:latest .
az acr login --name druginteractionacr
docker push druginteractionacr.azurecr.io/drug-interaction-api:latest
```

4. **Создайте App Service:**
```bash
az appservice plan create \
  --name drug-interaction-plan \
  --resource-group drug-interaction-rg \
  --is-linux \
  --sku B1

az webapp create \
  --name drug-interaction-api \
  --resource-group drug-interaction-rg \
  --plan drug-interaction-plan \
  --deployment-container-image-name druginteractionacr.azurecr.io/drug-interaction-api:latest
```

### CI/CD

GitHub Actions workflow уже настроен в `.github/workflows/backend-ci-cd.yml`

**Необходимые secrets в GitHub:**
- `AZURE_CREDENTIALS`
- `ACR_LOGIN_SERVER`
- `ACR_USERNAME`
- `ACR_PASSWORD`
- `AZURE_APP_NAME`

### Mobile App

**Android:**
```bash
cd mobile
flutter build apk --release
# или
flutter build appbundle --release
```

Загрузите `.aab` файл в Google Play Console.

**iOS:**
```bash
flutter build ios --release
```

Используйте Xcode для архивации и загрузки в App Store Connect.

## 🧪 Тестирование

### Backend
```bash
cd backend/DrugInteractionAPI
dotnet test
```

### Mobile
```bash
cd mobile
flutter test
```

## 📝 Важные замечания

1. **Медицинский disclaimer:** Приложение предоставляет только информацию и НЕ заменяет профессиональную медицинскую консультацию.

2. **RxNorm API:** Бесплатный, но требует регистрации для некоторых функций. См. [https://rxnav.nlm.nih.gov/](https://rxnav.nlm.nih.gov/)

3. **OpenAI API:** Платный сервис. Следите за использованием токенов и настройте лимиты.

4. **GDPR:** Убедитесь, что вы соблюдаете требования GDPR при обработке медицинских данных пользователей в ЕС.

5. **Rate Limiting:** В production настройте адекватные лимиты на основе ваших OpenAI квот.

## 📚 Дополнительная документация

- [API Specification (OpenAPI)](./docs/api-spec.yaml) - TODO
- [Architecture Decision Records](./docs/adr/) - TODO
- [Security Considerations](./docs/security.md) - TODO

## 🤝 Контрибуция

1. Fork проект
2. Создайте feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit изменения (`git commit -m 'Add some AmazingFeature'`)
4. Push в branch (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

## 📄 Лицензия

Этот проект создан в образовательных целях. Для использования в production необходимо:
- Получить соответствующие медицинские сертификации
- Провести аудит безопасности
- Получить юридическую консультацию относительно медицинских приложений в вашей юрисдикции

## ⚠️ Disclaimer

**ВАЖНО:** Это приложение предоставляет информационные материалы о потенциальных взаимодействиях лекарств на основе доступных данных и AI анализа. Оно НЕ предназначено для замены профессиональной медицинской консультации, диагностики или лечения. Всегда консультируйтесь с квалифицированным медицинским специалистом по вопросам, связанным со здоровьем и лекарствами.

## 👥 Авторы

Создано для демонстрации возможностей интеграции Flutter, .NET, Azure и OpenAI в healthcare приложениях.

---

**Сделано с ❤️ для улучшения безопасности пациентов**