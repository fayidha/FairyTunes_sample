import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dupepro/model/teacher_model.dart';

class TeacherController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generate a unique teacher ID
  String _generateTeacherId() {
    return 'TEACHER-${DateTime.now().millisecondsSinceEpoch}';
  }

  // Change the registration method to accept parameters
  Future<String?> registerTeacher({
    required String name,
    required String phone,
    required String email,
    required String category,
    required String qualification,
    required String experience,
    required String address,
    String? imageUrl,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return "User not logged in";
      }

      String teacherId = _generateTeacherId();
      Teacher teacher = Teacher(
        uid: user.uid,
        name: name,
        email: user.email!,
        phone: phone,
        category: category,
        qualification: qualification,
        experience: experience,
        address: address,
        imageUrl: imageUrl,
      );

      await _firestore.collection('teachers').doc(teacherId).set(teacher.toMap());
      return null; // Success
    } catch (e) {
      print("Error registering teacher: $e");
      return "Failed to register teacher";
    }
  }


  Future<List<Teacher>> getTeachers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('teachers').get();
      return snapshot.docs
          .map((doc) => Teacher.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching teachers: $e");
      return [];
    }
  }

  //fetch


  Future<Teacher?> getTeacherById(String teacherId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('teachers').doc(teacherId).get();
      if (doc.exists) {
        return Teacher.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error fetching teacher: $e");
      return null;
    }
  }
}
