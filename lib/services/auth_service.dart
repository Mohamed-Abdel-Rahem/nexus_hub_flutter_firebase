import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus_hub_flutter_firebase/model/extension.dart';
import 'package:nexus_hub_flutter_firebase/model/user_model.dart';
import 'package:nexus_hub_flutter_firebase/screens/data_read.dart';
import 'package:nexus_hub_flutter_firebase/services/firestore_service.dart';

const int _maxRetries = 20;

class AuthService {
  // Singleton Pattern
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer;
  int _retryCount = 0;

  // Function to handle user registration
  Future<void> register(
    BuildContext context, {
    required UserModel userAccount,
  }) async {
    try {
      // Always trim email and password to avoid malformed credential errors
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: userAccount.email.trim(),
            password: userAccount.password.trim(),
          );

      User? user = userCredential.user;

      if (user != null) {
        // Send verification link to user's email
        await user.sendEmailVerification();
        FirestoreService.instance.addDataToFirestore(
          userModel: userAccount,
          context: context,
        );
        if (context.mounted) {
          context.showSnackBar(
            message: 'Register Success! Check your email to verify.',
          );
        }

        // Start polling timer to detect when user verifies their email
        _startEmailVerificationTimer(context, userAccount);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        context.showSnackBar(message: '${e.message}', color: Colors.red);
      }
    }
  }

  // Timer that checks email verification status every 3 seconds
  void _startEmailVerificationTimer(
    BuildContext context,
    UserModel userAccount,
  ) {
    _timer?.cancel();
    _retryCount = 0;

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _retryCount++;

      // Stop the timer if max retries are reached (approx. 60 seconds)
      if (_retryCount >= _maxRetries) {
        timer.cancel();
        _timer = null;
        if (context.mounted) {
          context.showSnackBar(
            message:
                'Verification timed out. Please check your email and try again.',
            color: Colors.orange,
          );
        }
        return;
      }

      // Fetch the latest user data from Firebase servers
      await _auth.currentUser?.reload();
      User? user = _auth.currentUser;

      // If email is verified, stop timer and proceed
      if (user != null && user.emailVerified) {
        timer.cancel();
        _timer = null;

        if (context.mounted) {
          context.showSnackBar(message: 'Email Verified! try to login.');
        }
      }
    });
  }

  // Clear timer when service is no longer needed
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  // Function to handle user login
  Future<void> login({
    required UserModel userModel,
    required BuildContext context,
  }) async {
    try {
      // Sign in with trimmed credentials
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: userModel.email.trim(),
        password: userModel.password.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Only allow entry if email is verified
        if (user.emailVerified) {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DataRead()),
            );
          }
        } else {
          await _auth.signOut();
          // Notify user to verify email before logging in
          if (context.mounted) {
            context.showSnackBar(
              message: 'Please verify your email first!',
              color: Colors.orange,
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        context.showSnackBar(message: '${e.message}', color: Colors.red);
      }
    }
  }
}
