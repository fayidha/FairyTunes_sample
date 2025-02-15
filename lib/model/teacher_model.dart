class Teacher {
  String uid; // Same as user UID
  String name;
  String email;
  String phone;
  String category;
  String qualification;
  String experience;
  String address;
  String? imageUrl;

  Teacher({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.category,
    required this.qualification,
    required this.experience,
    required this.address,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'category': category,
      'Qualification':qualification,
      'experience': experience,
      'address': address,
      'imageUrl': imageUrl,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      category: map['category'] ?? '',
      qualification: map['qualification'] ?? '',
      experience: map['experience'] ?? '',
      address: map['address'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }
}
