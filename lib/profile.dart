import 'package:dupepro/Artist_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dupepro/editprofile.dart';
import 'package:dupepro/view/Company_add.dart';
import 'package:dupepro/view/Teacher_profile_Add.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String email = "";
  String profileImage = 'asset/210379377.png';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'];
          email = userDoc['email'];
          profileImage = userDoc['profileImage'] ?? profileImage;
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
              onTap: () async {
                final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) setState(() => profileImage = pickedFile.path);
              },
              child: CircleAvatar(radius: 60, backgroundImage: FileImage(File(profileImage)),),
            ),
            SizedBox(height: 20),
            Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Editprofile())), child: Text('Edit Profile')),
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyAdd())),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.school, color: Color(0xFF380230)),
              title: Text('Switch to Teacher'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherAdd())),
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
          _carouselCard(context, "Create a Artist Profile", "Set your passion, join bands, and collaborate effortlessly.", Icons.music_note),
          _carouselCard(context, "Create a Band", "Form your own music band, find artists, and share your passion.", Icons.group),
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
        }
        else if (title == "Create a Band") {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => CreateGroupPage()),
          // );
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
              Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}