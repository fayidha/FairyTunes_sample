class CartItem {
  String id;
  String name;
  double price;
  int quantity;
  String imageUrl;
  String color;
  String size;
  String uid; // Add uid
  String productId; // Add productId

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.color,
    required this.size,
    required this.uid, // Add uid
    required this.productId, // Add productId
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'color': color,
      'size': size,
      'uid': uid, // Add uid
      'productId': productId, // Add productId
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, String id) {
    return CartItem(
      id: id,
      name: map['name'],
      price: map['price'].toDouble(),
      quantity: map['quantity'],
      imageUrl: map['imageUrl'],
      color: map['color'],
      size: map['size'],
      uid: map['uid'], // Add uid
      productId: map['productId'], // Add productId
    );
  }
}