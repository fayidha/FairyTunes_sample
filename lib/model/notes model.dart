// import 'package:uuid/uuid.dart';
//
// class Note {
//   final String noteId;  // Unique ID for each note
//   final String name;
//   final String path;
//   final String teacherId;  // Firebase UID of the teacher
//
//   Note({required this.noteId, required this.name, required this.path, required this.teacherId});
//
//   // Convert Note to JSON for Firebase
//   Map<String, dynamic> toJson() {
//     return {
//       "noteId": noteId,
//       "name": name,
//       "path": path,
//       "teacherId": teacherId,
//     };
//   }
//
//   // Create Note object from Firebase JSON
//   factory Note.fromJson(Map<String, dynamic> json) {
//     return Note(
//       noteId: json['noteId'],
//       name: json['name'],
//       path: json['path'],
//       teacherId: json['teacherId'],
//     );
//   }
// }
