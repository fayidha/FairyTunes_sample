class Troupe {
  final String id;
  final String name;
  final String description;
  final String adminId;
  final List<String> members; // List of artist IDs
  final String imageUrl;

  Troupe({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.members,
    required this.imageUrl,
  });

  // Convert Firestore data to Troupe object
  factory Troupe.fromMap(Map<String, dynamic> data) {
    return Troupe(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      adminId: data['adminId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Convert Troupe object to Map (for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'adminId': adminId,
      'members': members,
      'imageUrl': imageUrl,
    };
  }
}
