import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


class AdvertisementController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Uploads an image or video to Firebase Storage
  Future<String?> uploadFile(File file, String folder) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      Reference ref = _storage.ref().child('$folder/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }

  // Saves the image advertisement details to Firestore
  Future<void> saveImageAdvertisement(String imageUrl) async {
    try {
      await _firestore.collection('advertisements').add({
        'type': 'image',
        'url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Failed to save image advertisement: $e");
    }
  }

  // Saves the video advertisement details to Firestore
  Future<void> saveVideoAdvertisement(String videoUrl) async {
    try {
      await _firestore.collection('advertisements').add({
        'type': 'video',
        'url': videoUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Failed to save video advertisement: $e");
    }
  }
}