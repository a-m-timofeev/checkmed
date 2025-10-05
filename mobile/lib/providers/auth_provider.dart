import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token != null) {
      // Token exists, assume authenticated
      // In production, validate token with backend
      _isAuthenticated = true;
      
      // Load user data
      final userData = prefs.getString('user_data');
      if (userData != null) {
        // Parse and set user
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      
      if (idToken == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Send to backend
      final response = await _apiService.signInWithGoogle(idToken);
      
      if (response != null) {
        _user = User.fromJson(response['user']);
        _isAuthenticated = true;
        
        // Save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', response['user'].toString());
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Error signing in: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_data');
    
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}