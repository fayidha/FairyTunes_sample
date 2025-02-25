import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dupepro/model/teacher_model.dart';

class TeacherController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ Register a new teacher
  Future<String?> registerTeacher({
    required String name,
    required String phone,
    required String email,
    required String category,
    required String qualification,
    required String experience,
    required String address,
    String? imageUrl,  // Image URL from Firebase Storage or users collection
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return "User not logged in";

      String uid = user.uid;
      print("🔥 DEBUG: Registering teacher with UID: $uid");

      // Create Teacher object
      Teacher teacher = Teacher(
        uid: uid,
        teacherId: uid,  // Use UID as teacherId
        name: name,
        email: email,
        phone: phone,
        category: category,
        qualification: qualification,
        experience: experience,
        address: address,
        imageUrl: imageUrl ?? "",  // Ensure imageUrl is either null or default empty
      );

      print("🔥 DEBUG: Teacher data before saving: ${teacher.toMap()}");

      // Save Teacher object to Firestore
      await _firestore.collection('teachers').doc(uid).set(
        teacher.toMap(),
        SetOptions(merge: true), // Prevents overwriting fields
      );

      print("✅ Teacher registered successfully: $uid");
      return null;  // No error
    } catch (e) {
      print("❌ Error registering teacher: $e");
      return "Failed to register teacher";
    }
  }


  /// ✅ Fetch teacher profile by Firebase Auth UID
  Future<Teacher?> getTeacherByUserId() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print("❌ No user logged in");
        return null;
      }

      DocumentSnapshot doc = await _firestore.collection('teachers').doc(user.uid).get();

      if (doc.exists) {
        print("✅ Firestore data: ${doc.data()}");
        return Teacher.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print("❌ No teacher profile found for UID: ${user.uid}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching teacher: $e");
      return null;
    }
  }

  /// ✅ Update teacher profile
  Future<String?> updateTeacherProfile(Map<String, dynamic> teacherData) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return "User not logged in";

      await _firestore.collection('teachers').doc(user.uid).update(teacherData);
      return null;
    } catch (e) {
      print("❌ Error updating teacher profile: $e");
      return "Failed to update profile";
    }
  }

  /// ✅ Check if the teacher profile exists
  Future<bool> doesTeacherExist() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      DocumentSnapshot doc = await _firestore.collection('teachers').doc(user.uid).get();
      return doc.exists;
    } catch (e) {
      print("❌ Error checking teacher existence: $e");
      return false;
    }
  }

  /// ✅ Delete teacher profile
  Future<String?> deleteTeacherProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return "User not logged in";

      await _firestore.collection('teachers').doc(user.uid).delete();
      return null;
    } catch (e) {
      print("❌ Error deleting teacher profile: $e");
      return "Failed to delete profile";
    }
  }
}
