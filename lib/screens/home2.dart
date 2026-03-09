import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus_hub_flutter_firebase/model/extension.dart';
import 'package:nexus_hub_flutter_firebase/screens/home.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(onPressed: () => _signOut(), child: Text('LogOut')),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return HomePage();
          },
        ),
        //
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      context.showSnackBar(
        message: '${e.message} - ${e.code}',
        color: Colors.red,
      );
    }
  }
}
