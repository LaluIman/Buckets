import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:income_tracker/services/auth_service.dart';
import 'package:income_tracker/screens/home_screen.dart';
import 'package:income_tracker/screens/auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isInitialized) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
          );
        }
        
        if (authProvider.isSignedIn) {
          return HomeScreen();
        }
        
        return AuthScreen();
      },
    );
  }
} 