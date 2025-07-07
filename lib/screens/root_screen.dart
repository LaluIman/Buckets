import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:income_tracker/services/auth_service.dart';
import 'package:income_tracker/screens/home_screen.dart';
import 'package:income_tracker/screens/auth_screen.dart';

class RootScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user != null) {
          return HomeScreen();
        } else {
          return AuthScreen();
        }
      },
    );
  }
} 