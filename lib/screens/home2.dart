import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nexus_hub_flutter_firebase/model/app_user.dart';
import 'package:nexus_hub_flutter_firebase/model/extension.dart';
import 'package:nexus_hub_flutter_firebase/screens/home.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(onPressed: () => _signOut(), child: Text('LogOut')),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => __saveUserData(),
            child: Text('Save user data'),
          ),
          ElevatedButton(
            onPressed: () => __readUserData(),
            child: Text('Veiw user data'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
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

  Future<void> __saveUserData() async {
    AppUser user = AppUser(
      name: 'Mohamed',
      phone: '01018134686',
      address: 'Egypt-Giza-October',
      email: _auth.currentUser!.email!,
      uid: _auth.currentUser!.uid,
    );
    await _db
        .child('users')
        .child(_auth.currentUser!.uid)
        .set(user.toMap())
        .then((value) {
          context.showSnackBar(message: 'User saved successfully.');
        });
  }

  Future<void> __readUserData() async {
    _db.child('users').child(_auth.currentUser!.uid).onValue.listen((event) {
      // print(event.snapshot.value);
      // print(event.snapshot.value.runtimeType);
      //Explicit Casting تحويل صريح
      Map<String, dynamic> data = Map.from(
        event.snapshot.value as Map<Object?, Object?>,
      );
      AppUser user = AppUser.fromMap(data);
      print(user);
    });
  }
}
/*Future<void> __readUserData() async {
    try {
      // 1. شيلنا الـ Cascade واستخدمنا الـ await صح
      final snapshot = await _db
          .child('users')
          .child(_auth.currentUser!.uid)
          .get();

      if (snapshot.exists) {
        // 2. التحويل الآمن للداتا (Casting)
        // بنستخدم Map.from عشان نتجنب مشكلة Object? vs String
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          snapshot.value as Map,
        );

        AppUser user = AppUser.fromMap(data);

        user.printUserData();
      } else {
        print("No data available for this user.");
      }
    } catch (e) {
      print("Error reading data: $e");
      context.showSnackBar(message: "Error: $e", color: Colors.red);
    }
  }*/