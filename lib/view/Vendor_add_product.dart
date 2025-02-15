import 'package:dupepro/controller/Product_Controller.dart';
import 'package:flutter/material.dart';
import 'package:dupepro/SuccessScreen.dart';
import 'package:dupepro/model/Product_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _companyController = TextEditingController();
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
    _descriptionController.dispose();
    _priceController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _images.isNotEmpty) {
      try {
        List<String> imageUrls = await _productController.uploadImages(_images);

        Product product = Product(
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          company: _companyController.text,
          imageUrls: imageUrls,
        );

        await _productController.addProduct(product);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully!')),
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
        SnackBar(content: Text('Please fill all fields and add images.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF380230),
        title: const Text(
          "Add Product Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: _images.isEmpty
                        ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey[700])
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Image.file(_images[index], height: 150),
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Product Name"),
                  validator: (value) => value == null || value.isEmpty ? "Enter product name" : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: "Description"),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? "Enter product description" : null,
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Price (₹)"),
                  validator: (value) => value == null || value.isEmpty ? "Enter product price" : null,
                ),
                TextFormField(
                  controller: _companyController,
                  decoration: InputDecoration(labelText: "Company Name"),
                  validator: (value) => value == null || value.isEmpty ? "Enter company name" : null,
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: Icon(Icons.add_circle),
                  label: Text("Add Product"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF380230),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
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