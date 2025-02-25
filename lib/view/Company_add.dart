import 'package:dupepro/SuccessScreen.dart';
import 'package:dupepro/controller/Seller_controller.dart';
import 'package:dupepro/controller/session.dart';
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
  XFile? _image; // Nullable type for image
  late String _name;
  late String _email;
  late String _companyName;
  late String _phone;
  late String _address;
  late String _productCategory;
  final SellerController _controller = SellerController();
  bool _isLoading = false;
  bool _isFetchingUserData = true; // Flag to track loading user data

  // Fetch user details from the session and Firestore
  Future<void> _fetchUserDetails() async {
    try {
      Map<String, dynamic>? userDetails = await Session.getUserDetails();
      if (userDetails != null) {
        setState(() {
          _name = userDetails['name'] ?? ''; // Set name
          _email = userDetails['email'] ?? ''; // Set email
          // Optionally, set the profile image if available
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }

    setState(() {
      _isFetchingUserData = false; // Stop loading once data is fetched
    });
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  // Method to save seller data
  void _saveSeller() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Show loading indicator

      Seller seller = Seller(
        uid: "", // UID will be fetched automatically from the current user
        companyName: _companyName,
        email: _email, // Use fetched email
        phone: _phone,
        address: _address,
        productCategory: _productCategory,
        profileImage: _image?.path,  // Use picked image for profile
      );

      try {
        await _controller.addSeller(seller); // Add the seller using the controller

        setState(() => _isLoading = false); // Hide loading indicator
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Seller Data Saved")),
        );
      } catch (e) {
        setState(() => _isLoading = false); // Hide loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(); // Fetch user details when screen is loaded
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
        child: _isFetchingUserData
            ? const Center(child: CircularProgressIndicator()) // Show loading spinner while fetching user data
            : Form(
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

              // Name Input (pre-populated with current user name)
              _buildTextField("Name", (value) {
                _name = value;
              }, initialValue: _name),

              const SizedBox(height: 10),

              // Email Input (pre-populated with current user email)
              _buildTextField("Email", (value) {
                _email = value;
              }, keyboardType: TextInputType.emailAddress, initialValue: _email),

              const SizedBox(height: 10),

              // Company Name Input
              _buildTextField("Company Name", (value) {
                _companyName = value;
              }),

              const SizedBox(height: 10),

              // Phone Number Input
              _buildTextField("Phone Number", (value) {
                _phone = value;
              }, keyboardType: TextInputType.phone),

              const SizedBox(height: 10),

              // Company Address Input
              _buildTextField("Company Address", (value) {
                _address = value;
              }),

              const SizedBox(height: 10),

              // Product Category Input
              _buildTextField("Product Category", (value) {
                _productCategory = value;
              }),

              const SizedBox(height: 20),

              // Save Button
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator() // Show spinner when loading
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF380230),
                    foregroundColor: Colors.white,
                  ),
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

  // Helper method for creating text fields with optional initial values
  Widget _buildTextField(String label, Function(String) onChanged,
      {String? initialValue, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      initialValue: initialValue,
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
