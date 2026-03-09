import 'package:flutter/material.dart';
import 'package:nexus_hub_flutter_firebase/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nexus_hub_flutter_firebase/screens/spalshScreen.dart';
import 'firebase_options.dart';

void main() async {
  // This line user for initializing the firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FirebaseApp());
}

class FirebaseApp extends StatelessWidget {
  const FirebaseApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: SpalshScreen(),
    );
  }
}
