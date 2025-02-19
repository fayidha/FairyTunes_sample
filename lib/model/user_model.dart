class UserModel {
  final String uid;
  final String name;
  final String email;
  final String password;

  UserModel({required this.uid, required this.name, required this.email,required this.password});

  // Convert UserModel to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password':password,
      'userProfile':'https://firebasestorage.googleapis.com/v0/b/zootopia-ae68f.firebasestorage.app/o/images.png?alt=media&token=bd64e9a4-11fd-409f-83d3-dd2fa0f93e77'
    };
  }

  // Convert Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }
}
