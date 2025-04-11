import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/Product_model.dart';
import 'package:dupepro/view/detailPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Wishlist", style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF380230),
        ),
        body: Center(child: Text("Please login to view your wishlist")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Wishlist", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF380230),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('wishlist')
            .where('userId', isEqualTo: currentUser.uid) // <-- filter by current user
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 10),
                  Text(
                    "Your wishlist is empty!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Add items you love to your wishlist.",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          List<Product> wishlistItems = snapshot.data!.docs
              .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              Product product = wishlistItems[index];

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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product.imageUrls.isNotEmpty ? product.imageUrls[0] : 'assets/no_image.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 12),
                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 5),
                              Text(
                                product.company,
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5),
                              Text(
                                '₹${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF380230),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Wishlist Remove Button (Heart Icon)
                        IconButton(
                          icon: Icon(Icons.favorite, color: Color(0xFF380230), size: 28),
                          onPressed: () async {
                            await _firestore.collection('wishlist').doc(product.id).delete();
                          },
                        ),
                      ],
                    ),
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
