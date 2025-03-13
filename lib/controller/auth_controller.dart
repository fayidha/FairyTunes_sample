import 'package:dupepro/controller/session.dart';
import 'package:dupepro/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

  class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User
  Future<String?> registerUser(String name, String email,
      String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;
      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(user.uid).set(user.toMap());

      return uid; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  // Login User
  Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(
          userCredential.user!.uid).get();

      if (!userDoc.exists) {
        return "User not found"; // Prevents unauthorized logins
      }
      await Session.saveSession(email, userId);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  // Logout User
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // Reset Password (Sends email)
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  // Update Password in Firestore
  Future<String?> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        await _firestore.collection("users").doc(user.uid).update({
          "password": newPassword, // Update in Firestore
        });
        return null;
      } else {
        return "User not logged in";
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Get current user's name and email
  Future<Map<String, String?>> getCurrentUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return {
        'name': user.displayName,
        'email': user.email,
      };
    }
    return {
      'name': null,
      'email': null,
    };
  }

  // Register user and save details to Firestore
  Future<String?> register(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Save user details to Firestore
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
      });

      return uid; // Return UID for navigation
    } catch (e) {
      print('Registration Error: $e');
      return null;
    }
  }

  }

