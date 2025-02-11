import 'package:dupepro/creategrp.dart';
import 'package:dupepro/editprofile.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String name = "Fayidha Sulthana N K";  // Replace with user's name
  final String email = "fayidha@gmail.com";  // Replace with user's email
  final String phone = "8592933929";  // Replace with user's phone number
  final String profileImage = 'asset/210379377.png';  // Replace with user's profile image path

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF380230), // Changed color
        title: const Text("Profile",style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(profileImage),
              ),
            ),
            const SizedBox(height: 20),

            // Name
            Text(
              name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF380230), // Changed color
              ),
            ),
            const SizedBox(height: 10),

            // Email
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Phone Number
            Text(
              phone,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Edit Profile Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Editprofile(),));// Add functionality to edit profile
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFF380230)), // Changed button color
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateGroupPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF380230),
                foregroundColor: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Create a Group Now'),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
