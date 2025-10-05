import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/check_result.dart';
import '../services/api_service.dart';

class CheckProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  CheckResult? _currentResult;
  List<CheckResult> _history = [];
  bool _isChecking = false;
  String? _currentJobId;
  
  CheckResult? get currentResult => _currentResult;
  List<CheckResult> get history => _history;
  bool get isChecking => _isChecking;
  
  Future<bool> startCheck(List<Medication> medications, {Map<String, dynamic>? context}) async {
    _isChecking = true;
    _currentResult = null;
    notifyListeners();
    
    try {
      final jobId = await _apiService.createCheck(medications, context: context);
      if (jobId != null) {
        _currentJobId = jobId;
        return true;
      }
    } catch (e) {
      print('Error starting check: $e');
    }
    
    _isChecking = false;
    notifyListeners();
    return false;
  }
  
  Future<CheckResult?> pollResult() async {
    if (_currentJobId == null) return null;
    
    try {
      final result = await _apiService.getCheckResult(_currentJobId!);
      
      if (result != null) {
        if (result.status == 'completed') {
          _currentResult = result;
          _isChecking = false;
          notifyListeners();
          return result;
        } else if (result.status == 'failed') {
          _isChecking = false;
          notifyListeners();
          return null;
        }
        // Still processing, continue polling
      }
    } catch (e) {
      print('Error polling result: $e');
    }
    
    return null;
  }
  
  Future<void> loadHistory() async {
    try {
      _history = await _apiService.getCheckHistory();
      notifyListeners();
    } catch (e) {
      print('Error loading history: $e');
    }
  }
  
  void clearCurrentResult() {
    _currentResult = null;
    _currentJobId = null;
    _isChecking = false;
    notifyListeners();
  }
}