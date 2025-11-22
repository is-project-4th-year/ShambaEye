import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  AppAuthProvider? _authProvider;

  // Initialize with auth provider (call this in main.dart)
  void initialize(AppAuthProvider authProvider) {
    _authProvider = authProvider;
    // Apply user preference on initialization
    _applyUserPreference();
  }

  Locale get locale {
    // If explicit locale is set, use it
    if (_locale != null) return _locale!;
    
    // If user is logged in, use their preference
    if (_authProvider?.isLoggedIn == true && _authProvider?.languagePreference != 'system') {
      return Locale(_authProvider!.languagePreference);
    }
    
    // Fallback: Use device locale or default to English
    return _getDeviceLocale();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    
    // Save to user profile if logged in
    if (_authProvider?.isLoggedIn == true) {
      await _authProvider!.updateLanguagePreference(locale.languageCode);
    }
    
    notifyListeners();
  }

  Future<void> clearLocale() async {
    _locale = null;
    
    // Save to user profile if logged in
    if (_authProvider?.isLoggedIn == true) {
      await _authProvider!.updateLanguagePreference('system');
    }
    
    notifyListeners();
  }

  // Call this when user logs in to apply their preference
  void applyUserPreference() {
    if (_authProvider?.isLoggedIn == true && _authProvider?.languagePreference != 'system') {
      _locale = Locale(_authProvider!.languagePreference);
    } else {
      _locale = null; // Use system default
    }
    notifyListeners();
  }

  // Private method to apply user preference on initialization
  void _applyUserPreference() {
    if (_authProvider?.isLoggedIn == true && _authProvider?.languagePreference != 'system') {
      _locale = Locale(_authProvider!.languagePreference);
    }
  }

  // Get device locale with fallback to English
  Locale _getDeviceLocale() {
    try {
      final platformLocale = WidgetsBinding.instance.window.locale;
      
      // Support for Swahili (sw) and English (en)
      if (platformLocale.languageCode.contains('sw')) {
        return const Locale('sw');
      }
      
      // Default to English for all other cases
      return const Locale('en');
    } catch (e) {
      // Fallback in case of any error
      return const Locale('en');
    }
  }

  // Helper to check if we're using system default
  bool get isUsingSystemDefault => _locale == null;

  // Helper to get current language code
  String get currentLanguageCode {
    if (_locale != null) return _locale!.languageCode;
    if (_authProvider?.isLoggedIn == true && _authProvider?.languagePreference != 'system') {
      return _authProvider!.languagePreference;
    }
    return _getDeviceLocale().languageCode;
  }
}