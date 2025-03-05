import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id;
  String uid;
  String name;
  String category;
  String company;
  String description;
  double price;
  List<String> imageUrls;
  List<String> colors;
  List<String> sizes;
  int quantity;
  Timestamp? createdAt;

  Product({
    required this.id,
    required this.uid,
    required this.name,
    required this.category,
    required this.company,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.colors,
    required this.sizes,
    required this.quantity,
    this.createdAt,
  });

  // Convert a Product object to a Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'category': category,
      'company': company,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'colors': colors,
      'sizes': sizes,
      'quantity': quantity,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Convert a Firestore document to a Product object
  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      company: map['company'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] is int) ? (map['price'] as int).toDouble() : (map['price'] as double? ?? 0.0),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      colors: List<String>.from(map['colors'] ?? []),
      sizes: List<String>.from(map['sizes'] ?? []),
      quantity: map['quantity'] ?? 0,
      createdAt: map['createdAt'] != null ? map['createdAt'] as Timestamp : null,
    );
  }
}