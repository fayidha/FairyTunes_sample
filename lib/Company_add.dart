import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Add the image_picker package

class CompanyAdd extends StatefulWidget {
  const CompanyAdd({super.key});

  @override
  State<CompanyAdd> createState() => _CompanyAddState();
}

class _CompanyAddState extends State<CompanyAdd> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String _companyName = "";
  String _email = "";
  String _phone = "";
  String _address = "";
  String _productCategory = ""; // Text field for category

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Registration", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF380230),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(  // Add scroll functionality to the screen
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,  // Prevents ListView from taking unnecessary space
          children: [
            // Profile Image Picker
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

            // Company Name Input
            _buildTextField("Company Name", (value) {
              setState(() {
                _companyName = value;
              });
            }),

            const SizedBox(height: 10),

            // Email Input
            _buildTextField("Email", (value) {
              setState(() {
                _email = value;
              });
            }, keyboardType: TextInputType.emailAddress),

            const SizedBox(height: 10),

            // Phone Number Input
            _buildTextField("Phone Number", (value) {
              setState(() {
                _phone = value;
              });
            }, keyboardType: TextInputType.phone),

            const SizedBox(height: 10),

            // Company Address Input
            _buildTextField("Company Address", (value) {
              setState(() {
                _address = value;
              });
            }),

            const SizedBox(height: 10),

            // Product Category Input
            _buildTextField("Product Category", (value) {
              setState(() {
                _productCategory = value;
              });
            }),

            const SizedBox(height: 20),

            // Save Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF380230),
                    foregroundColor: Colors.white // Button color
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle the form submission
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Processing Data...")),
                    );
                  }
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for creating text fields
  Widget _buildTextField(String label, Function(String) onChanged,
      {TextInputType keyboardType = TextInputType.text}) {
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
