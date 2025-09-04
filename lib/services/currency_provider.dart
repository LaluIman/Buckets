import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppCurrency { usd, idr }

class CurrencyProvider extends ChangeNotifier {
  static const String _currencyKey = 'selected_currency';
  static const AppCurrency _defaultCurrency = AppCurrency.usd;
  
  AppCurrency _currency = _defaultCurrency;

  AppCurrency get currency => _currency;
  String get currencySymbol => _currency == AppCurrency.usd ? '\$' : 'Rp';
  String get currencyName => _currency == AppCurrency.usd ? 'Dollar (\$)' : 'Indonesian Rupiah (Rp)';

  CurrencyProvider() {
    print('CurrencyProvider: Initializing...');
    print('CurrencyProvider: USD index: ${AppCurrency.usd.index}, IDR index: ${AppCurrency.idr.index}');
    _loadSavedCurrency();
    // Print saved currency for debugging
    printSavedCurrency();
  }

  void _loadSavedCurrency() {
    SharedPreferences.getInstance().then((prefs) {
      final savedCurrencyIndex = prefs.getInt(_currencyKey);
      print('CurrencyProvider: Retrieved index from preferences: $savedCurrencyIndex');
      
      if (savedCurrencyIndex != null) {
        _currency = AppCurrency.values[savedCurrencyIndex];
        print('CurrencyProvider: Loaded currency from preferences: ${_currency.name}');
      } else {
        _currency = _defaultCurrency;
        print('CurrencyProvider: No saved currency found, using default: ${_currency.name}');
      }
      notifyListeners();
    }).catchError((e) {
      _currency = _defaultCurrency;
      print('CurrencyProvider: Error loading currency, using default: ${_currency.name}');
      print('CurrencyProvider: Error details: $e');
      notifyListeners();
    });
  }

  Future<void> setCurrency(AppCurrency newCurrency) async {
    print('CurrencyProvider: Setting currency to: ${newCurrency.name} (index: ${newCurrency.index})');
    if (_currency != newCurrency) {
      _currency = newCurrency;
      
      // Save to SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_currencyKey, newCurrency.index);
        print('CurrencyProvider: Saved currency to preferences: ${newCurrency.name} (index: ${newCurrency.index})');
      } catch (e) {
        // Handle error saving to preferences
        print('CurrencyProvider: Error saving currency preference: $e');
      }
      
      notifyListeners();
    } else {
      print('CurrencyProvider: Currency already set to ${newCurrency.name}, no change needed');
    }
  }

  // For testing purposes
  Future<void> clearSavedCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currencyKey);
      print('CurrencyProvider: Cleared saved currency');
    } catch (e) {
      print('CurrencyProvider: Error clearing saved currency: $e');
    }
  }

  // For debugging purposes
  Future<void> printSavedCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt(_currencyKey);
      print('CurrencyProvider: Current saved index: $savedIndex');
      if (savedIndex != null) {
        print('CurrencyProvider: Current saved currency: ${AppCurrency.values[savedIndex].name}');
      } else {
        print('CurrencyProvider: No saved currency found');
      }
    } catch (e) {
      print('CurrencyProvider: Error reading saved currency: $e');
    }
  }
} 