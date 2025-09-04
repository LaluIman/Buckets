import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:income_tracker/screens/splash_screen.dart';
import 'package:income_tracker/screens/settings_screen.dart';
import 'package:income_tracker/services/auth_service.dart';
import 'package:income_tracker/services/currency_provider.dart';
import 'package:income_tracker/services/income_service.dart';
import 'package:income_tracker/services/expense_service.dart';
import 'package:income_tracker/services/localization_service.dart';
import 'package:income_tracker/utils/constants.dart';
import 'package:income_tracker/utils/app_localizations.dart';
import 'package:income_tracker/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => IncomeProvider()),
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
        ChangeNotifierProvider(create: (context) => LocalizationService()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
      ],
      child: Consumer2<LocalizationService, CurrencyProvider>(
        builder: (context, localizationService, currencyProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeData(),
            locale: localizationService.locale,
            supportedLocales: LocalizationService.supportedLocales,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: SplashScreen(),
            routes: {
              '/settings': (context) => SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

