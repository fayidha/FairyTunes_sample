import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/Product_model.dart';
import 'package:dupepro/view/detailPage.dart';
import 'package:shimmer/shimmer.dart';

class ProductCategoryPage extends StatefulWidget {
  final String selectedCategory;

  ProductCategoryPage({required this.selectedCategory});

  @override
  _ProductCategoryPageState createState() => _ProductCategoryPageState();
}

class _ProductCategoryPageState extends State<ProductCategoryPage> {
  List<Product> products = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchProducts(widget.selectedCategory);
  }

  Future<void> fetchProducts(String category) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          products = [];
          isLoading = false;
        });
        return;
      }

      List<Product> loadedProducts = querySnapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      if (mounted) {
        setState(() {
          products = loadedProducts;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.selectedCategory,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? _buildLoadingShimmer()
            : hasError
            ? _buildErrorWidget()
            : products.isEmpty
            ? _buildEmptyState()
            : _buildProductList(),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 100,
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          SizedBox(height: 10),
          Text("Oops! Something went wrong.", style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text("Please try again later.", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => fetchProducts(widget.selectedCategory),
            child: Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text("No products found.", style: TextStyle(fontSize: 18)),
          Text("Try a different category.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        Product product = products[index];
        return GestureDetector(
          onTap: () {
            // Navigate to ProductDetail page when tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetail(productId: product),
              ),
            );
          },
          child: Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.imageUrls.isNotEmpty
                        ? Image.network(
                      product.imageUrls.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                        : Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
                  SizedBox(width: 12),
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  // Forward Icon
                  Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
