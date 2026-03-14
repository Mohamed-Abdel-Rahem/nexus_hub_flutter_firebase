import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:nexus_hub_flutter_firebase/model/user_model.dart';
import 'package:nexus_hub_flutter_firebase/services/auth_service.dart';
import 'package:nexus_hub_flutter_firebase/widgets/customText.dart';

import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool obscureText = true;

  @override
  void dispose() {
    AuthService.instance.dispose(); // بنوقف التايمر من السيرفيس
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        opacity: 0.5,
        progressIndicator: const CircularProgressIndicator(
          color: Colors.blueAccent,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // محاذاة النص لليسار أشيك
        children: [
          const SizedBox(height: 20),
          Text(
            'Create Account',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Connect with NexusHub and sync your data securely across all devices.",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),

          const SizedBox(height: 40),

          // حقل الاسم
          customText(
            textHint: 'Full Name',
            textLabel: 'Name',
            controller: nameController,
            keyboardType: TextInputType.name,
            prefixIcon: const Icon(
              Icons.person_outline,
              color: Colors.blueAccent,
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Name Required' : null,
          ),

          const SizedBox(height: 15),

          // حقل الإيميل
          customText(
            textHint: 'name@example.com',
            textLabel: 'Email Address',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Colors.blueAccent,
            ),
            validator: (value) {
              if (value == null || !value.contains('@')) return 'Invalid email';
              return null;
            },
          ),

          const SizedBox(height: 15),

          // حقل الباسورد
          customText(
            textHint: 'Minimum 6 characters',
            textLabel: 'Password',
            controller: passwordController,
            keyboardType: TextInputType.visiblePassword,
            obsecureText: obscureText,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.blueAccent,
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(() => obscureText = !obscureText),
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
            ),
            validator: (value) =>
                (value != null && value.length < 6) ? 'Too short' : null,
          ),

          const SizedBox(height: 30),

          // زرار الـ Sign Up
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _handleRegister,
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // النص السفلي
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account?",
                style: TextStyle(color: Colors.grey[700]),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // حتة احترافية: شروط الخدمة
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "By signing up, you agree to our Terms of Service and Privacy Policy.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    // 1. التحقق من صحة الحقول
    if (!formKey.currentState!.validate()) return;

    // 2. بدأ التحميل
    setState(() => _isLoading = true);

    try {
      // 3. تنفيذ التسجيل
      await AuthService.instance.register(
        context,
        userAccount: UserModel(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        ),
      );

      // 4. في حالة النجاح
      if (mounted) {
        nameController.clear();
        emailController.clear();
        passwordController.clear();
      }
    } catch (e) {
      debugPrint("Error in Register Screen: $e");
    } finally {
      // 5. إنهاء التحميل في كل الحالات
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
