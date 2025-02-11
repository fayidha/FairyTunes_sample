import 'package:flutter/material.dart';

class Chatlist extends StatefulWidget {
  const Chatlist({super.key});

  @override
  State<Chatlist> createState() => _ChatlistState();
}

class _ChatlistState extends State<Chatlist> {
  // Sample data for teachers
  final List<Map<String, String>> teachers = [
    {'name': 'John Doe', 'message': 'Hello, how are you?', 'time': '10:30 AM'},
    {'name': 'Jane Smith', 'message': 'Can we reschedule?', 'time': '9:45 AM'},
    {'name': 'Emma Brown', 'message': 'Looking forward to our class.', 'time': 'Yesterday'},
    {'name': 'Michael Green', 'message': 'Please send the notes.', 'time': '5:00 PM'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatList'),
      ),
      body: ListView.builder(
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              // Placeholder for teacher's profile picture
              backgroundColor: Colors.blueAccent,
              child: Text(teachers[index]['name']![0]), // First letter of name
            ),
            title: Text(teachers[index]['name']!),
            subtitle: Text(teachers[index]['message']!),
            trailing: Text(teachers[index]['time']!),
            onTap: () {
              // Implement chat navigation here if needed
            },
          );
        },
      ),
    );
  }
}
