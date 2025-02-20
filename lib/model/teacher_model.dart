class Teacher {
  final String uid; // Firebase Auth UID
  final String teacherId; // Unique teacher ID
  final String name;
  final String email;
  final String phone;
  final String category;
  final String qualification;
  final String experience;
  final String address;
  final String? imageUrl;

  Teacher({
    required this.uid,
    required this.teacherId,
    required this.name,
    required this.email,
    required this.phone,
    required this.category,
    required this.qualification,
    required this.experience,
    required this.address,
    this.imageUrl,
  });

  // Convert Teacher object to a Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'teacherId': teacherId,
      'name': name,
      'email': email,
      'phone': phone,
      'category': category,
      'qualification': qualification,
      'experience': experience,
      'address': address,
      'imageUrl': imageUrl,
    };
  }

  // Create a Teacher object from a Map
  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      uid: map['uid'],
      teacherId: map['teacherId'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      category: map['category'],
      qualification: map['qualification'],
      experience: map['experience'],
      address: map['address'],
      imageUrl: map['imageUrl'],
    );
  }
}