import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/company_view.dart';
import 'package:dupepro/view/Checkout.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dupepro/controller/cart_controller.dart';
import 'package:dupepro/model/cart_model.dart';
import 'package:dupepro/cart.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth to get uid

class ProductDetail extends StatefulWidget {
  final dynamic productId;

  const ProductDetail({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int _currentImageIndex = 0;
  String? _selectedColor;
  String? _selectedSize;
  int _quantity = 1; // Add a quantity counter

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() async {
    if (_selectedColor == null || _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select color and size!')),
      );
      return;
    }

    CartController cartController = CartController();
    User? user = FirebaseAuth.instance.currentUser; // Get current user

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be logged in to add items to the cart!')),
      );
      return;
    }

    CartItem cartItem = CartItem(
      id: widget.productId.id,
      name: widget.productId.name,
      price: widget.productId.price,
      quantity: _quantity, // Use the selected quantity
      imageUrl: widget.productId.imageUrls[0],
      color: _selectedColor!,
      size: _selectedSize!,
      uid: user.uid,
      productId: widget.productId.id, // Add productId
    );

    try {
      await cartController.addToCart(cartItem);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.productId.name} added to cart!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _buyNow() async {
    print("Buy Now button pressed"); // Debug print

    // Check if color and size are selected
    if (_selectedColor == null || _selectedSize == null) {
      print("Color or Dimensions not selected"); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select color and size!')),
      );
      return;
    }

    // Check if user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in"); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be logged in to proceed!')),
      );
      return;
    }

    // Check if product data is valid
    if (widget.productId == null || widget.productId.price == null || widget.productId.id == null) {
      print("Invalid product data"); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid product details!')),
      );
      return;
    }

    // Create a CartItem object
    CartItem cartItem = CartItem(
      id: widget.productId.id,
      name: widget.productId.name,
      price: widget.productId.price,
      quantity: _quantity, // Use the selected quantity
      imageUrl: widget.productId.imageUrls[0],
      color: _selectedColor!,
      size: _selectedSize!,
      uid: user.uid,
      productId: widget.productId.id,
    );

    print("Navigating to CheckoutPage"); // Debug print
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          totalAmount: widget.productId.price * _quantity, // Calculate total amount based on quantity
          cartItems: [cartItem], // Pass the CartItem object as a list
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> colors = widget.productId.colors ?? [];
    List<String> sizes = widget.productId.sizes ?? [];
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details", style: GoogleFonts.lora(color: Colors.white)),
        backgroundColor: Color(0xFF451626),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You need to be logged in to view your cart!')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage(uid: user.uid)),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF380230), Colors.grey[900]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              // Carousel for images
              CarouselSlider(
                options: CarouselOptions(
                  height: 260,
                  viewportFraction: 1,
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
                items: widget.productId.imageUrls.map<Widget>((imageUrl) {
                  return ClipRRect(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
              // Image indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.productId.imageUrls.length,
                      (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    width: _currentImageIndex == index ? 10 : 8,
                    height: _currentImageIndex == index ? 10 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
              // Product details
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.productId.name,
                      style: GoogleFonts.lora(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Category: ${widget.productId.category}",
                          style: GoogleFonts.lora(fontSize: 14, color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () async {
                            String companyName = widget.productId.company;

                            // Fetch seller details from Firestore
                            DocumentSnapshot sellerSnapshot = await FirebaseFirestore.instance
                                .collection('sellers')
                                .where('companyName', isEqualTo: companyName)
                                .get()
                                .then((querySnapshot) => querySnapshot.docs.first);

                            if (sellerSnapshot.exists) {
                              Map<String, dynamic> sellerData = sellerSnapshot.data() as Map<String, dynamic>;

                              // Navigate to SellerDetailPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SellerDetailPage(
                                    companyName: sellerData['companyName'] ?? 'No Company Name',
                                    phone: sellerData['phone'] ?? 'No Phone',
                                    email: sellerData['email'] ?? 'No email',
                                    address: sellerData['address'] ?? 'No Address',
                                    productCategory: sellerData['productCategory'] ?? 'No Category',
                                    profileImageUrl: sellerData['profileImage'] ?? '',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Seller details not found')),
                              );
                            }
                          },
                          child: Text(
                            "Brand: ${widget.productId.company}",
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEBB21D),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.productId.description,
                      style: GoogleFonts.lora(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.5,
                  maxChildSize: 0.9,
                  builder: (context, scrollController) {
                    return Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display colors
                            Text(
                              "Available Colors",
                              style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Wrap(
                              spacing: 8,
                              children: colors.map((color) {
                                bool isSelected = _selectedColor == color;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedColor = color;
                                    });
                                  },
                                  child: Chip(
                                    label: Text(
                                      color,
                                      style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                                    ),
                                    backgroundColor: isSelected ? Colors.purple : Colors.grey[300],
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 15),
                            // Display sizes
                            Text(
                              "Available Dimensions",
                              style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Wrap(
                              spacing: 8,
                              children: sizes.map((size) {
                                bool isSelected = _selectedSize == size;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSize = size;
                                    });
                                  },
                                  child: Chip(
                                    label: Text(
                                      size,
                                      style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                                    ),
                                    backgroundColor: isSelected ? Colors.purple : Colors.grey[300],
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₹${widget.productId.price}",
                                  style: GoogleFonts.lora(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                // Quantity selector
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, color: Colors.white),
                                      onPressed: _decrementQuantity,
                                    ),
                                    Text(
                                      '$_quantity',
                                      style: GoogleFonts.lora(fontSize: 18, color: Colors.white),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add, color: Colors.white),
                                      onPressed: _incrementQuantity,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            // Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: _buyNow, // Updated to call _buyNow
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFEBB21D),
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text("Buy Now", style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                ),
                                ElevatedButton(
                                  onPressed: _addToCart,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text("Add to Cart", style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}