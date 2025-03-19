import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/Product_model.dart';
import 'package:dupepro/view/detailPage.dart';
import 'package:dupepro/view/wishlist.dart';
import 'package:flutter/material.dart';

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<String> wishlist = {}; // Track wishlist items
  String searchQuery = ''; // Track search query

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  // Load wishlist items from Firestore
  void _loadWishlist() async {
    QuerySnapshot snapshot = await _firestore.collection('wishlist').get();
    setState(() {
      wishlist = snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  void _toggleWishlist(Product product) async {
    DocumentReference wishlistRef = _firestore.collection('wishlist').doc(product.id);
    if (wishlist.contains(product.id)) {
      await wishlistRef.delete();
      setState(() {
        wishlist.remove(product.id);
      });
    } else {
      await wishlistRef.set(product.toMap());
      setState(() {
        wishlist.add(product.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF380230),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WishlistPage()),
              );
            },
          ),
        ],
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search by name or company...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No products available"));
          }

          List<Product> products = snapshot.data!.docs
              .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          // Filter products based on search query
          List<Product> filteredProducts = products.where((product) {
            return product.name.toLowerCase().contains(searchQuery) ||
                product.company.toLowerCase().contains(searchQuery);
          }).toList();

          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              Product product = filteredProducts[index];
              bool isWishlisted = wishlist.contains(product.id);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetail(productId: product),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                          child: product.imageUrls.isNotEmpty
                              ? Image.network(
                            product.imageUrls[0],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                              : Image.asset('assets/no_image.png', fit: BoxFit.cover, width: double.infinity),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              product.company,
                              style: TextStyle(color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\ ₹${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF380230)),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                                    color: Color(0xFF380230),
                                  ),
                                  onPressed: () => _toggleWishlist(product),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}