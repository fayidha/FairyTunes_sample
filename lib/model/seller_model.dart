
// model/seller_model.dart
class Seller {
  String id;
  String companyName;
  String email;
  String phone;
  String address;
  String productCategory;
  String? profileImage;

  Seller({
    this.id = '',
    required this.companyName,
    required this.email,
    required this.phone,
    required this.address,
    required this.productCategory,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'email': email,
      'phone': phone,
      'address': address,
      'productCategory': productCategory,
      'profileImage': profileImage,
    };
  }

  factory Seller.fromMap(String id, Map<String, dynamic> map) {
    return Seller(
      id: id,
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      productCategory: map['productCategory'] ?? '',
      profileImage: map['profileImage'],
    );
  }
}