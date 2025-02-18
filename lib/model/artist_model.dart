class Artist {
  final String id;
  final String uid;
  final String artistType;
  final String bio;
  final bool joinBands;
  final String? imageUrl; // Optional imageUrl field

  Artist({
    required this.uid,
    required this.id,
    required this.artistType,
    required this.bio,
    required this.joinBands,
    this.imageUrl,  // Add the imageUrl parameter to the constructor
  });

  // Convert Artist object to Map (for saving in Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'artistType': artistType,
      'bio': bio,
      'joinBands': joinBands,
      'imageUrl': imageUrl,  // Include imageUrl in the map if available
    };
  }

  // Create an Artist object from Map (for reading from Firestore)
  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id'],
      uid: map['uid'],
      artistType: map['artistType'],
      bio: map['bio'],
      joinBands: map['joinBands'],
      imageUrl: map['imageUrl'],  // Include imageUrl if it exists
    );
  }
}
