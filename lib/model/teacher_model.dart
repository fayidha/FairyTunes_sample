class Teacher {
  String name;
  String email;
  String phone;
  String category;
  String experience;
  String address;
  String? imageUrl; // To store the profile image URL (if uploaded)

  Teacher({
    required this.name,
    required this.email,
    required this.phone,
    required this.category,
    required this.experience,
    required this.address,
    this.imageUrl,
  });

  // Convert to a map (Firestore format)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'category': category,
      'experience': experience,
      'address': address,
      'imageUrl': imageUrl,
    };
  }

  // Create a Teacher object from Firestore data
  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      category: map['category'],
      experience: map['experience'],
      address: map['address'],
      imageUrl: map['imageUrl'],
    );
  }
}
