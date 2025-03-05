// import 'package:dupepro/model/notes%20model.dart';
// import 'package:file_picker/file_picker.dart';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
//
// class NoteController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final Uri uuid = Uuid(); // UUID generator
//
//   // Get the current logged-in teacher's UID
//   String? get currentTeacherId => _auth.currentUser?.uid;
//
//   // Pick files and store in Firestore
//   Future<void> pickAndUploadFiles() async {
//     if (currentTeacherId == null) return;
//
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//       allowMultiple: true,
//     );
//
//     if (result != null) {
//       for (var file in result.files) {
//         if (file.size < 5000000) {  // Limit to 5MB
//           Note note = Note(
//             noteId: uuid.v4(),  // Generate unique ID
//             name: file.name,
//             path: file.path ?? '',
//             teacherId: currentTeacherId!,
//           );
//
//           // Save note to Firestore
//           await _firestore.collection("notes").doc(note.noteId).set(note.toJson());
//         }
//       }
//     }
//   }
//
//   // Remove a note by ID
//   Future<void> removeNote(String noteId) async {
//     if (currentTeacherId == null) return;
//
//     await _firestore.collection("notes").doc(noteId).delete();
//   }
//
//   // Fetch notes for the logged-in teacher
//   Stream<List<Note>> getNotesForTeacher() {
//     if (currentTeacherId == null) {
//       return Stream.value([]);
//     }
//
//     return _firestore
//         .collection("notes")
//         .where("teacherId", isEqualTo: currentTeacherId)
//         .snapshots()
//         .map((snapshot) =>
//         snapshot.docs.map((doc) => Note.fromJson(doc.data())).toList());
//   }
// }
//
