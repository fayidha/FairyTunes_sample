import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherNotesPage extends StatefulWidget {
  const TeacherNotesPage({super.key});

  @override
  State<TeacherNotesPage> createState() => _TeacherNotesPageState();
}

class _TeacherNotesPageState extends State<TeacherNotesPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Example: Assume teacherId is stored in Firebase Authentication or global state.
  final String teacherId = "example_teacher_id"; // Replace with actual logic

  Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = file.name;

      Reference ref = _storage.ref().child('notes/$teacherId/$fileName');
      await ref.putData(file.bytes!);
      String fileUrl = await ref.getDownloadURL();

      await _firestore.collection('teachers').doc(teacherId).collection('notes').add({
        'title': fileName,
        'url': fileUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteFile(String noteId, String fileUrl) async {
    await _firestore.collection('teachers').doc(teacherId).collection('notes').doc(noteId).delete();
    await _storage.refFromURL(fileUrl).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teacher's Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadFile,
        child: Icon(Icons.upload_file),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('teachers')
            .doc(teacherId)
            .collection('notes')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          var notes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              var note = notes[index];
              return ListTile(
                title: Text(note['title']),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteFile(note.id, note['url']),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewNotePage(url: note['url'])),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ViewNotePage extends StatelessWidget {
  final String url;
  const ViewNotePage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Note")),
      body: Center(child: Text("Open file: $url")),
    );
  }
}
