class Artist {
  final String id;
  final String name;
  final String artistType;
  final String bio;
  final bool joinBands;

  Artist({
    required this.id,
    required this.name,
    required this.artistType,
    required this.bio,
    required this.joinBands,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'artistType': artistType,
      'bio': bio,
      'joinBands': joinBands,
    };
  }
}
