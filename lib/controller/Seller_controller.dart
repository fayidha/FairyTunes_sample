import 'package:dupepro/model/seller_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class SellerController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch seller details by UID
  Future<Seller?> getSellerDetails(String uid) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('sellers').doc(uid).get();
      if (snapshot.exists) {
        return Seller.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        print("No seller document found for UID: $uid");
        return null;
      }
    } catch (e) {
      print("Error fetching seller details: $e");
      return null;
    }
  }

  // Update seller details
  Future<String?> updateSeller(Seller seller) async {
    try {
      String? imageUrl;

      // Upload new image if available
      if (seller.profileImage != null && seller.profileImage!.isNotEmpty) {
        imageUrl = await _uploadImage(seller.profileImage!, seller.uid);
      }

      final updatedSeller = {
        'companyName': seller.companyName,
        'email': seller.email,
        'phone': seller.phone,
        'address': seller.address,
        'productCategory': seller.productCategory,
        'profileImage': imageUrl ?? seller.profileImage,
      };

      await _firestore.collection('sellers').doc(seller.uid).update(updatedSeller);
      return null;
    } catch (e) {
      return 'Failed to update seller: $e';
    }
  }

  // Add seller using the current user's UID
  Future<String?> addSeller(Seller seller) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return 'User not logged in.';
      }

      String? imageUrl;

      // If the seller has a profile image, upload it
      if (seller.profileImage != null && seller.profileImage!.isNotEmpty) {
        imageUrl = await _uploadImage(seller.profileImage!, user.uid);
      } else {
        // If no image is provided, use the user's photoURL or set a default image URL
        imageUrl = user.photoURL ?? 'https://your-default-image-url.com/default_image.jpg';  // Ensure this URL exists
      }

      final newSeller = {
        'uid': user.uid,
        'companyName': seller.companyName,
        'email': seller.email,
        'phone': seller.phone,
        'address': seller.address,
        'productCategory': seller.productCategory,
        'profileImage': imageUrl,
      };

      await _firestore.collection('sellers').doc(user.uid).set(newSeller);
      return null;
    } catch (e) {
      return 'Failed to add seller: $e';
    }
  }

  // Method to handle image upload to Firebase Storage
  Future<String> _uploadImage(String filePath, String uid) async {
    try {
      File imageFile = File(filePath);
      String fileName = 'sellers/$uid.jpg';  // Ensure you are saving the image in the correct location in Firebase Storage
      UploadTask uploadTask = _storage.ref(fileName).putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return '';  // If image upload fails, return an empty string (you can also handle this more gracefully)
    }
  }
}
