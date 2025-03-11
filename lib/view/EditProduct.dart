// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:dupepro/model/Product_model.dart';
//
// class EditProductScreen extends StatefulWidget {
//   final Product product;
//   const EditProductScreen({super.key, required this.product});
//
//   @override
//   State<EditProductScreen> createState() => _EditProductScreenState();
// }
//
// class _EditProductScreenState extends State<EditProductScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _priceController;
//   late TextEditingController _categoryController;
//   late TextEditingController _companyController;
//   late TextEditingController _quantityController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _colorsController;
//   late TextEditingController _sizesController;
//
//   List<File> _newImages = [];
//   List<String> _existingImageUrls = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.product.name);
//     _priceController = TextEditingController(text: widget.product.price.toString());
//     _categoryController = TextEditingController(text: widget.product.category);
//     _companyController = TextEditingController(text: widget.product.company);
//     _quantityController = TextEditingController(text: widget.product.quantity.toString());
//     _descriptionController = TextEditingController(text: widget.product.description);
//     _colorsController = TextEditingController(text: widget.product.colors.join(', '));
//     _sizesController = TextEditingController(text: widget.product.sizes.join(', '));
//     _existingImageUrls = List.from(widget.product.imageUrls);
//   }
//
//   Future<void> _pickImages() async {
//     final pickedFiles = await ImagePicker().pickMultiImage();
//     if (pickedFiles.isNotEmpty) {
//       setState(() {
//         _newImages = pickedFiles.map((file) => File(file.path)).toList();
//       });
//     }
//   }
//
//   Future<List<String>> _uploadNewImages() async {
//     List<String> imageUrls = List.from(_existingImageUrls);
//     for (var image in _newImages) {
//       String fileName = 'products/${widget.product.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       TaskSnapshot snapshot = await FirebaseStorage.instance.ref(fileName).putFile(image);
//       String downloadUrl = await snapshot.ref.getDownloadURL();
//       imageUrls.add(downloadUrl);
//     }
//     return imageUrls;
//   }
//
//   Future<void> _updateProduct() async {
//     if (_formKey.currentState!.validate()) {
//       List<String> finalImageUrls = _existingImageUrls;
//       if (_newImages.isNotEmpty) {
//         finalImageUrls = await _uploadNewImages();
//       }
//
//       await FirebaseFirestore.instance.collection('products').doc(widget.product.id).update({
//         'name': _nameController.text,
//         'price': double.parse(_priceController.text),
//         'category': _categoryController.text,
//         'company': _companyController.text,
//         'quantity': int.parse(_quantityController.text),
//         'description': _descriptionController.text,
//         'colors': _colorsController.text.split(',').map((e) => e.trim()).toList(),
//         'sizes': _sizesController.text.split(',').map((e) => e.trim()).toList(),
//         'imageUrls': finalImageUrls,
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Product updated successfully!')),
//       );
//
//       Navigator.pop(context);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Edit Product"),
//         backgroundColor: const Color(0xFF380230),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("Product Images", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 const SizedBox(height: 10),
//                 _existingImageUrls.isNotEmpty
//                     ? Wrap(
//                   spacing: 10,
//                   runSpacing: 10,
//                   children: _existingImageUrls.map((url) {
//                     return ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.network(url, height: 100, width: 100, fit: BoxFit.cover),
//                     );
//                   }).toList(),
//                 )
//                     : const Text("No images available"),
//                 const SizedBox(height: 10),
//                 if (_newImages.isNotEmpty)
//                   Wrap(
//                     spacing: 10,
//                     runSpacing: 10,
//                     children: _newImages.map((image) {
//                       return ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.file(image, height: 100, width: 100, fit: BoxFit.cover),
//                       );
//                     }).toList(),
//                   ),
//                 TextButton(onPressed: _pickImages, child: const Text("Change Images")),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(labelText: "Product Name", border: OutlineInputBorder()),
//                   validator: (value) => value == null || value.isEmpty ? "Enter product name" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _priceController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: "Price", border: OutlineInputBorder()),
//                   validator: (value) => value == null || value.isEmpty ? "Enter price" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _categoryController,
//                   decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
//                   validator: (value) => value == null || value.isEmpty ? "Enter category" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _companyController,
//                   decoration: const InputDecoration(labelText: "Company", border: OutlineInputBorder()),
//                   validator: (value) => value == null || value.isEmpty ? "Enter company name" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _quantityController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: "Quantity", border: OutlineInputBorder()),
//                   validator: (value) => value == null || value.isEmpty ? "Enter quantity" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
//                   validator: (value) => value == null || value.isEmpty ? "Enter description" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _colorsController,
//                   decoration: const InputDecoration(labelText: "Colors (comma separated)", border: OutlineInputBorder()),
//                   validator: (value) => value == null || value.isEmpty ? "Enter colors" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _sizesController,
//                   decoration: const InputDecoration(labelText: "Sizes (comma separated)", border: OutlineInputBorder()),
//                   validator: (value) => value == null || value.isEmpty ? "Enter sizes" : null,
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _updateProduct,
//                   style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF380230), foregroundColor: Colors.white),
//                   child: const Text("Update Product"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
