import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/teacher_model.dart';


class TeacherController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTeacher(Teacher teacher) async {
    try {
      await _firestore.collection('teachers').add(teacher.toMap());
    } catch (e) {
      print("Error adding teacher: $e");
    }
  }

  // Fetch teacher data from Firestore (optional)
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
}
