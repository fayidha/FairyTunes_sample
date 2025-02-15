import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/Product_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductController {
  final CollectionReference productsCollection = FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(Product product) async {
    await productsCollection.add(product.toMap());
  }

  Future<List<String>> uploadImages(List<File> images) async {
    List<String> downloadUrls = [];
    for (var image in images) {
      final storageRef = FirebaseStorage.instance.ref().child('product_images/${DateTime.now().toIso8601String()}');
      await storageRef.putFile(image);
      String downloadUrl = await storageRef.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }
}