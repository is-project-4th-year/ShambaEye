import 'package:flutter/foundation.dart';
import '../../services/auth_service.dart';

class AppAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _userProfile;
  String _languagePreference = 'system'; // Default to system language

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile;
  String get languagePreference => _languagePreference;

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
        
        // Load language preference from user profile
        if (_userProfile != null) {
          _languagePreference = _userProfile!.preferredLanguage;
          print('🌐 Language preference loaded: $_languagePreference');
        }
      } else {
        print('ℹ️ No user logged in');
        _languagePreference = 'system'; // Reset to default when not logged in
      }
      
    } catch (e) {
      print('❌ Error checking auth status: $e');
      _errorMessage = 'Failed to check authentication status';
      _isLoggedIn = false; // Ensure we don't get stuck
      _languagePreference = 'system'; // Reset to default on error
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
        
        // Load language preference after login
        if (_userProfile != null) {
          _languagePreference = _userProfile!.preferredLanguage;
          print('🌐 Language preference set after login: $_languagePreference');
        }
        
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
        _languagePreference = 'system'; // Default for new users
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
      
      // Set language preference from profile
      _languagePreference = profile.preferredLanguage;
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateLanguagePreference(String languageCode) async {
    if (!_isLoggedIn) {
      print('⚠️ Cannot update language preference: User not logged in');
      return;
    }
    
    print('🌐 Updating language preference to: $languageCode');
    
    // Update local state immediately for responsive UI
    final previousPreference = _languagePreference;
    _languagePreference = languageCode;
    notifyListeners();
    
    try {
      // Update in Firestore
      await _authService.updateUserLanguagePreference(languageCode);
      
      // Update local profile if it exists
      if (_userProfile != null) {
        _userProfile = _userProfile!.copyWith(preferredLanguage: languageCode);
      }
      
      print('✅ Language preference updated successfully');
    } catch (e) {
      print('❌ Error updating language preference: $e');
      
      // Revert local state on error
      _languagePreference = previousPreference;
      notifyListeners();
      
      _errorMessage = 'Failed to update language preference';
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _isLoggedIn = false;
    _userProfile = null;
    _languagePreference = 'system'; // Reset to default on logout
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper method to get the actual locale to use
  String get effectiveLanguage {
    if (_languagePreference == 'system') {
      // Return device locale or default to English
      return 'en'; // You can enhance this to detect device locale
    }
    return _languagePreference;
  }
}