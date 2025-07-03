import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:income_tracker/screens/splash_screen.dart';
import 'package:income_tracker/services/auth_service.dart';
import 'package:income_tracker/services/income_service.dart';
import 'package:income_tracker/utils/constants.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeData(),
        home: SplashScreen(),
      ),
    );
  }
}

