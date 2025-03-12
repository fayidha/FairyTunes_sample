import 'package:cloud_firestore/cloud_firestore.dart';

class Advertisement {
  final String id;
  final String type; // 'image' or 'video'
  final String url;
  final DateTime timestamp;

  Advertisement({
    required this.id,
    required this.type,
    required this.url,
    required this.timestamp,
  });

  // Convert Advertisement object to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'timestamp': timestamp,
    };
  }

  // Create an Advertisement object from Firestore data
  factory Advertisement.fromMap(String docId, Map<String, dynamic> map) {
    return Advertisement(
      id: docId,
      type: map['type'] ?? '',
      url: map['url'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}