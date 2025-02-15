// model/seller_model.dart
class Seller {
  String uid;
  String companyName;
  String email;
  String phone;
  String address;
  String productCategory;
  String? profileImage;

  Seller({
    required this.uid,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.address,
    required this.productCategory,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'companyName': companyName,
      'email': email,
      'phone': phone,
      'address': address,
      'productCategory': productCategory,
      'profileImage': profileImage,
    };
  }

  factory Seller.fromMap(Map<String, dynamic> map) {
    return Seller(
      uid: map['uid'] ?? '',
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      productCategory: map['productCategory'] ?? '',
      profileImage: map['profileImage'],
    );
  }
}
