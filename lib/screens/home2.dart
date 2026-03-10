import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexus_hub_flutter_firebase/model/app_user.dart';
import 'package:nexus_hub_flutter_firebase/model/cloud_model.dart';
import 'package:nexus_hub_flutter_firebase/model/extension.dart';
import 'package:nexus_hub_flutter_firebase/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Reference _storageRef = FirebaseStorage.instance.ref();
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
          StreamBuilder<DocumentSnapshot>(
            // 1. مراقبة الدوكيومنت بتاع المستخدم الحالي
            stream: _firestore
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              // 2. التأكد إن الداتا وصلت
              if (snapshot.hasData && snapshot.data!.exists) {
                // 3. استخراج البيانات وتحويلها لـ Map
                var userData = snapshot.data!.data() as Map<String, dynamic>;

                // 4. الحصول على اللينك من حقل 'pic' (تأكد إنه نفس الاسم في Firestore)
                String? urlFromFirestore = userData['pic'];

                // 5. عرض الصورة لو اللينك موجود، أو عرض أيقونة افتراضية
                if (urlFromFirestore != null && urlFromFirestore.isNotEmpty) {
                  return CachedNetworkImage(
                    imageUrl: urlFromFirestore,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 60,
                      backgroundImage: imageProvider,
                    ),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.red),
                  );
                } else {
                  return const CircleAvatar(
                    radius: 60,
                    child: Icon(Icons.person, size: 60),
                  );
                }
              }

              // حالة التحميل (بينما يجلب الـ Stream البيانات لأول مرة)
              return const CircularProgressIndicator();
            },
          ),

          //Real time database add data
          ElevatedButton(
            onPressed: () => __saveUserData(),
            child: Text('Save user data Real time database'),
          ),
          //Real time database read data
          ElevatedButton(
            onPressed: () => __readUserData(),
            child: Text('Veiw user data Real time database'),
          ),
          //Firestore database add data
          ElevatedButton(
            onPressed: () => __saveUserDataInFireStore(),
            child: Text('Save user data firestore database'),
          ),
          //Firestore time database read data
          ElevatedButton(
            onPressed: () => __readUserDataInFireStore(),
            child: Text('Veiw user data firestore database'),
          ),
          ElevatedButton(
            onPressed: () => __uploadProfilePicture(),
            child: Text('upload profile picture'),
          ),
        ],
      ),
    );
  }

  //Firebase auth sign out
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

  //Real time database add data
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

  //Real time database read data
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

  void __saveUserDataInFireStore() {
    AppUser user = AppUser(
      name: 'Mohamed',
      phone: '01018134686',
      address: 'Egypt-Giza-October',
      email: _auth.currentUser!.email!,
      uid: _auth.currentUser!.uid,
    );
    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .set(user.toMap())
        .then((value) {
          print('data saved');
        })
        .catchError((error) => print('Failed to add user: $error'));
  }

  void __readUserDataInFireStore() {
    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) {
          print(value.data());
          print(value.data().runtimeType);
          AppUser user = AppUser.fromMap(value.data()!);
          print(user);
        })
        .catchError((error) => print('Failed to read user: $error'));
  }

  void __uploadProfilePicture() async {
    final path = await _getImage();

    if (path != null) {}
    // 2. رفع الصورة لـ Cloudinary
    CloudinaryService cloudinary = CloudinaryService();
    String? imageUrl = await cloudinary.uploadImage(File(path ?? ''));

    if (imageUrl != null) {
      // 3. تحديث الـ Firestore باللينك اللي رجع
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid) // الـ UID بتاع المستخدم الحالي
          .update({'pic': imageUrl});

      print("مبروك! الصورة ارفعت واللينك اتحفظ: $imageUrl");
    }
  }

  Future<String?> _getImage() async {
    ImagePicker picker = ImagePicker();
    XFile? xFile = await picker.pickImage(source: ImageSource.camera);
    // print(xFile?.path);
    return xFile?.path;
  }

  //FireStore database
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