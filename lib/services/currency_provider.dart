import 'package:flutter/material.dart';

enum AppCurrency { usd, idr }

class CurrencyProvider extends ChangeNotifier {
  AppCurrency _currency = AppCurrency.usd;

  AppCurrency get currency => _currency;
  String get currencySymbol => _currency == AppCurrency.usd ? '\$' : 'Rp';
  String get currencyName => _currency == AppCurrency.usd ? 'Dollar (\$)' : 'Indonesian Rupiah (Rp)';

  void setCurrency(AppCurrency newCurrency) {
    if (_currency != newCurrency) {
      _currency = newCurrency;
      notifyListeners();
    }
  }
} 