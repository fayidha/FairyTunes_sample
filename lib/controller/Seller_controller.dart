import 'package:dupepro/model/seller_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class SellerController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch user details by UID
  static Future<Map<String, dynamic>?> getUserDetailsByUid(String uid) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  // Add seller using the current user's UID
  Future<String?> addSeller(Seller seller) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return 'User not logged in.';
      }

      // Fetch user details
      var userDetails = await getUserDetailsByUid(user.uid);
      if (userDetails == null) {
        return 'User details not found.';
      }

      String? imageUrl;

      if (seller.profileImage != null && seller.profileImage!.isNotEmpty) {
        File imageFile = File(seller.profileImage!);
        String fileName = 'sellers/${user.uid}.jpg'; // Use the UID as file name
        UploadTask uploadTask = _storage.ref(fileName).putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      final newSeller = {
        'uid': user.uid, // Use logged-in user's UID
        'companyName': seller.companyName,
        'email': userDetails['email'] ?? '', // Fetch email from user details
        'phone': seller.phone,
        'address': seller.address,
        'productCategory': seller.productCategory,
        'profileImage': imageUrl ?? userDetails['profileImage'], // Use fetched profile image
      };

      await _firestore.collection('sellers').doc(user.uid).set(newSeller); // Save using UID as the document ID
      return null;
    } catch (e) {
      return 'Failed to add seller: $e';
    }
  }
}
