import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/bottomBar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dupepro/controller/Seller_controller.dart';
import 'package:dupepro/controller/session.dart';
import 'package:dupepro/model/seller_model.dart';

class CompanyAdd extends StatefulWidget {
  const CompanyAdd({super.key});

  @override
  State<CompanyAdd> createState() => _CompanyAddState();
}

class _CompanyAddState extends State<CompanyAdd> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  // Fields to store user data
  String _name = "";
  String _email = "";
  String _companyName = "";
  String _phone = "";
  String _address = "";
  String _productCategory = "";
  String? _profileImageUrl;

  // Controller for Seller operations
  final SellerController _controller = SellerController();

  // Loading state flags
  bool _isLoading = false;
  bool _isFetchingUserData = true;
  bool _isEditing = false;

  // Fetch user and seller details
  Future<void> _fetchUserDetails() async {
    try {
      Map<String, String?> session = await Session.getSession();
      String? uid = session['uid'];

      if (uid == null || uid.isEmpty) {
        print("Error: UID not found in session.");
        setState(() => _isFetchingUserData = false);
        return;
      }

      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _name = userData['name'] ?? 'Not Available';
          _email = userData['email'] ?? 'Not Available';

          bool isSeller = userData['isSeller'] ?? false;
          _isEditing = !isSeller;

          print('UserName: $_name');
          print('isSeller: $isSeller');
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
    setState(() => _isFetchingUserData = false);
  }

  Future<void> _fetchSellerDetails() async {
    try {
      // Get session details
      Map<String, String?> session = await Session.getSession();
      String? uid = session['uid']; // Fetch UID from session

      if (uid == null || uid.isEmpty) {
        print("Error: UID not found in session.");
        return;
      }

      // Fetch seller details using UID
      DocumentSnapshot sellerSnapshot =
          await FirebaseFirestore.instance.collection('sellers').doc(uid).get();

      if (sellerSnapshot.exists) {
        Map<String, dynamic> sellerData =
            sellerSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _companyName = sellerData['companyName'] ?? '';
          _phone = sellerData['phone'] ?? '';
          _address = sellerData['address'] ?? '';
          _productCategory = sellerData['productCategory'] ?? '';
          _profileImageUrl = sellerData['profileImage'] ?? '';

          print('Company Name: $_companyName');
          print('Phone: $_phone');
          print('Address: $_address');
          print('Product Category: $_productCategory');
        });
      } else {
        print("No seller details found for UID: $uid");
      }
    } catch (e) {
      print("Error fetching seller details: $e");
    }
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
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

      // Retrieve session details to get UID
      Map<String, String?> session = await Session.getSession();
      String? uid = session['uid'];

      Seller seller = Seller(
        uid: "",
        companyName: _companyName,
        email: _email,
        phone: _phone,
        address: _address,
        productCategory: _productCategory,
        profileImage: _image?.path, // Use picked image for profile
      );

      try {
        await _controller
            .addSeller(seller); // Add the seller using the controller

        // Update the 'users' collection to mark the user as a seller
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'isSeller': true,
        });

        setState(() => _isLoading = false);

        setState(() => _isLoading = false);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomBarScreen(),
            ));
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
    if (_companyName.isEmpty ||
        _phone.isEmpty ||
        _address.isEmpty ||
        _productCategory.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchSellerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Registration",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF380230),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isFetchingUserData
            ? const Center(
                child:
                    CircularProgressIndicator()) // Show loading spinner while fetching user data
            : Column(
                children: [
                  _isEditing ? _buildEditableForm() : _buildProfileCard(),
                ],
              ),
      ),
    );
  }

  // Profile Card with Edit Button
  Widget _buildProfileCard() {
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
            // Profile Image
            CircleAvatar(
              radius: 50,
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(
                      _profileImageUrl!) // Use NetworkImage for Firebase URL
                  : null,
              child: _profileImageUrl == null
                  ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 20),

            // Name
            Text(
              _name.isNotEmpty ? _name : 'No name available',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Email
            Text(
              _email.isNotEmpty ? _email : 'No email available',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Company Name
            Text(
              _companyName.isNotEmpty
                  ? _companyName
                  : 'No company name available',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Phone
            Text(
              _phone.isNotEmpty ? _phone : 'No phone number available',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Address
            Text(
              _address.isNotEmpty ? _address : 'No address available',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Product Category
            Text(
              _productCategory.isNotEmpty
                  ? _productCategory
                  : 'No product category available',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Edit Button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true; // Switch to editing mode
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF380230),
                foregroundColor: Colors.white,
              ),
              child: const Text("Edit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Editable Form for Company and Contact Info
  Widget _buildEditableForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Profile Image Picker
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  _image != null ? FileImage(File(_image!.path)) : null,
              child: _image == null
                  ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 20),

          // Name Input (Editable)
          _buildTextField("Name", (value) {
            _name = value;
          }, initialValue: _name, enabled: true),

          const SizedBox(height: 10),

          // Email Input (Editable)
          _buildTextField("Email", (value) {
            _email = value;
          },
              keyboardType: TextInputType.emailAddress,
              initialValue: _email,
              enabled: true),

          const SizedBox(height: 10),

          // Company Name Input
          _buildTextField("Company Name", (value) {
            _companyName = value;
          }, initialValue: _companyName),

          const SizedBox(height: 10),

          // Phone Number Input
          _buildTextField("Phone Number", (value) {
            _phone = value;
          }, keyboardType: TextInputType.phone),

          const SizedBox(height: 10),

          // Company Address Input
          _buildTextField("Company Address", (value) {
            _address = value;
          }, initialValue: _address),

          const SizedBox(height: 10),

          // Product Category Input
          _buildTextField("Product Category", (value) {
            _productCategory = value;
          }, initialValue: _productCategory),

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
    );
  }

  // Helper method for creating text fields with optional initial values
  Widget _buildTextField(String label, Function(String) onChanged,
      {String? initialValue,
      TextInputType keyboardType = TextInputType.text,
      bool enabled = true}) {
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
      enabled: enabled,
    );
  }
}
