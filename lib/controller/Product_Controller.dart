  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:firebase_storage/firebase_storage.dart';
  import 'dart:io';
  import 'package:dupepro/model/Product_model.dart';

  class ProductController {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseStorage _storage = FirebaseStorage.instance;

    // Generate a unique product ID
    String generateProductId() {
      return _firestore.collection('products').doc().id;
    }

    // Upload images to Firebase Storage and return URLs
    Future<List<String>> uploadImages(List<File> images) async {
      List<String> imageUrls = [];
      for (var image in images) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = _storage.ref().child("product_images/$fileName.jpg");
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
      return imageUrls;
    }

    // Add a new product to Firestore
    Future<void> addProduct(Product product) async {
      try {
        await _firestore.collection('products').doc(product.id).set(product.toMap());
      } catch (e) {
        throw Exception("Error adding product: $e");
      }
    }

    // Fetch all products from Firestore
    Future<List<Product>> getAllProducts() async {
      try {
        QuerySnapshot querySnapshot = await _firestore.collection('products').orderBy('createdAt', descending: true).get();
        return querySnapshot.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      } catch (e) {
        throw Exception("Error fetching products: $e");
      }
    }

    // Fetch products by seller UID
    Future<List<Product>> getProductsByVendor(String uid) async {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('products')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .get();
        return querySnapshot.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      } catch (e) {
        throw Exception("Error fetching vendor products: $e");
      }
    }

    // Update product details
    Future<void> updateProduct(String productId, Map<String, dynamic> updatedData) async {
      try {
        await _firestore.collection('products').doc(productId).update(updatedData);
      } catch (e) {
        throw Exception("Error updating product: $e");
      }
    }

    // Delete product
    Future<void> deleteProduct(String productId) async {
      try {
        await _firestore.collection('products').doc(productId).delete();
      } catch (e) {
        throw Exception("Error deleting product: $e");
      }
    }
  }
