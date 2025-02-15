class Troup {
  String id;
  String name;
  String description;
  List<Map<String, String>> members;
  Map<String, String> admin;

  Troup({required this.id, required this.name, required this.description, required this.members, required this.admin});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'members': members,
      'admin': admin,
    };
  }

  factory Troup.fromMap(Map<String, dynamic> map) {
    return Troup(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      members: List<Map<String, String>>.from(map['members']),
      admin: Map<String, String>.from(map['admin']),
    );
  }
}
