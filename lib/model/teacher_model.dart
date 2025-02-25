class Teacher {
  final String uid;
  final String teacherId;
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
      'imageUrl': imageUrl, // Ensure imageUrl is included here
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      uid: map['uid'] ?? "Unknown UID",
      teacherId: map['teacherId'] ?? "Unknown ID",
      name: map['name'] ?? "No Name",
      email: map['email'] ?? "No Email",
      phone: map['phone'] ?? "No Phone",
      category: map['category'] ?? "No Category",
      qualification: map['qualification'] ?? "No Qualification",
      experience: map['experience'] ?? "No Experience",
      address: map['address'] ?? "No Address",
      imageUrl: map['imageUrl'], // Ensure imageUrl is retrieved here
    );
  }
}