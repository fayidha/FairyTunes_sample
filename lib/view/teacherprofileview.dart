import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TeacherProfilePage extends StatelessWidget {
  final String teacherId;
  final String name;
  final String phone;
  final String address;
  final String qualification;
  final String category;
  final String email;
  final String experience;
  final String? imageUrl;

  const TeacherProfilePage({
    super.key,
    required this.teacherId,
    required this.name,
    required this.phone,
    required this.address,
    required this.qualification,
    required this.category,
    required this.email,
    required this.experience,
    this.imageUrl,
  });

  // Function to Download and Open PDF
  Future<void> _openPdf(String pdfUrl) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${pdfUrl.split('/').last}';
      final file = File(filePath);

      if (!await file.exists()) {
        debugPrint("Downloading PDF...");
        await Dio().download(pdfUrl, filePath);
      }

      OpenFile.open(filePath);
    } catch (e) {
      debugPrint("Error opening PDF: $e");
      debugPrint("PDF URL: $pdfUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF380230),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blueGrey,
                  backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                      ? NetworkImage(imageUrl!)
                      : null,
                  child: imageUrl == null || imageUrl!.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('$qualification • $category', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      Text('Experience: $experience', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      Text('Email: $email', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      Text('Phone: $phone', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      Text('Address: $address', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Music Notes Section
            const Text('Music Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("notes")
                  .where("teacherId", isEqualTo: teacherId.trim())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint("Firestore Error: ${snapshot.error}");
                  return const Center(child: Text("Error loading notes"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No notes uploaded yet."));
                }

                final notes = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final data = notes[index].data() as Map<String, dynamic>;

                    final String noteName = data['noteName'] ?? 'Untitled Note';
                    final String description = data['description'] ?? 'No description available';
                    final String? pdfUrl = data['fileUrl'];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          noteName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(description),
                        trailing: IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.blueGrey),
                          onPressed: () {
                            if (pdfUrl != null && pdfUrl.isNotEmpty) {
                              _openPdf(pdfUrl);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("No PDF available for this note.")));
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
