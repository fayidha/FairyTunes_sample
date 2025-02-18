class Troupe {
  final String id;
  final String uid; // ID of the user who created this troupe
  final String name; // Name of the troupe
  final String description; // Description of the troupe
  final List<String> memberIds; // List of member IDs (Artist IDs)
  final String? imageUrl; // Optional image URL for the troupe

  Troupe({
    required this.id,
    required this.uid,
    required this.name,
    required this.description,
    required this.memberIds,
    this.imageUrl,
  });

  // Convert a Troupe object into a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'imageUrl': imageUrl,
    };
  }

  // Convert a Firestore document to a Troupe object
  factory Troupe.fromMap(Map<String, dynamic> map) {
    return Troupe(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      imageUrl: map['imageUrl'],
    );
  }
}
