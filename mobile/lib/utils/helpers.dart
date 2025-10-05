import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }
  
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  static String getFrequencyLabel(String frequency) {
    switch (frequency) {
      case 'once_daily':
        return '1 раз в день';
      case 'twice_daily':
        return '2 раза в день';
      case 'three_times_daily':
        return '3 раза в день';
      case 'four_times_daily':
        return '4 раза в день';
      case 'as_needed':
        return 'По необходимости';
      default:
        return frequency;
    }
  }
  
  static String getRouteLabel(String route) {
    switch (route) {
      case 'oral':
        return 'Перорально';
      case 'topical':
        return 'Наружно';
      case 'injection':
        return 'Инъекция';
      case 'inhaled':
        return 'Ингаляция';
      case 'sublingual':
        return 'Подъязычно';
      default:
        return route;
    }
  }
  
  static String getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'danger':
        return 'Опасно';
      case 'caution':
        return 'С осторожностью';
      case 'recommendation':
        return 'Рекомендация';
      default:
        return category;
    }
  }
  
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
  
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}