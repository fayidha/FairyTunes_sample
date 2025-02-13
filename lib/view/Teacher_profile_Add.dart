import 'dart:io';
import 'package:dupepro/SuccessScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dupepro/model/teacher_model.dart';
import 'package:dupepro/controller/teacher_controller.dart';

class TeacherAdd extends StatefulWidget {
  const TeacherAdd({super.key});

  @override
  State<TeacherAdd> createState() => _TeacherAddState();
}

class _TeacherAddState extends State<TeacherAdd> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String _teacherName = "";
  String _email = "";
  String _phone = "";
  String _category = "";
  String _experience = "";
  String _address = "";
  bool _isLoading = false; // Add a flag for loading state

  final TeacherController _teacherController = TeacherController();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  Future<void> _saveTeacher() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading to true while saving
      });

      String? imageUrl = await _uploadImage();

      Teacher teacher = Teacher(
        name: _teacherName,
        email: _email,
        phone: _phone,
        category: _category,
        experience: _experience,
        address: _address,
        imageUrl: imageUrl,
      );

      await _teacherController.addTeacher(teacher);

      setState(() {
        _isLoading = false; // Set loading to false after saving
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Teacher registered successfully!")),
      );

      _formKey.currentState!.reset();
      setState(() {
        _image = null;  // Reset the image after successful save
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SuccessScreen(),));
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      String fileName = 'teachers/${DateTime.now().millisecondsSinceEpoch}.png';
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref()
          .child(fileName)
          .putFile(File(_image!.path));
      String imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Registration", style: TextStyle(color: Colors.white)),
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
                  backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Teacher Name", (value) {
                setState(() {
                  _teacherName = value;
                });
              }),
              const SizedBox(height: 10),
              _buildTextField("Email", (value) {
                setState(() {
                  _email = value;
                });
              }, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _buildTextField("Phone Number", (value) {
                setState(() {
                  _phone = value;
                });
              }, keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _buildTextField("Category", (value) {
                setState(() {
                  _category = value;
                });
              }),
              const SizedBox(height: 10),
              _buildTextField("Experience", (value) {
                setState(() {
                  _experience = value;
                });
              }),
              const SizedBox(height: 10),
              _buildTextField("Address", (value) {
                setState(() {
                  _address = value;
                });
              }),
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

  Widget _buildTextField(String label, Function(String) onChanged, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a $label";
        }
        return null;
      },
    );
  }
}
