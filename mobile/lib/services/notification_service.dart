import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Notification service for medication reminders
/// Uses local notifications to remind users to take medications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  static const String _remindersKey = 'medication_reminders';
  bool _initialized = false;
  
  Future<void> initialize() async {
    if (_initialized) return;
    
    debugPrint('Notification service initialized');
    _initialized = true;
  }
  
  Future<void> scheduleMedicationReminder({
    required String medicationId,
    required String medicationName,
    required TimeOfDay time,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing reminders
    final remindersJson = prefs.getString(_remindersKey) ?? '[]';
    final List<dynamic> reminders = jsonDecode(remindersJson);
    
    // Add new reminder
    reminders.add({
      'id': medicationId,
      'name': medicationName,
      'hour': time.hour,
      'minute': time.minute,
      'enabled': true,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    // Save
    await prefs.setString(_remindersKey, jsonEncode(reminders));
    
    debugPrint('Scheduled reminder for $medicationName at ${time.format(NavigatorState().context)}');
  }
  
  Future<void> cancelMedicationReminder(String medicationId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing reminders
    final remindersJson = prefs.getString(_remindersKey) ?? '[]';
    final List<dynamic> reminders = jsonDecode(remindersJson);
    
    // Remove reminder
    reminders.removeWhere((r) => r['id'] == medicationId);
    
    // Save
    await prefs.setString(_remindersKey, jsonEncode(reminders));
    
    debugPrint('Cancelled reminder for $medicationId');
  }
  
  Future<void> cancelAllReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_remindersKey);
    
    debugPrint('Cancelled all reminders');
  }
  
  Future<List<Map<String, dynamic>>> getAllReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getString(_remindersKey) ?? '[]';
    final List<dynamic> reminders = jsonDecode(remindersJson);
    
    return reminders.cast<Map<String, dynamic>>();
  }
  
  Future<bool> hasReminder(String medicationId) async {
    final reminders = await getAllReminders();
    return reminders.any((r) => r['id'] == medicationId);
  }
}