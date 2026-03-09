// ignore_for_file: use_build_context_synchronously

import 'dart:async'; // 👈 ضروري عشان الـ Timer
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus_hub_flutter_firebase/model/extension.dart';
import 'package:nexus_hub_flutter_firebase/screens/home2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer; // 👈 متغير الـ Timer

  @override
  void dispose() {
    _timer?.cancel(); // 👈 لازم نقفله عشان الـ Memory Leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () =>
                    _login('mohamedar2002mail@gmail.com', '123456'),
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _register(
                  'mohamedar2002mail@gmail.com',
                  '123456',
                  'moamed',
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await user.reload(); // 👈 تحديث الحالة قبل التشيك
        if (user.emailVerified) {
          context.showSnackBar(message: 'Login Success');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage2()),
          );
        } else {
          context.showSnackBar(
            message: 'Please verify your email first!',
            color: Colors.orange,
          );
          await user.sendEmailVerification(); // إعادة إرسال لو مش مفعل
        }
      }
    } on FirebaseAuthException catch (e) {
      context.showSnackBar(message: '${e.message}', color: Colors.red);
    }
  }

  Future<void> _register(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        context.showSnackBar(
          message: 'Register Success! Please check your email.',
        );

        // 1. إرسال الإيميل
        await user.sendEmailVerification();

        // 2. تشغيل التايمر للتحقق التلقائي كل 3 ثواني
        _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
          checkVerificationEmail();
        });
      }
    } on FirebaseAuthException catch (e) {
      context.showSnackBar(message: '${e.message}', color: Colors.red);
    }
  }

  void checkVerificationEmail() async {
    // ⚠️ الخطوة السحرية: لازم reload عشان السيرفر يسمع في الموبايل
    await _auth.currentUser?.reload();

    if (_auth.currentUser != null && _auth.currentUser!.emailVerified) {
      _timer?.cancel(); // وقف العداد خلاص نجحنا

      if (mounted) {
        context.showSnackBar(message: 'Email Verified! Welcome.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage2()),
        );
      }
    }
  }
}
