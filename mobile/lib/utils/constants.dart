class AppConstants {
  // API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api', // Android emulator
  );
  
  // AdMob
  static const String adMobAppId = 'ca-app-pub-3940256099942544~3347511713'; // Test ID
  static const String adMobInterstitialId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String adMobBannerId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  
  // In-App Purchase
  static const String premiumSubscriptionId = 'premium_monthly';
  
  // Rate Limiting
  static const int freeUserDailyLimit = 5;
  static const int premiumUserDailyLimit = 100;
  
  // Polling
  static const Duration checkPollingInterval = Duration(seconds: 3);
  static const int maxPollingAttempts = 60; // 3 minutes max
  
  // Cache
  static const Duration cacheExpiry = Duration(hours: 48);
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  
  // Medication frequencies
  static const List<Map<String, String>> medicationFrequencies = [
    {'value': 'once_daily', 'label': '1 раз в день'},
    {'value': 'twice_daily', 'label': '2 раза в день'},
    {'value': 'three_times_daily', 'label': '3 раза в день'},
    {'value': 'four_times_daily', 'label': '4 раза в день'},
    {'value': 'as_needed', 'label': 'По необходимости'},
  ];
  
  // Medication routes
  static const List<Map<String, String>> medicationRoutes = [
    {'value': 'oral', 'label': 'Перорально'},
    {'value': 'topical', 'label': 'Наружно'},
    {'value': 'injection', 'label': 'Инъекция'},
    {'value': 'inhaled', 'label': 'Ингаляция'},
    {'value': 'sublingual', 'label': 'Подъязычно'},
  ];
  
  // Units
  static const List<String> medicationUnits = [
    'mg',
    'g',
    'ml',
    'mcg',
    'IU',
    'таб',
    'капс',
  ];
  
  // Emergency numbers
  static const String emergencyNumber = '112';
  static const String medicalHelplineNumber = '103';
  
  // Legal
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String supportEmail = 'support@example.com';
  
  // Disclaimer
  static const String medicalDisclaimer = 
    'Это приложение предоставляет информационные материалы о возможных '
    'взаимодействиях лекарств. Оно НЕ предназначено для замены '
    'профессиональной медицинской консультации, диагностики или лечения. '
    'Всегда консультируйтесь с квалифицированным медицинским специалистом.';
}