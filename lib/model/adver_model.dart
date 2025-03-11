class Advertisement {
  String id;
  String sellerId;
  String title;
  List<String> mediaUrls;
  DateTime createdAt;

  Advertisement({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.mediaUrls,
    required this.createdAt,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'title': title,
      'mediaUrls': mediaUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert Firestore Map to Object
  factory Advertisement.fromMap(Map<String, dynamic> map) {
    return Advertisement(
      id: map['id'],
      sellerId: map['sellerId'],
      title: map['title'],
      mediaUrls: List<String>.from(map['mediaUrls']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
