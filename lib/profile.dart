import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dupepro/Artist_tabbar.dart';
import 'package:dupepro/view/Teacher_profile_Add.dart';
import 'package:dupepro/view/creategrp.dart';
import 'package:dupepro/editprofile.dart';
import 'package:dupepro/view/Company_add.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late File _imageFile;
  String name = "";
  String email = "";
  String profileImage = '';
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future pickImages() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadImage();
    }
  }


  Future<void> _uploadImage() async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('user_images/$fileName.jpg');

      UploadTask uploadTask = storageRef.putFile(_imageFile);

      TaskSnapshot taskSnapshot = await uploadTask;

      String imageUrl = await taskSnapshot.ref.getDownloadURL();


      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'userProfile': imageUrl,
        });

        await FirebaseFirestore.instance.collection('teachers').doc(user.uid).update({
          'imageUrl': imageUrl,
        });
      }

      setState(() {
        profileImage = imageUrl;
      });

      print('Image uploaded successfully: $imageUrl');
    } catch (e) {
      print('Failed to upload image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
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
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'];
          email = userDoc['email'];
          profileImage = userDoc['userProfile'] ?? ''; // Default to empty string if no image exists
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF380230),
        iconTheme: IconThemeData(color: Colors.white),
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                pickImages(); // When tapped, pick an image
              },
              child: CircleAvatar(
                radius: 60,
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : AssetImage('asset/210379377.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Editprofile())),
              child: Text('Edit Profile'),
            ),
            SizedBox(height: 20),
            _buildSwitchMyRole(context),
            SizedBox(height: 20),
            _buildCarouselSlider(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchMyRole(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.store, color: Color(0xFF380230)),
              title: Text('Switch to Seller'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => CompanyAdd())),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.school, color: Color(0xFF380230)),
              title: Text('Switch to Teacher'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => TeacherAdd())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselSlider(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView(
        children: [
          _carouselCard(
              context,
              "Create a Artist Profile",
              "Set your passion, join bands, and collaborate effortlessly.",
              Icons.music_note),
          _carouselCard(
              context,
              "Create a Band",
              "Form your own music band, find artists, and share your passion.",
              Icons.group),
        ],
      ),
    );
  }

  Widget _carouselCard(BuildContext context, String title, String subtitle, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (title == "Create a Artist Profile") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ArtistTab()),
          );
        } else if (title == "Create a Band") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateGroupPage()),
          );
        }
      },
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Color(0xFF380230),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(height: 10),
              Text(title,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 8),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
