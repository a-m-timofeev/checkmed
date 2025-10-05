# Руководство по развертыванию

Подробная инструкция по развертыванию Drug Interaction Checker в production.

## Предварительные требования

- Azure subscription
- Azure CLI установлен и настроен
- Docker установлен
- .NET 8.0 SDK
- Flutter 3.16+
- Git

## Развертывание Backend в Azure

### Шаг 1: Подготовка Azure

1. **Войдите в Azure:**
```bash
az login
```

2. **Установите subscription (если несколько):**
```bash
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

3. **Запустите скрипт развертывания:**
```bash
cd infrastructure
chmod +x deploy.sh
./deploy.sh
```

Скрипт создаст:
- Resource Group
- App Service Plan + App Service
- PostgreSQL Flexible Server
- Redis Cache
- Key Vault
- Application Insights

### Шаг 2: Настройка Key Vault

Добавьте секреты в Key Vault:

```bash
KEYVAULT_NAME="drug-interaction-kv"

# OpenAI API Key
az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name "OpenAI--ApiKey" \
  --value "YOUR_OPENAI_KEY"

# JWT Secret
az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name "Jwt--Key" \
  --value "$(openssl rand -base64 64)"

# Google OAuth Client Secret (if needed)
az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name "Google--ClientSecret" \
  --value "YOUR_GOOGLE_CLIENT_SECRET"
```

### Шаг 3: Container Registry

1. **Создайте Azure Container Registry:**
```bash
az acr create \
  --name druginteractionacr \
  --resource-group drug-interaction-rg \
  --sku Basic \
  --admin-enabled true
```

2. **Получите credentials:**
```bash
az acr credential show --name druginteractionacr
```

### Шаг 4: Сборка и публикация Docker образа

```bash
cd backend

# Логин в ACR
az acr login --name druginteractionacr

# Build
docker build -t druginteractionacr.azurecr.io/drug-interaction-api:latest .

# Push
docker push druginteractionacr.azurecr.io/drug-interaction-api:latest
```

### Шаг 5: Настройка App Service

1. **Настройте контейнер:**
```bash
az webapp config container set \
  --name drug-interaction-api \
  --resource-group drug-interaction-rg \
  --docker-custom-image-name druginteractionacr.azurecr.io/drug-interaction-api:latest \
  --docker-registry-server-url https://druginteractionacr.azurecr.io \
  --docker-registry-server-user <username> \
  --docker-registry-server-password <password>
```

2. **Настройте переменные окружения:**
```bash
az webapp config appsettings set \
  --name drug-interaction-api \
  --resource-group drug-interaction-rg \
  --settings \
    "ConnectionStrings__DefaultConnection=Host=drug-interaction-db.postgres.database.azure.com;Database=druginteraction;Username=pgadmin;Password=<password>;SslMode=Require" \
    "ConnectionStrings__Redis=drug-interaction-cache.redis.cache.windows.net:6380,password=<password>,ssl=True,abortConnect=False" \
    "KeyVault__VaultUrl=https://drug-interaction-kv.vault.azure.net/"
```

3. **Включите managed identity для Key Vault доступа:**
```bash
az webapp identity assign \
  --name drug-interaction-api \
  --resource-group drug-interaction-rg

# Получите principal ID
PRINCIPAL_ID=$(az webapp identity show \
  --name drug-interaction-api \
  --resource-group drug-interaction-rg \
  --query principalId -o tsv)

# Дайте доступ к Key Vault
az keyvault set-policy \
  --name drug-interaction-kv \
  --object-id $PRINCIPAL_ID \
  --secret-permissions get list
```

### Шаг 6: База данных миграции

```bash
# Локально установите connection string
export ConnectionStrings__DefaultConnection="Host=drug-interaction-db.postgres.database.azure.com;Database=druginteraction;Username=pgadmin;Password=<password>;SslMode=Require"

cd backend/DrugInteractionAPI
dotnet ef database update
```

### Шаг 7: Настройка CI/CD через GitHub Actions

1. **Создайте Service Principal:**
```bash
az ad sp create-for-rbac \
  --name "drug-interaction-github-actions" \
  --role contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/drug-interaction-rg \
  --sdk-auth
```

Сохраните JSON output.

2. **Добавьте GitHub Secrets:**

В вашем GitHub репозитории, перейдите в Settings > Secrets and variables > Actions:

- `AZURE_CREDENTIALS` - JSON из предыдущего шага
- `ACR_LOGIN_SERVER` - druginteractionacr.azurecr.io
- `ACR_USERNAME` - username из ACR credentials
- `ACR_PASSWORD` - password из ACR credentials
- `AZURE_APP_NAME` - drug-interaction-api

3. **Push в main ветку:**
```bash
git push origin main
```

CI/CD pipeline автоматически:
- Соберет backend
- Запустит тесты
- Создаст Docker образ
- Загрузит в ACR
- Развернёт в App Service

## Развертывание Mobile App

### Android (Google Play)

1. **Настройте подписание приложения:**

Создайте `android/key.properties`:
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=<your-key-alias>
storeFile=<path-to-keystore>
```

2. **Соберите release APK/AAB:**
```bash
cd mobile

# APK
flutter build apk --release

# или AAB (рекомендуется для Google Play)
flutter build appbundle --release
```

3. **Загрузите в Google Play Console:**
   - Создайте приложение в [Google Play Console](https://play.google.com/console)
   - Заполните store listing информацию
   - Загрузите AAB файл
   - Настройте AdMob и In-App Purchases
   - Отправьте на review

### iOS (App Store)

1. **Откройте проект в Xcode:**
```bash
cd mobile/ios
open Runner.xcworkspace
```

2. **Настройте signing & capabilities:**
   - Выберите Team
   - Настройте Bundle ID
   - Включите In-App Purchases capability

3. **Архивируйте и загрузите:**
```bash
flutter build ios --release
```

Затем в Xcode:
- Product > Archive
- Distribute App > App Store Connect
- Upload

4. **Настройте в App Store Connect:**
   - Заполните metadata
   - Загрузите screenshots
   - Настройте pricing
   - Submit for review

## Мониторинг и Логи

### Application Insights

Посмотреть метрики:
```bash
az monitor app-insights metrics show \
  --app drug-interaction-api-insights \
  --resource-group drug-interaction-rg \
  --metric requests/count
```

### Логи App Service

```bash
# Stream logs
az webapp log tail \
  --name drug-interaction-api \
  --resource-group drug-interaction-rg

# Download logs
az webapp log download \
  --name drug-interaction-api \
  --resource-group drug-interaction-rg
```

## Масштабирование

### Вертикальное (увеличение мощности)

```bash
az appservice plan update \
  --name drug-interaction-api-plan \
  --resource-group drug-interaction-rg \
  --sku P1V2
```

### Горизонтальное (увеличение инстансов)

```bash
az appservice plan update \
  --name drug-interaction-api-plan \
  --resource-group drug-interaction-rg \
  --number-of-workers 3
```

### Auto-scaling

```bash
az monitor autoscale create \
  --resource drug-interaction-api \
  --resource-group drug-interaction-rg \
  --resource-type Microsoft.Web/serverfarms \
  --name autoscale-plan \
  --min-count 1 \
  --max-count 5 \
  --count 1
```

## Бэкапы

### PostgreSQL

```bash
# Включить автоматические бэкапы
az postgres flexible-server update \
  --name drug-interaction-db \
  --resource-group drug-interaction-rg \
  --backup-retention 30
```

### Manual backup

```bash
# Export database
pg_dump -h drug-interaction-db.postgres.database.azure.com \
  -U pgadmin \
  -d druginteraction \
  -F c \
  -f backup_$(date +%Y%m%d).dump
```

## Безопасность Checklist

- [ ] Key Vault настроен и используется для секретов
- [ ] Managed Identity включен для App Service
- [ ] TLS/HTTPS enforced
- [ ] Firewall правила настроены для PostgreSQL
- [ ] Redis требует TLS
- [ ] Rate limiting активирован
- [ ] Application Insights логирует без PII
- [ ] Регулярные security updates через Dependabot
- [ ] WAF настроен (опционально, через Azure Front Door)

## Troubleshooting

### Backend не запускается

1. Проверьте логи:
```bash
az webapp log tail --name drug-interaction-api --resource-group drug-interaction-rg
```

2. Проверьте health endpoint:
```bash
curl https://drug-interaction-api.azurewebsites.net/health
```

3. Проверьте переменные окружения в Portal

### OpenAI API errors

- Проверьте квоты API
- Проверьте секрет в Key Vault
- Проверьте rate limiting settings

### База данных недоступна

- Проверьте firewall правила PostgreSQL
- Проверьте connection string
- Проверьте, что Allow Azure Services включено

## Стоимость оптимизация

1. **Используйте Reserved Instances для долгосрочных проектов**
2. **Настройте auto-scaling для оптимального использования**
3. **Используйте Redis только когда нужно (можно отключить в dev)**
4. **Мониторьте OpenAI token usage и настройте лимиты**
5. **Используйте B-tier App Service для dev/staging**

## Поддержка

Для вопросов и проблем создайте issue в GitHub репозитории.