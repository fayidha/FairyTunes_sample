import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/adver_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdvertisementController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get Current Seller ID
  String? getSellerId() {
    return _auth.currentUser?.uid;
  }

  // Upload Files to Firebase Storage
  Future<String?> _uploadFile(File file, String path) async {
    try {
      UploadTask uploadTask = _storage.ref(path).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("File Upload Error: $e");
      return null;
    }
  }

  // Add Advertisement
  Future<String?> addAdvertisement(String title, List<File> mediaFiles) async {
    String? sellerId = getSellerId();
    if (sellerId == null) return "User not logged in.";

    try {
      List<String> mediaUrls = [];
      for (File file in mediaFiles) {
        String filePath = 'advertisements/$sellerId/${DateTime.now().millisecondsSinceEpoch}.jpg';
        String? fileUrl = await _uploadFile(file, filePath);
        if (fileUrl != null) mediaUrls.add(fileUrl);
      }

      String adId = _firestore.collection('advertisements').doc().id;
      Advertisement ad = Advertisement(
        id: adId,
        sellerId: sellerId,
        title: title,
        mediaUrls: mediaUrls,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('advertisements').doc(adId).set(ad.toMap());
      return null;  // Success
    } catch (e) {
      return "Failed to upload advertisement: $e";
    }
  }

  // Fetch Advertisements for Current Seller
  Stream<List<Advertisement>> getAdvertisements() {
    String? sellerId = getSellerId();
    if (sellerId == null) return Stream.value([]);

    return _firestore.collection('advertisements')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Advertisement.fromMap(doc.data())).toList());
  }
}
