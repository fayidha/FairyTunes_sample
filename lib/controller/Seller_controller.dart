import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dupepro/model/seller_model.dart';
import 'dart:io';

class SellerController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addSeller(Seller seller) async {
    try {
      String? imageUrl;
      if (seller.profileImage != null && seller.profileImage!.isNotEmpty) {
        File imageFile = File(seller.profileImage!);
        String fileName = 'sellers/${DateTime.now().millisecondsSinceEpoch}.jpg';
        UploadTask uploadTask = _storage.ref(fileName).putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      final newSeller = seller.toMap();
      if (imageUrl != null) {
        newSeller['profileImage'] = imageUrl;
      }

      await _firestore.collection('sellers').add(newSeller);
    } catch (e) {
      throw Exception('Failed to add seller: $e');
    }
  }

  Future<List<Seller>> getSellers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('sellers').get();
      return snapshot.docs.map((doc) => Seller.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch sellers: $e');
    }
  }

  Future<void> deleteSeller(String id) async {
    await _firestore.collection('sellers').doc(id).delete();
  }

  Future<void> updateSeller(String id, Seller seller) async {
    await _firestore.collection('sellers').doc(id).update(seller.toMap());
  }
}
