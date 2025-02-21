import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/SuccessScreen.dart';
import 'package:dupepro/controller/teacher_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TeacherAdd extends StatefulWidget {
  const TeacherAdd({super.key});

  @override
  State<TeacherAdd> createState() => _TeacherAddState();
}

class _TeacherAddState extends State<TeacherAdd> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isEditing = false;


  // ✅ TextEditingControllers for all fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _profileImage = "";
  bool _isLoading = false;

  final TeacherController _teacherController = TeacherController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetch user details from Firebase Authentication & Firestore
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

        print("User Data from Firestore: $data");

        if (data != null) {
          setState(() {
            _nameController.text = data['name'] ?? "Unknown User";
            _emailController.text = data['email'] ?? "unknown@gmail.com";
            _profileImage = data['userProfile'] ?? "";
          });

          print("Fetched Name: ${_nameController.text}");
          print("Fetched Email: ${_emailController.text}");
          print("Fetched Profile Image: $_profileImage");
        } else {
          print("Error: No user data found in Firestore");
        }
      } else {
        print("Error: No user document found in Firestore");
      }
    } else {
      print("Error: No user signed in");
    }
  }

  /// Pick an image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  /// Upload image to Firebase Storage and return the URL
  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      String fileName =
          'teachers/${FirebaseAuth.instance.currentUser!.uid}.png';
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref()
          .child(fileName)
          .putFile(File(_image!.path));
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  /// Save teacher details to Firestore
  Future<void> _saveTeacher() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl = await _uploadImage(); // Upload image and get URL

      String? errorMessage = await _teacherController.registerTeacher(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        category: _categoryController.text,
        qualification: _qualificationController.text,
        experience: _experienceController.text,
        address: _addressController.text,
        imageUrl: imageUrl ?? _profileImage, // Use old image if not updated
      );

      setState(() {
        _isLoading = false;
      });

      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Teacher registered successfully!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $errorMessage")),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Registration",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF380230),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("teachers")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            // User is already registered - show profile card
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            return _isEditing ? _buildRegistrationForm(data) : _buildProfileCard(data);
          } else {
            // User is not registered - show registration form
            return _buildRegistrationForm(null);
          }
        },
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> data) {
    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF380230), Colors.blueGrey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 3,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: data['imageUrl'] != null
                  ? NetworkImage(data['imageUrl'])
                  : const AssetImage('asset/210379377.png') as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(data['name'] ?? "Unknown User",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 5),
            Text(data['email'] ?? "unknown@gmail.com",
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 5),
            Text("Phone: ${data['phone'] ?? "N/A"}",
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 5),
            Text("Category: ${data['category'] ?? "N/A"}",
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 5),
            Text("Qualification: ${data['qualification'] ?? "N/A"}",
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 5),
            Text("Experience: ${data['experience'] ?? "N/A"}",
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 5),
            Text("Address: ${data['address'] ?? "N/A"}",
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Text("Edit Profile"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm(Map<String, dynamic>? data) {
    if (data != null) {
      _nameController.text = data['name'] ?? "";
      _emailController.text = data['email'] ?? "";
      _phoneController.text = data['phone'] ?? "";
      _categoryController.text = data['category'] ?? "";
      _qualificationController.text = data['qualification'] ?? "";
      _experienceController.text = data['experience'] ?? "";
      _addressController.text = data['address'] ?? "";
      _profileImage = data['imageUrl'] ?? "";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _image != null
                    ? FileImage(File(_image!.path))
                    : _profileImage.isNotEmpty
                    ? NetworkImage(_profileImage)
                    : const AssetImage('asset/210379377.png') as ImageProvider,
                child: _image == null && _profileImage.isEmpty
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField("Teacher Name", _nameController),
            _buildTextField("Email", _emailController, keyboardType: TextInputType.emailAddress),
            _buildTextField("Phone Number", _phoneController, keyboardType: TextInputType.phone),
            _buildTextField("Category", _categoryController),
            _buildTextField("Qualification", _qualificationController),
            _buildTextField("Experience", _experienceController),
            _buildTextField("Address", _addressController),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF380230),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _saveTeacher,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a text input field
  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a $label";
        }
        return null;
      },
    );
  }
}
