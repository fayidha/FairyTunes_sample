import 'package:cloud_firestore/cloud_firestore.dart';

class Artist {
  String uid; // User ID from Firebase Authentication
  String id; // Unique artist ID in Firestore
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

  // Create an Artist object from a Firestore document snapshot
  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      uid: json['uid'],
      id: json['id'],
      artistType: json['artistType'],
      bio: json['bio'],
      joinBands: json['joinBands'],
    );
  }
}
