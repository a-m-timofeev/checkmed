# Drug Interaction Checker - Backend API

ASP.NET Core Web API для проверки взаимодействий лекарств.

## Требования

- .NET 8.0 SDK
- PostgreSQL 16+ (или Docker)
- Redis (опционально, для кэша)

## Быстрый старт

### С Docker Compose (рекомендуется)

```bash
cd backend
docker-compose up -d
```

API будет доступен на `http://localhost:5000`

### Без Docker

1. **Установите зависимости:**
```bash
cd DrugInteractionAPI
dotnet restore
```

2. **Настройте БД:**

Обновите connection string в `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=druginteraction;Username=postgres;Password=yourpassword"
  }
}
```

3. **Запустите миграции:**
```bash
dotnet ef database update
```

4. **Запустите API:**
```bash
dotnet run
```

## Конфигурация

### appsettings.json

```json
{
  "Jwt": {
    "Key": "your-secret-key-at-least-32-characters",
    "Issuer": "DrugInteractionAPI",
    "Audience": "DrugInteractionMobileApp"
  },
  "Google": {
    "ClientId": "your-google-client-id.apps.googleusercontent.com"
  },
  "OpenAI": {
    "ApiKey": "your-openai-api-key",
    "Model": "gpt-4-turbo-preview"
  }
}
```

### Секреты в Development

Используйте User Secrets для чувствительных данных:

```bash
dotnet user-secrets init
dotnet user-secrets set "OpenAI:ApiKey" "your-key"
dotnet user-secrets set "Jwt:Key" "your-secret"
```

### Azure Key Vault (Production)

Секреты автоматически загружаются из Key Vault если:
- Настроен `KeyVault:VaultUrl` в конфигурации
- App Service имеет Managed Identity

## API Endpoints

### Authentication

- `POST /api/auth/google` - Google Sign-In
- `POST /api/auth/refresh` - Refresh token

### Medications

- `GET /api/medications` - Список лекарств
- `POST /api/medications` - Добавить лекарство
- `PUT /api/medications/{id}` - Обновить
- `DELETE /api/medications/{id}` - Удалить

### Check Interactions

- `POST /api/check` - Создать проверку
- `GET /api/check/results/{jobId}` - Получить результат
- `GET /api/check/history` - История
- `DELETE /api/check/{jobId}` - Удалить

### User

- `GET /api/user/profile` - Профиль пользователя
- `PUT /api/user/profile` - Обновить профиль
- `POST /api/user/export-data` - Экспорт данных (GDPR)
- `DELETE /api/user/account` - Удалить аккаунт

### Swagger

Доступен на: `http://localhost:5000/swagger`

## Тестирование

```bash
cd DrugInteractionAPI.Tests
dotnet test
```

С coverage:
```bash
dotnet test /p:CollectCoverage=true /p:CoverageReportFormat=opencover
```

## Database Migrations

### Создать миграцию

```bash
dotnet ef migrations add MigrationName
```

### Применить миграции

```bash
dotnet ef database update
```

### Откатить миграцию

```bash
dotnet ef database update PreviousMigrationName
```

## Docker

### Build образа

```bash
docker build -t drug-interaction-api .
```

### Запуск

```bash
docker run -p 5000:80 \
  -e ConnectionStrings__DefaultConnection="Host=host.docker.internal;..." \
  drug-interaction-api
```

## Развертывание

### Azure App Service

См. подробное руководство в `/DEPLOYMENT.md`

Краткая версия:
```bash
# Build and push
docker build -t yourregistry.azurecr.io/drug-interaction-api:latest .
docker push yourregistry.azurecr.io/drug-interaction-api:latest

# Deploy
az webapp create --resource-group rg --plan plan \
  --name drug-api --deployment-container-image-name yourregistry.azurecr.io/drug-interaction-api:latest
```

## Мониторинг

### Application Insights

Логи автоматически отправляются в Application Insights если настроен connection string.

### Health Check

```bash
curl http://localhost:5000/health
```

### Логи

Просмотр логов в Development:
```bash
dotnet run
# Logs будут в консоли
```

Production (Azure):
```bash
az webapp log tail --name your-app --resource-group your-rg
```

## Архитектура

```
Controllers/         # API endpoints
├── AuthController
├── MedicationsController
├── CheckController
└── UserController

Services/           # Business logic
├── AuthService          # JWT + Google OAuth
├── InteractionCheckService  # Main check logic
├── OpenAIService       # ChatGPT integration
├── RxNormService       # Drug normalization
├── RedisCacheService   # Caching
└── CheckJobWorker      # Background processing

Models/             # Data models
├── User
├── Medication
├── CheckJob
└── CheckResult

Data/               # Database context
└── ApplicationDbContext

Middleware/         # Custom middleware
├── ErrorHandlingMiddleware
└── RequestLoggingMiddleware
```

## Безопасность

- ✅ HTTPS enforced
- ✅ JWT authentication
- ✅ Google OAuth server-side verification
- ✅ Rate limiting
- ✅ Input validation
- ✅ SQL injection protection (EF Core)
- ✅ CORS configured
- ✅ Secrets in Key Vault (production)

## Performance

### Кэширование

- Redis для результатов проверок (TTL: 48 часов)
- In-memory cache для rate limiting

### Асинхронная обработка

- Background Worker для CPU-интенсивных задач
- Очереди для масштабирования (можно добавить Azure Queue)

## Troubleshooting

### База данных недоступна

```bash
# Проверьте connection string
dotnet ef dbcontext info

# Проверьте, что PostgreSQL запущен
docker ps
```

### OpenAI API ошибки

- Проверьте API key
- Проверьте квоты в OpenAI dashboard
- Проверьте rate limits

### JWT ошибки

- Проверьте, что ключ >= 32 символов
- Проверьте Issuer и Audience
- Проверьте время на сервере (JWT проверяет exp)

## Contributing

См. `/CONTRIBUTING.md`

## License

MIT License - см. LICENSE в корне проекта