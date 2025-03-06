import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class TeacherDashboard extends StatefulWidget {
  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Map<String, dynamic>> selectedNotes = [];
  final List<TextEditingController> descriptionControllers = [];

  @override
  void dispose() {
    for (var controller in descriptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> uploadNotes() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    for (int i = 0; i < selectedNotes.length; i++) {
      File file = File(selectedNotes[i]['file'].path!);
      String fileName = selectedNotes[i]['file'].name;
      String noteId = _firestore.collection("notes").doc().id;

      TaskSnapshot uploadTask = await _storage.ref('notes/${user.uid}/$fileName').putFile(file);
      String fileUrl = await uploadTask.ref.getDownloadURL();

      await _firestore.collection("notes").doc(noteId).set({
        "noteId": noteId,
        "teacherId": user.uid,
        "noteName": fileName,
        "fileUrl": fileUrl,
        "description": descriptionControllers[i].text,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${selectedNotes.length} PDFs uploaded successfully")),
    );
    setState(() {
      selectedNotes.clear();
      descriptionControllers.clear();
    });
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          if (file.size < 5000000) {
            selectedNotes.add({"file": file, "description": ""});
            descriptionControllers.add(TextEditingController());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("File '${file.name}' exceeds 5MB limit and was not added.")),
            );
          }
        }
      });
    }
  }

  Future<void> deleteNote(String noteId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Note"),
        content: Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirmDelete) {
      await _firestore.collection("notes").doc(noteId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Note deleted successfully")));
    }
  }

  Future<void> editDescription(String noteId, String newDescription) async {
    await _firestore.collection("notes").doc(noteId).update({"description": newDescription});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Description updated successfully")));
  }

  void viewPDF(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PDFViewer(filePath: filePath)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGradientHeader(),
            SizedBox(height: 20),
            _buildUploadNotesSection(),
            SizedBox(height: 20),
            _buildViewNotesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 50, horizontal: 70),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF380230), Color(0xFF6A0D54)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome Music Teacher", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 2),
          Text("Manage your notes and chats", style: TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildUploadNotesSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: pickFiles,
            icon: Icon(Icons.upload_file, color: Colors.white),
            label: Text("Select PDF Notes", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF380230)),
          ),
          Column(
            children: List.generate(selectedNotes.length, (index) {
              return Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => viewPDF(selectedNotes[index]['file'].path!),
                    icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: Text("View PDF", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF380230)),
                  ),
                  TextField(
                    controller: descriptionControllers[index],
                    decoration: InputDecoration(labelText: "Description"),
                  ),
                  SizedBox(height: 8),
                ],
              );
            }),
          ),
          if (selectedNotes.isNotEmpty)
            ElevatedButton(
              onPressed: uploadNotes,
              child: Text("Upload Notes"),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF380230), foregroundColor: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildViewNotesSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("notes").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final notes = snapshot.data!.docs;

        return Column(
          children: notes.map((note) {
            TextEditingController editController = TextEditingController(text: note['description']);
            bool isEditing = false;

            return StatefulBuilder(
              builder: (context, setState) {
                return Card(
                  child: ListTile(
                    title: Text(note['noteName']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isEditing)
                          Text(note['description']),
                        if (isEditing)
                          TextField(
                            controller: editController,
                            decoration: InputDecoration(labelText: "Edit Description"),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEditing)
                          IconButton(
                            icon: Icon(Icons.save),
                            onPressed: () async {
                              await editDescription(note.id, editController.text);
                              setState(() {
                                isEditing = false;
                              });
                            },
                          ),
                        if (!isEditing)
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                isEditing = true;
                              });
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          onPressed: () => launch(note['fileUrl']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteNote(note.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}


    class PDFViewer extends StatelessWidget {
  final String filePath;

  PDFViewer({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View PDF'),
        backgroundColor: Color(0xFF380230),
      ),
      body: PDFView(filePath: filePath),
    );
  }
}
