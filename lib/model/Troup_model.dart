
// troupe_model.dart
class Troupe {
  final String id;
  final String name;
  final String location;
  final String description;
  final List<String> images;
  final List<Map<String, String>> artists;
  final String creator;

  Troupe({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.images,
    required this.artists,
    required this.creator,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'images': images,
      'artists': artists,
      'creator': creator,
    };
  }
}
