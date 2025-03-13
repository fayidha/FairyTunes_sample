import 'package:cloud_firestore/cloud_firestore.dart';

class Artist {
  String uid;
  String id;
  String artistType;
  String bio;
  bool joinBands;

  // Constructor
  Artist({
    required this.uid,
    required this.id,
    required this.artistType,
    required this.bio,
    required this.joinBands,
  });

  // Convert Firestore JSON to Artist Object
  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      uid: json['uid'] ?? '',
      id: json['id'] ?? '', // Ensure `id` is handled
      artistType: json['artistType'] ?? '',
      bio: json['bio'] ?? '',
      joinBands: json['joinBands'] ?? false,
    );
  }

  // Create an Artist object from a Firestore document snapshot
  factory Artist.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Artist(
      uid: data['uid'] ?? '',
      id: doc.id, // Ensuring Firestore ID is used
      artistType: data['artistType'] ?? '',
      bio: data['bio'] ?? '',
      joinBands: data['joinBands'] ?? false,
    );
  }

  // Convert Artist object to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'id': id,
      'artistType': artistType,
      'bio': bio,
      'joinBands': joinBands,
      'createdAt': Timestamp.now(),
    };
  }
}
