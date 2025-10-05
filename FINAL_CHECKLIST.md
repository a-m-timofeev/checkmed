# Pre-Production Checklist

Чек-лист перед запуском Drug Interaction Checker в production.

## 🔐 Безопасность

### Backend

- [ ] Все секреты в Azure Key Vault (не в коде!)
  - [ ] OpenAI API Key
  - [ ] JWT Secret Key
  - [ ] Google OAuth Client Secret
  - [ ] PostgreSQL password
  - [ ] Redis connection string

- [ ] HTTPS enforced везде
  - [ ] App Service HTTPS Only enabled
  - [ ] HSTS headers настроены
  - [ ] Certificate валиден

- [ ] CORS настроен правильно
  - [ ] Не использует `AllowAny` в production
  - [ ] Указаны конкретные origins

- [ ] Rate Limiting активирован
  - [ ] Free tier: 5 requests/day
  - [ ] Premium tier: 100 requests/day
  - [ ] Настроены правильные лимиты

- [ ] Logging без PII
  - [ ] Медицинские данные не логируются
  - [ ] Email/имена редактируются в логах
  - [ ] Application Insights правильно настроен

- [ ] Input Validation
  - [ ] Все endpoints валидируют входные данные
  - [ ] XSS protection
  - [ ] SQL Injection protection (EF Core)

- [ ] Authentication & Authorization
  - [ ] JWT токены с коротким TTL (60 min)
  - [ ] Refresh tokens работают
  - [ ] Google OAuth правильно верифицируется на сервере

### Mobile

- [ ] Секреты не в коде
  - [ ] API keys в конфигурации
  - [ ] Google OAuth Client ID обфусцирован

- [ ] Certificate Pinning (опционально, для высокой безопасности)

- [ ] Локальное хранилище зашифровано
  - [ ] SQLite encryption enabled
  - [ ] Sensitive data encrypted

- [ ] Permissions минимальные
  - [ ] Запрашиваются только необходимые permissions

## 📱 Mobile App

### Конфигурация

- [ ] Package name/Bundle ID финальный
  - Android: `com.yourdomain.druginteraction`
  - iOS: `com.yourdomain.druginteraction`

- [ ] App version обновлена
  - [ ] version в pubspec.yaml: `1.0.0+1`

- [ ] API URL production
  - [ ] В constants.dart указан production URL
  - [ ] Не осталось localhost/test URLs

- [ ] Google Sign-In production credentials
  - [ ] Android: SHA-1 fingerprint release keystore
  - [ ] iOS: Bundle ID зарегистрирован
  - [ ] google-services.json (Android) актуален
  - [ ] GoogleService-Info.plist (iOS) актуален

- [ ] AdMob production IDs
  - [ ] App ID заменён с test на production
  - [ ] Ad Unit IDs заменены
  - [ ] AndroidManifest.xml обновлён
  - [ ] Info.plist обновлён

- [ ] In-App Purchases настроены
  - [ ] Products созданы в Google Play Console
  - [ ] Products созданы в App Store Connect
  - [ ] IDs совпадают в коде

### Сборка

- [ ] Android release build
  - [ ] Keystore создан
  - [ ] key.properties настроен
  - [ ] ProGuard rules проверены
  - [ ] App Bundle (.aab) собран
  - [ ] Протестирован release build

- [ ] iOS release build
  - [ ] Provisioning profile создан
  - [ ] Code signing настроен
  - [ ] Archive создан
  - [ ] Протестирован на physical device

### Testing

- [ ] Функциональное тестирование
  - [ ] Onboarding flow
  - [ ] Sign-in/Sign-out
  - [ ] Add/Edit/Delete medications
  - [ ] Check interactions
  - [ ] View history
  - [ ] Settings (export, delete account)

- [ ] Performance testing
  - [ ] App запускается < 3 секунды
  - [ ] Навигация плавная (60 fps)
  - [ ] Нет memory leaks
  - [ ] Battery usage приемлемый

- [ ] Network testing
  - [ ] Работает на 3G/4G/5G
  - [ ] Offline handling
  - [ ] Slow network handling
  - [ ] Retry logic работает

- [ ] Device testing
  - [ ] Различные размеры экранов
  - [ ] Различные версии Android (API 21+)
  - [ ] Различные версии iOS (12+)
  - [ ] Tablets

### Store Preparation

- [ ] Google Play Store
  - [ ] Store listing заполнен
    - [ ] Title (макс 50 символов)
    - [ ] Short description (макс 80 символов)
    - [ ] Full description
  - [ ] Screenshots (минимум 2)
    - [ ] Phone screenshots
    - [ ] Tablet screenshots (опционально)
  - [ ] Feature graphic (1024x500)
  - [ ] App icon (512x512)
  - [ ] Privacy Policy URL
  - [ ] Content rating заполнен
  - [ ] Pricing & Distribution настроены
  - [ ] Age restrictions установлены

- [ ] Apple App Store
  - [ ] App Store listing заполнен
    - [ ] Name
    - [ ] Subtitle
    - [ ] Description
  - [ ] Screenshots (все требуемые размеры)
  - [ ] Preview video (опционально)
  - [ ] App icon
  - [ ] Privacy Policy URL
  - [ ] Age rating
  - [ ] Pricing
  - [ ] App Store Review Information

## 🖥️ Backend

### Azure Resources

- [ ] Resource Group создана
- [ ] App Service Plan (минимум B1)
- [ ] App Service/Container Apps
  - [ ] Custom domain (опционально)
  - [ ] SSL certificate
  - [ ] Auto-scaling настроен (опционально)
- [ ] PostgreSQL Flexible Server
  - [ ] Firewall rules настроены
  - [ ] Backups enabled
  - [ ] Высокая доступность (опционально)
- [ ] Redis Cache
  - [ ] TLS enabled
  - [ ] Правильный pricing tier
- [ ] Key Vault
  - [ ] Все секреты добавлены
  - [ ] Access policies настроены
  - [ ] Managed Identity для App Service
- [ ] Application Insights
  - [ ] Связан с App Service
  - [ ] Alerts настроены
- [ ] Container Registry (если используете)
  - [ ] Docker images загружены
  - [ ] Credentials настроены

### Configuration

- [ ] Environment Variables в App Service
  - [ ] Connection strings
  - [ ] KeyVault URL
  - [ ] CORS origins
  - [ ] Rate limiting settings

- [ ] Database
  - [ ] Migrations применены
  - [ ] Seed data загружен (если нужно)
  - [ ] Индексы созданы
  - [ ] Backup strategy

- [ ] Monitoring
  - [ ] Application Insights работает
  - [ ] Alerts настроены (errors, high latency, etc.)
  - [ ] Log retention policy
  - [ ] Cost alerts

### Performance

- [ ] Caching работает
  - [ ] Redis connection работает
  - [ ] TTL правильно настроен

- [ ] Database optimized
  - [ ] Индексы на часто запрашиваемых полях
  - [ ] Connection pooling

- [ ] API optimization
  - [ ] Pagination на списках
  - [ ] Compression enabled
  - [ ] Async/await везде

## 📝 Compliance & Legal

### GDPR

- [ ] Privacy Policy опубликована
  - [ ] Объясняет сбор данных
  - [ ] Объясняет использование данных
  - [ ] Объясняет права пользователей

- [ ] Terms of Service опубликованы

- [ ] Cookie Policy (если используются)

- [ ] Data Processing Agreement (если нужно)

- [ ] User Rights implemented
  - [ ] Right to access (export data)
  - [ ] Right to deletion (delete account)
  - [ ] Right to portability

- [ ] Consent management
  - [ ] Explicit consent на сбор данных
  - [ ] Opt-in для маркетинга
  - [ ] Age verification (если нужно)

### Medical Disclaimer

- [ ] Disclaimer отображается в app
  - [ ] Onboarding screen
  - [ ] Results screen
  - [ ] Settings/About

- [ ] Disclaimer ясно говорит:
  - Это только информация
  - Не заменяет врача
  - Не для критических медицинских решений
  - Всегда консультируйтесь с профессионалом

### Licensing

- [ ] OpenAI Terms of Service соблюдены
- [ ] RxNorm attribution (если требуется)
- [ ] Third-party licenses включены
  - [ ] В app (About screen)
  - [ ] В store listings

## 🧪 Testing

### Unit Tests

- [ ] Backend unit tests проходят
  - [ ] Coverage > 70%
  - [ ] Critical paths покрыты

- [ ] Mobile unit tests проходят
  - [ ] Models тестируются
  - [ ] Services тестируются

### Integration Tests

- [ ] API endpoints тестируются
  - [ ] Happy paths
  - [ ] Error cases
  - [ ] Edge cases

- [ ] Database operations тестируются

### E2E Tests

- [ ] Критические user flows
  - [ ] Sign up/Sign in
  - [ ] Add medication
  - [ ] Check interaction
  - [ ] View history

### Security Testing

- [ ] Basic security scan
  - [ ] OWASP Top 10 checked
  - [ ] SQL Injection tests
  - [ ] XSS tests
  - [ ] Auth bypass tests

- [ ] Penetration testing (опционально, но рекомендуется)

### Load Testing

- [ ] API может обработать ожидаемую нагрузку
  - [ ] 100 concurrent users
  - [ ] 1000 requests/minute
  - [ ] Stress test до failure point

## 📊 Analytics & Monitoring

- [ ] Analytics SDK интегрирован (Firebase/App Center)
- [ ] Key events tracked
  - [ ] Sign up
  - [ ] Add medication
  - [ ] Check interaction
  - [ ] View ad
  - [ ] Purchase subscription
- [ ] Crash reporting работает
  - [ ] Sentry/Firebase Crashlytics
- [ ] Performance monitoring
  - [ ] App startup time
  - [ ] API response times
  - [ ] Screen load times

## 💰 Monetization

- [ ] AdMob настроен и тестируется
- [ ] In-App Purchases настроены
  - [ ] Products созданы
  - [ ] Prices установлены
  - [ ] Billing backend интегрирован
- [ ] Payment processor настроен (если нужно)
- [ ] Tax compliance (VAT, sales tax, etc.)

## 🚀 Deployment

### CI/CD

- [ ] GitHub Actions/Azure DevOps настроен
- [ ] Secrets в CI/CD
- [ ] Build pipeline работает
- [ ] Test pipeline работает
- [ ] Deploy pipeline работает
- [ ] Rollback strategy определена

### Backup & Disaster Recovery

- [ ] Database backups automated
  - [ ] Daily backups
  - [ ] Retention policy
  - [ ] Restore tested
- [ ] Disaster recovery plan документирован
- [ ] Recovery Time Objective (RTO) определён
- [ ] Recovery Point Objective (RPO) определён

### Monitoring & Alerting

- [ ] Uptime monitoring (Pingdom/UptimeRobot)
- [ ] Error alerts настроены
  - [ ] Email/SMS/Slack notifications
  - [ ] On-call rotation (если есть)
- [ ] Cost alerts
  - [ ] OpenAI usage
  - [ ] Azure spend
- [ ] Health checks работают

## 📢 Marketing & Launch

- [ ] Landing page создана
- [ ] Social media accounts созданы
- [ ] Press kit подготовлен
- [ ] Launch announcement готов
- [ ] Beta testers recruited (опционально)
- [ ] App Store Optimization (ASO)
  - [ ] Keywords researched
  - [ ] Title optimized
  - [ ] Description optimized
  - [ ] Screenshots A/B tested

## 📞 Support

- [ ] Support email настроен
- [ ] FAQ документ создан
- [ ] Support ticketing system (опционально)
- [ ] Response time SLA определён

## ✅ Final Checks

- [ ] Весь код в git и pushed
- [ ] Sensitive data удалены из git history
- [ ] .gitignore правильно настроен
- [ ] Dependencies обновлены
- [ ] Security vulnerabilities исправлены
- [ ] Documentation complete
  - [ ] README
  - [ ] API documentation
  - [ ] Deployment guide
  - [ ] Troubleshooting guide
- [ ] Team trained на использование и поддержку

---

## 🎯 Launch Day Checklist

**За 1 день:**
- [ ] Final smoke tests на production
- [ ] Team meeting - роли и ответственности
- [ ] Monitoring dashboards открыты
- [ ] On-call schedule установлен

**В Launch Day:**
- [ ] Publish в stores
- [ ] Announce на social media
- [ ] Monitor errors/crashes
- [ ] Monitor user feedback
- [ ] Be ready для hotfixes

**После запуска:**
- [ ] Collect user feedback
- [ ] Monitor metrics
- [ ] Plan updates
- [ ] Celebrate! 🎉

---

**Примечание:** Этот чек-лист comprehensive, но не обязательно все пункты критичны для первого релиза. Приоритизируйте безопасность, стабильность и compliance.