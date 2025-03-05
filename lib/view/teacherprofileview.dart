import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Function to Open PDF in Browser
  void _viewPdf(String? pdfUrl) async {
    if (pdfUrl == null || pdfUrl.isEmpty) {
      debugPrint("No PDF URL available");
      return;
    }

    final Uri url = Uri.parse(pdfUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not open PDF");
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
                    final String? pdfUrl = data['pdfUrl']; // Fetch the PDF URL correctly

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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye, color: Colors.blueGrey),
                              onPressed: () {
                                if (pdfUrl != null && pdfUrl.isNotEmpty) {
                                  _viewPdf(pdfUrl);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("No PDF available for this note."))
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.download, color: Colors.blueGrey),
                              onPressed: () {
                                // Implement Download functionality
                              },
                            ),
                          ],
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
