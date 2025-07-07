import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:income_tracker/screens/home_screen.dart';
import 'package:income_tracker/screens/auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return AuthScreen();
      },
    );
  }
} 