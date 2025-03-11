import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dupepro/model/Product_model.dart';
import 'package:dupepro/controller/Product_Controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ManageProducts extends StatefulWidget {
  const ManageProducts({super.key});

  @override
  State<ManageProducts> createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  final ProductController _productController = ProductController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  void _viewProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Products"),
        backgroundColor: const Color(0xFF380230),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('uid', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products found"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Product product = Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              return GestureDetector(
                onTap: () => _viewProductDetails(product),
                child: Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            product.imageUrls[0],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Price: \$${product.price.toStringAsFixed(2)}"),
                            Text("Sizes: ${product.sizes.join(', ')}"),
                            Text("Colors: ${product.colors.join(', ')}"),
                            Text("Description: ${product.description}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name), backgroundColor: const Color(0xFF380230)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrls.isNotEmpty)
              Center(
                child: Image.network(
                  product.imageUrls[0],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text("Category: ${product.category}", style: const TextStyle(fontSize: 16)),
            Text("Company: ${product.company}", style: const TextStyle(fontSize: 16)),
            Text("Price: \$${product.price}", style: const TextStyle(fontSize: 16)),
            Text("Quantity: ${product.quantity}", style: const TextStyle(fontSize: 16)),
            Text("Sizes: ${product.sizes.join(', ')}", style: const TextStyle(fontSize: 16)),
            Text("Colors: ${product.colors.join(', ')}", style: const TextStyle(fontSize: 16)),
            Text("Description: ${product.description}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProductScreen(product: product)),
              ),
              child: const Text("Edit Product"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _companyController;
  late TextEditingController _quantityController;
  late TextEditingController _sizesController;
  late TextEditingController _colorsController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _categoryController = TextEditingController(text: widget.product.category);
    _companyController = TextEditingController(text: widget.product.company);
    _quantityController = TextEditingController(text: widget.product.quantity.toString());
    _sizesController = TextEditingController(text: widget.product.sizes.join(', '));
    _colorsController = TextEditingController(text: widget.product.colors.join(', '));
    _descriptionController = TextEditingController(text: widget.product.description);
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('products').doc(widget.product.id).update({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'category': _categoryController.text,
        'company': _companyController.text,
        'quantity': int.parse(_quantityController.text),
        'sizes': _sizesController.text.split(',').map((e) => e.trim()).toList(),
        'colors': _colorsController.text.split(',').map((e) => e.trim()).toList(),
        'description': _descriptionController.text,
      });
      Navigator.pop(context);
    }
  }

  Future<void> _deleteProduct() async {
    await FirebaseFirestore.instance.collection('products').doc(widget.product.id).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Product Name")),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
              TextFormField(controller: _categoryController, decoration: const InputDecoration(labelText: "Category")),
              TextFormField(controller: _companyController, decoration: const InputDecoration(labelText: "Company")),
              TextFormField(controller: _quantityController, decoration: const InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
              TextFormField(controller: _sizesController, decoration: const InputDecoration(labelText: "Sizes")),
              TextFormField(controller: _colorsController, decoration: const InputDecoration(labelText: "Colors")),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Description")),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(onPressed: _updateProduct, child: const Text("Update")),
                  ElevatedButton(
                    onPressed: () async {
                      bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Product"),
                          content: const Text("Are you sure you want to delete this product?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        _deleteProduct();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}