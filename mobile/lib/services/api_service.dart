import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/medication.dart';
import '../models/check_result.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-url.azurewebsites.net/api';
  // For local development: 'http://10.0.2.2:5000/api' (Android emulator)
  
  String? _accessToken;
  
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }
  
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    _accessToken = token;
  }
  
  Map<String, String> _headers({bool includeAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    
    return headers;
  }
  
  // Auth
  Future<Map<String, dynamic>?> signInWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: _headers(),
        body: jsonEncode({'id_token': idToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access_token']);
        return data;
      }
      
      return null;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }
  
  // Medications
  Future<List<Medication>> getMedications() async {
    await _loadToken();
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medications'),
        headers: _headers(includeAuth: true),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Medication.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting medications: $e');
      return [];
    }
  }
  
  Future<Medication?> createMedication(Medication medication) async {
    await _loadToken();
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/medications'),
        headers: _headers(includeAuth: true),
        body: jsonEncode(medication.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Medication.fromJson(jsonDecode(response.body));
      }
      
      return null;
    } catch (e) {
      print('Error creating medication: $e');
      return null;
    }
  }
  
  Future<bool> deleteMedication(String id) async {
    await _loadToken();
    
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/medications/$id'),
        headers: _headers(includeAuth: true),
      );
      
      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting medication: $e');
      return false;
    }
  }
  
  // Check
  Future<String?> createCheck(List<Medication> medications, {Map<String, dynamic>? context}) async {
    await _loadToken();
    
    try {
      final requestBody = {
        'medications': medications.map((m) => m.toJson()).toList(),
        if (context != null) 'context': context,
        'options': {
          'detailed_report': true,
          'include_sources': true,
        },
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/check'),
        headers: _headers(includeAuth: true),
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 202) {
        final data = jsonDecode(response.body);
        return data['job_id'];
      }
      
      return null;
    } catch (e) {
      print('Error creating check: $e');
      return null;
    }
  }
  
  Future<CheckResult?> getCheckResult(String jobId) async {
    await _loadToken();
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check/results/$jobId'),
        headers: _headers(includeAuth: true),
      );
      
      if (response.statusCode == 200) {
        return CheckResult.fromJson(jsonDecode(response.body));
      }
      
      return null;
    } catch (e) {
      print('Error getting check result: $e');
      return null;
    }
  }
  
  Future<List<CheckResult>> getCheckHistory({int page = 1, int pageSize = 20}) async {
    await _loadToken();
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check/history?page=$page&pageSize=$pageSize'),
        headers: _headers(includeAuth: true),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CheckResult.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting check history: $e');
      return [];
    }
  }
}