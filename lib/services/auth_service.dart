import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? get user => _auth.currentUser;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    debugPrint('AuthProvider: Initializing...');
    _auth.authStateChanges().listen((User? user) {
      _isInitialized = true;
      debugPrint('AuthProvider: Auth state changed - user: ${user?.uid ?? 'null'}');
      debugPrint('AuthProvider: User email: ${user?.email ?? 'null'}');
      debugPrint('AuthProvider: User display name: ${user?.displayName ?? 'null'}');
      debugPrint('AuthProvider: User is email verified: ${user?.emailVerified ?? 'null'}');
      debugPrint('AuthProvider: User provider data: ${user?.providerData.map((e) => e.providerId).toList()}');
      notifyListeners();
    });
    
    // Also check current user on initialization
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      debugPrint('AuthProvider: Current user found on initialization: ${currentUser.uid}');
      _isInitialized = true;
      notifyListeners();
    }
    
    // Print current user info for debugging
    printCurrentUserInfo();
  }

  Future<void> signInWithGoogle() async {
    try {
      debugPrint('AuthProvider: Starting Google sign in...');
      _isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('AuthProvider: Google sign in cancelled by user');
        return;
      }

      debugPrint('AuthProvider: Google user obtained: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      debugPrint('AuthProvider: Google authentication obtained');
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('AuthProvider: Signing in with Firebase...');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      debugPrint('AuthProvider: Successfully signed in: ${userCredential.user?.uid}');
      
      // Verify the user is properly signed in
      if (userCredential.user != null) {
        debugPrint('AuthProvider: User verification - UID: ${userCredential.user!.uid}');
        debugPrint('AuthProvider: User verification - Email: ${userCredential.user!.email}');
        debugPrint('AuthProvider: User verification - Email verified: ${userCredential.user!.emailVerified}');
      }
    } catch (e) {
      debugPrint('AuthProvider: Error signing in with Google: $e');
      // Re-throw the error so the UI can handle it
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('AuthProvider: Starting sign out...');
      await _googleSignIn.signOut();
      debugPrint('AuthProvider: Google sign out completed');
      await _auth.signOut();
      debugPrint('AuthProvider: Firebase sign out completed');
    } catch (e) {
      debugPrint('AuthProvider: Error signing out: $e');
      rethrow;
    }
  }

  // Method to check if user is currently signed in
  bool get isSignedIn => _auth.currentUser != null;
  
  // Method to get current user info for debugging
  void printCurrentUserInfo() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      debugPrint('AuthProvider: Current user info:');
      debugPrint('  UID: ${currentUser.uid}');
      debugPrint('  Email: ${currentUser.email}');
      debugPrint('  Display name: ${currentUser.displayName}');
      debugPrint('  Email verified: ${currentUser.emailVerified}');
      debugPrint('  Provider data: ${currentUser.providerData.map((e) => e.providerId).toList()}');
    } else {
      debugPrint('AuthProvider: No current user');
    }
  }
}