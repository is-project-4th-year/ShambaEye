import 'package:flutter/foundation.dart';
import '../../services/auth_service.dart';

class AppAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _userProfile;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🔍 Checking authentication status...');
      
      // Check if user is logged in
      _isLoggedIn = await _authService.isUserLoggedIn();
      print('📱 User login status: $_isLoggedIn');
      
      if (_isLoggedIn) {
        print('🔄 Fetching user profile...');
        _userProfile = await _authService.getUserProfile();
        print('✅ User profile loaded: ${_userProfile != null}');
      } else {
        print('ℹ️ No user logged in');
      }
      
    } catch (e) {
      print('❌ Error checking auth status: $e');
      _errorMessage = 'Failed to check authentication status';
      _isLoggedIn = false; // Ensure we don't get stuck
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 Auth check completed');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        _isLoggedIn = true;
        _userProfile = await _authService.getUserProfile();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signUp(email, password);
      if (user != null) {
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> createProfile(UserProfile profile) async {
    try {
      await _authService.createUserProfile(profile);
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _isLoggedIn = false;
    _userProfile = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}