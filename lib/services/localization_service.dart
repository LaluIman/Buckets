import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en'; // English as default
  
  Locale _locale = const Locale('en', 'US');
  
  Locale get locale => _locale;
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('id', 'ID'), // Indonesian
    Locale('en', 'US'), // English
  ];
  
  // Language names
  static const Map<String, String> languageNames = {
    'id': 'Bahasa Indonesia',
    'en': 'English',
  };
  
  LocalizationService() {
    _loadSavedLanguage();
  }
  
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
    _locale = Locale(savedLanguage, savedLanguage == 'id' ? 'ID' : 'US');
    notifyListeners();
  }
  
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode != _locale.languageCode) {
      _locale = Locale(languageCode, languageCode == 'id' ? 'ID' : 'US');
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      notifyListeners();
    }
  }
  
  String getCurrentLanguageName() {
    return languageNames[_locale.languageCode] ?? 'Unknown';
  }
  
  String getCurrentLanguageCode() {
    return _locale.languageCode;
  }
} 