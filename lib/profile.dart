import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/creategrp.dart';
import 'package:dupepro/editprofile.dart';
import 'package:dupepro/model/user_model.dart';
import 'package:dupepro/view/Company_add.dart';

import 'package:dupepro/view/Teacher_profile_Add.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String email = "";
  String profileImage = 'asset/210379377.png';  // Default image
  String userType = "User"; // Default user type

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = pickedFile.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        UserModel userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        setState(() {
          name = userModel.name;
          email = userModel.email;
        });
      }
    }
  }

  void _setUserType(String type) {
    setState(() {
      userType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget pageToNavigate;

    // Change appBar color based on userType
    if (userType == "Seller") {
      pageToNavigate = Placeholder(); // Placeholder for Seller page, replace it later.
    } else if (userType == "Teacher") {
      pageToNavigate = Placeholder(); // Placeholder for Teacher page, replace it later.
    } else {
      pageToNavigate = Placeholder(); // Placeholder for User page, replace it later.
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF380230),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(File(profileImage)),
                  child: profileImage.isEmpty
                      ? Icon(Icons.camera_alt, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF380230),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Editprofile()));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF380230)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: const Text('Edit Profile'),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Switch my Role",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF380230),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ToggleButtons(
                            borderColor: Color(0xFF380230),
                            selectedBorderColor: Color(0xFF380230),
                            fillColor: Color(0xFF380230),
                            selectedColor: Colors.white,
                            color: Color(0xFF380230),
                            borderRadius: BorderRadius.circular(10),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text("User"),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text("Seller"),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text("Teacher"),
                              ),
                            ],
                            isSelected: [
                              userType == "User",
                              userType == "Seller",
                              userType == "Teacher"
                            ],
                            onPressed: (int index) {
                              if (index == 0) {
                                _setUserType("User");
                              } else if (index == 1) {
                                _setUserType("Seller");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CompanyAdd()),
                                );
                              } else {
                                _setUserType("Teacher");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => TeacherAdd()),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Current Role: $userType",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
