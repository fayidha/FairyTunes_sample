import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dupepro/model/teacher_model.dart';
import 'package:dupepro/chat.dart';
import 'package:dupepro/view/teacherprofileview.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF380230),
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            hintText: 'Search teachers...',
            hintStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white24,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('teachers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No teachers found'));
          }

          var teachers = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Teacher.fromMap(data);
          }).where((teacher) {
            return teacher.name.toLowerCase().contains(searchQuery) ||
                teacher.category.toLowerCase().contains(searchQuery);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              var teacher = teachers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherProfilePage(
                        teacherId: teacher.teacherId,
                        name: teacher.name,
                        phone: teacher.phone,
                        address: teacher.address,
                        qualification: teacher.qualification,
                        category: teacher.category,
                        email: teacher.email,
                        experience: teacher.experience,
                        imageUrl: teacher.imageUrl,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  shadowColor: Colors.black26,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: teacher.imageUrl != null && teacher.imageUrl!.isNotEmpty
                              ? NetworkImage(teacher.imageUrl!)
                              : null,
                          child: teacher.imageUrl == null || teacher.imageUrl!.isEmpty
                              ? const Icon(Icons.person, size: 40, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                teacher.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF380230),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.grid_view_rounded, color: Colors.grey, size: 18),
                                  const SizedBox(width: 5),
                                  Text(teacher.category, style: TextStyle(color: Colors.grey[800])),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(Icons.school, color: Colors.grey[600], size: 18),
                                  const SizedBox(width: 5),
                                  Text('Experience: ${teacher.experience} yrs', style: TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF380230), Color(0xFFAB47BC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chat_rounded, color: Colors.white, size: 26),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(teacher.teacherId, teacher.name),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}