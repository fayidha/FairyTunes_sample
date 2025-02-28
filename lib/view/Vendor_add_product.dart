import 'package:dupepro/controller/Product_Controller.dart';
import 'package:flutter/material.dart';
import 'package:dupepro/SuccessScreen.dart';
import 'package:dupepro/model/Product_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  List<File> _images = [];
  final ProductController _productController = ProductController();

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _images.isNotEmpty) {
      try {
        String uid = FirebaseAuth.instance.currentUser!.uid; // Get current user ID
        String productId = ProductController().generateProductId(); // Generate unique product ID

        List<String> imageUrls = await _productController.uploadImages(_images);

        Product product = Product(
          id: productId,
          uid: uid,
          name: _nameController.text,
          category: _categoryController.text,
          company: _companyController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          imageUrls: imageUrls,
        );

        await _productController.addProduct(product);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and add images.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF380230),
        title: const Text(
          "Add Product",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    child: _images.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 60, color: Colors.purple[700]),
                          const Text(
                            "Tap to add images",
                            style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    )
                        : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _images.map((image) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(image, height: 120, width: 120, fit: BoxFit.cover),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Product Name", border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? "Enter product name" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? "Enter category" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: "Company Name", border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? "Enter company name" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? "Enter product description" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price (₹)", border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? "Enter product price" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.add_circle, color: Colors.white),
                  label: const Text("Add Product"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF380230),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
