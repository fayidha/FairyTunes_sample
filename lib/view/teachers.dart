import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/teacher_model.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF380230),
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Color(0xFF380230)),
            hintText: 'Search teachers..',
            hintStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white24,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Color(0xFF380230)),
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
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(
                    backgroundImage: teacher.imageUrl != null
                        ? NetworkImage(teacher.imageUrl!)
                        : null,
                    child: teacher.imageUrl == null
                        ? const Icon(Icons.person, size: 40, color: Colors.blueGrey)
                        : null,
                  ),
                  title: Text(
                    teacher.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: ${teacher.category}'),
                      Text('Qualification: ${teacher.qualification}'),
                      Text('Location: ${teacher.address}'),
                      Text('Phone: ${teacher.phone}'),
                      Text('Email: ${teacher.email}'),
                      Text('Experience: ${teacher.experience}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.chat, color: Colors.blueGrey),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(teacherName: teacher.name),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherProfilePage(
                          name: teacher.name,
                          phone: teacher.phone,
                          address: teacher.address,
                          qualification: teacher.qualification,
                          category: teacher.category,
                          email: teacher.email,
                          experience: teacher.experience,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
