import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/api_service.dart';

class MedicationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Medication> _medications = [];
  bool _isLoading = false;
  
  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;
  
  Future<void> loadMedications() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _medications = await _apiService.getMedications();
    } catch (e) {
      print('Error loading medications: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> addMedication(Medication medication) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final created = await _apiService.createMedication(medication);
      if (created != null) {
        _medications.add(created);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error adding medication: $e');
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }
  
  Future<bool> deleteMedication(String id) async {
    try {
      final success = await _apiService.deleteMedication(id);
      if (success) {
        _medications.removeWhere((m) => m.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error deleting medication: $e');
    }
    return false;
  }
  
  void clearMedications() {
    _medications.clear();
    notifyListeners();
  }
}