import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:nexus_hub_flutter_firebase/model/user_model.dart';
import 'package:nexus_hub_flutter_firebase/screens/auth/register.dart';
import 'package:nexus_hub_flutter_firebase/services/auth_service.dart';
import 'package:nexus_hub_flutter_firebase/widgets/customText.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool obscureText = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // خلفية نظيفة
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          // شعار المشروع (NexusHub Icon)
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hub_rounded, // أيقونة تعبر عن Nexus/Connection
              size: 70,
              color: Colors.blueAccent,
            ),
          ),

          const SizedBox(height: 25),

          Text(
            'NexusHub',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Welcome back! Login to sync your data.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),

          const SizedBox(height: 50),

          // حقل الإيميل باستخدام الـ Widget بتاعك
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
              if (value == null || !value.contains('@'))
                return 'Please enter a valid email';
              return null;
            },
          ),

          const SizedBox(height: 15),

          // حقل الباسورد باستخدام الـ Widget بتاعك
          customText(
            textHint: 'Enter your password',
            textLabel: 'Password',
            controller: passwordController,
            keyboardType: TextInputType.visiblePassword,
            prefixIcon: const Icon(
              Icons.lock_open_rounded,
              color: Colors.blueAccent,
            ),
            obsecureText: obscureText,
            suffixIcon: IconButton(
              onPressed: () => setState(() => obscureText = !obscureText),
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
            ),
            validator: (value) => (value != null && value.length < 6)
                ? 'Password must be at least 6 characters'
                : null,
          ),

          // زرار "نسيت كلمة السر" (بيضيف احترافية للـ UI)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // زرار الدخول بتصميم جديد
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
              onPressed: _isLoading ? null : _handleLogin,
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // الفاصل (Or connect with)
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("OR", style: TextStyle(color: Colors.grey[400])),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),

          const SizedBox(height: 30),

          // الانتقال للـ Sign Up
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "New to NexusHub?",
                style: TextStyle(color: Colors.grey[700]),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Create Account",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Inside LoginScreen.dart
  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Call the updated login logic
      await AuthService.instance.login(
        context: context,
        userModel: UserModel(
          email: emailController.text.trim(),
          password: passwordController.text,

          name: '', // Not needed for login
        ),
      );
    } finally {
      // Stop loading regardless of the outcome
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
