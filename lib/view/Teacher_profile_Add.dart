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

      String? imageUrl = await _uploadImage();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'name': _nameController.text,
        'email': _emailController.text,
        'userProfile': imageUrl ?? _profileImage, // Use existing image if not updated
        'phone': _phoneController.text,
        'category': _categoryController.text,
        'qualification': _qualificationController.text,
        'experience': _experienceController.text,
        'address': _addressController.text,
      });

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Teacher registered successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen()),
      );
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
      body: SingleChildScrollView(
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
                      ? const Icon(Icons.camera_alt,
                      size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Teacher Name", _nameController),
              const SizedBox(height: 10),
              _buildTextField("Email", _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _buildTextField("Phone Number", _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _buildTextField("Category", _categoryController),
              const SizedBox(height: 10),
              _buildTextField("Qualification", _qualificationController),
              const SizedBox(height: 10),
              _buildTextField("Experience", _experienceController),
              const SizedBox(height: 10),
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
                      : const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
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
