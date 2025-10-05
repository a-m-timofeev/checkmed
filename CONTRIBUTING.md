# Contributing to Drug Interaction Checker

Спасибо за интерес к проекту! Мы приветствуем вклад от всех.

## Как внести вклад

### Reporting Bugs

Если вы нашли баг, пожалуйста создайте issue с:
- Описанием проблемы
- Шагами для воспроизведения
- Ожидаемым и фактическим поведением
- Screenshots (если применимо)
- Environment info (OS, .NET version, Flutter version)

### Suggesting Features

Для предложения новой функции:
1. Проверьте, нет ли уже такого issue
2. Создайте новый issue с тегом "enhancement"
3. Опишите функцию и её пользу
4. Приведите примеры использования

### Pull Requests

1. Fork репозиторий
2. Создайте feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit изменения (`git commit -m 'Add some AmazingFeature'`)
4. Push в branch (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

#### PR Guidelines

- Следуйте code style проекта
- Добавьте тесты для новой функциональности
- Обновите документацию
- Убедитесь, что все тесты проходят
- Один PR = одна фича (не смешивайте несколько фич)

## Code Style

### Backend (C#)
- Используйте Microsoft C# coding conventions
- Async/await для всех I/O операций
- Dependency Injection для сервисов
- Логирование через ILogger

### Mobile (Flutter/Dart)
- Следуйте [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Используйте Provider для state management
- Async/await для асинхронных операций
- Комментируйте сложные участки кода

## Testing

### Backend
```bash
cd backend/DrugInteractionAPI.Tests
dotnet test
```

### Mobile
```bash
cd mobile
flutter test
```

## Commit Messages

Используйте [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - новая функция
- `fix:` - исправление бага
- `docs:` - изменения в документации
- `style:` - форматирование кода
- `refactor:` - рефакторинг без изменения функциональности
- `test:` - добавление тестов
- `chore:` - изменения в build процессе

Примеры:
```
feat: add medication autocomplete
fix: resolve null reference in CheckService
docs: update deployment guide
```

## Code Review Process

1. Maintainer проверит PR в течение 48 часов
2. Могут быть запрошены изменения
3. После approval, PR будет merged
4. Ваша ветка будет удалена

## Community Guidelines

- Будьте уважительны к другим
- Конструктивная критика приветствуется
- Помогайте новичкам
- Следуйте [Code of Conduct](CODE_OF_CONDUCT.md)

## License

Внося вклад, вы соглашаетесь с лицензией проекта.

## Questions?

Не стесняйтесь задавать вопросы через GitHub Discussions или issues.