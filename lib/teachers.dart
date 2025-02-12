
import 'package:dupepro/chat.dart';
import 'package:dupepro/view/teacherprofileview.dart';
import 'package:flutter/material.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
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
          onChanged: (value) => print('search clicked!'),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: 9, // Example count, replace with actual data count
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: const Icon(Icons.person, size: 40, color: Colors.blueGrey),
              title: Text(
                'Teacher ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category: Category ${index + 1}'),
                  Text('Location: Location ${index + 1}'),
                  Text('Phone: +91 98765432${index + 1}'),
                  Text('Email: teacher${index + 1}@example.com'),  // Added email
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.chat, color: Colors.blueGrey),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(teacherName: 'Teacher ${index + 1}'),
                    ),
                  );
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherProfilePage(
                      name: 'Teacher ${index + 1}',
                      phone: '+91 98765432${index + 1}',
                      address: 'Address ${index + 1}',
                      qualification: 'Qualification ${index + 1}',
                      category: 'Category ${index + 1}',
                      email: 'teacher${index + 1}@example.com', // Passing email to profile page
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
