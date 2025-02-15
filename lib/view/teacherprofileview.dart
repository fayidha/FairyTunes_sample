import 'package:flutter/material.dart';

class TeacherProfilePage extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final String qualification;
  final String category;
  final String email;
  final String experience;

  const TeacherProfilePage({
    super.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.qualification,
    required this.category,
    required this.email,
    required this.experience,
  });

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
            Row(
              children: [
                const CircleAvatar(radius: 40, backgroundColor: Colors.blueGrey, child: Icon(Icons.person, size: 50, color: Colors.white)),
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
            const Text('Music Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...List.generate(8, (index) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text('Note ${index + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                subtitle: const Text('This is a sample note description.'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye, color: Colors.blueGrey),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.blueGrey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
