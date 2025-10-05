class Validators {
  static String? medicationName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите название лекарства';
    }
    
    if (value.trim().length < 2) {
      return 'Название слишком короткое';
    }
    
    if (value.trim().length > 100) {
      return 'Название слишком длинное';
    }
    
    return null;
  }
  
  static String? dose(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Введите числовое значение';
    }
    
    if (number <= 0) {
      return 'Доза должна быть положительным числом';
    }
    
    return null;
  }
  
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите email';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Введите корректный email';
    }
    
    return null;
  }
  
  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Введите числовое значение';
    }
    
    if (age < 0 || age > 150) {
      return 'Введите корректный возраст';
    }
    
    return null;
  }
  
  static String? weight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Введите числовое значение';
    }
    
    if (weight <= 0 || weight > 500) {
      return 'Введите корректный вес';
    }
    
    return null;
  }
}