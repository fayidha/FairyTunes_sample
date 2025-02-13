import 'package:dupepro/SuccessScreen.dart';
import 'package:dupepro/controller/Seller_controller.dart';
import 'package:dupepro/model/seller_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CompanyAdd extends StatefulWidget {
  const CompanyAdd({super.key});

  @override
  State<CompanyAdd> createState() => _CompanyAddState();
}

class _CompanyAddState extends State<CompanyAdd> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;  // Changed to nullable type
  late String _companyName;
  late String _email;
  late String _phone;
  late String _address;
  late String _productCategory; // Text field for category
  final SellerController _controller = SellerController();
  bool _isLoading = false;


  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  void _saveSeller() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Show loading indicator

      Seller seller = Seller(
        companyName: _companyName,
        email: _email,
        phone: _phone,
        address: _address,
        productCategory: _productCategory,
        profileImage: _image?.path,  // Safe null check for profileImage
      );

      await _controller.addSeller(seller);

      setState(() => _isLoading = false); // Hide loading indicator
      // Navigate to the SuccessScreen and show a SnackBar
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seller Data Saved")),
      );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
            child: _isLoading
                ? const CircularProgressIndicator() // Show spinner when loading
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF380230),
                  foregroundColor: Colors.white),
              onPressed: _saveSeller,
              child: const Text("Save"),
            ),
              ),
            ],
          ),
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
