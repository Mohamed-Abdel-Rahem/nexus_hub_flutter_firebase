import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus_hub_flutter_firebase/model/extension.dart';
import 'package:nexus_hub_flutter_firebase/model/user_model.dart';

class FirestoreService {
  // Singleton Pattern
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to add user data to Firestore with error handling
  Future<void> addDataToFirestore({
    required UserModel userModel,
    required BuildContext context,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        userModel.uId = currentUser.uid;
        // Use await instead of .then for cleaner, more readable code
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .set(userModel.toMap());
      }
    } on FirebaseException catch (e) {
      // Catch specific Firebase errors (e.g., permission denied)
      if (context.mounted) {
        context.showSnackBar(
          message: 'Firebase Error: ${e.message}',
          color: Colors.red,
        );
      }
    } catch (e) {
      // Handle any other unexpected errors
      if (context.mounted) {
        context.showSnackBar(
          message: 'An unexpected error occurred: $e',
          color: Colors.red,
        );
      }
    }
  }

  // خلي الدالة ترجع UserModel? بدل void
  Future<UserModel?> readDataFromFirestore({
    required BuildContext context,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // بنستخدم await هنا أسهل وأضمن
        var value = await _firestore
            .collection('users') // تأكد إنها users بالجمع
            .doc(currentUser.uid)
            .get();

        if (value.exists && value.data() != null) {
          print('Firestore Data: ${value.data()}'); // طباعة البيانات للتأكد
          // بنرجع الموديل الجديد
          return UserModel.fromMap(value.data()!);
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar(message: 'Error: $e', color: Colors.red);
      }
    }
    return null; // لو حصل مشكلة يرجع null
  }
}
