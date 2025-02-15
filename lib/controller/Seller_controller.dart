import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:dupepro/model/seller_model.dart';

class SellerController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Generate a unique seller ID
  String _generateSellerId() {
    return 'SELLER-${DateTime.now().millisecondsSinceEpoch}';
  }

  // Add a new seller
  Future<String?> addSeller(Seller seller) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return 'User not logged in.';
      }

      String sellerId = _generateSellerId();
      String? imageUrl;

      if (seller.profileImage != null && seller.profileImage!.isNotEmpty) {
        File imageFile = File(seller.profileImage!);
        String fileName = 'sellers/$sellerId.jpg';
        UploadTask uploadTask = _storage.ref(fileName).putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      final newSeller = seller.toMap();
      newSeller['uid'] = user.uid;
      newSeller['sellerId'] = sellerId;
      if (imageUrl != null) newSeller['profileImage'] = imageUrl;

      await _firestore.collection('sellers').doc(sellerId).set(newSeller);
      return null;
    } catch (e) {
      return 'Failed to add seller: $e';
    }
  }
}