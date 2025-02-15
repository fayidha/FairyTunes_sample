class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String company;
  final List<String> imageUrls;

  Product({this.id = '', required this.name, required this.description, required this.price, required this.company, required this.imageUrls});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'company': company,
      'imageUrls': imageUrls,
    };
  }
}
