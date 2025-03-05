import 'package:carousel_slider/carousel_slider.dart';
import 'package:dupepro/cart.dart';
import 'package:dupepro/controller/Seller_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dupepro/view/seller_detail_page.dart';
import 'package:dupepro/model/seller_model.dart';

class ProductDetail extends StatefulWidget {
  final dynamic product;

  const ProductDetail({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int _currentImageIndex = 0;
  String? _selectedColor;
  String? _selectedSize;

  void _navigateToSellerPage() async {
    SellerController sellerController = SellerController();
    Seller? seller = await sellerController.getSellerDetails(widget.product.uid);

    if (seller != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellerDetailPage(seller: seller),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seller details not found!')),
      );
    }
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> colors = widget.product.colors ?? [];
    List<String> sizes = widget.product.sizes ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details", style: GoogleFonts.lora(color: Colors.white)),
        backgroundColor: Color(0xFF451626),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: _navigateToCart,
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
                items: widget.product.imageUrls.map<Widget>((imageUrl) {
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
                  widget.product.imageUrls.length,
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
                            Text(
                              widget.product.name,
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
                                  "Category: ${widget.product.category}",
                                  style: GoogleFonts.lora(fontSize: 14, color: Colors.white70),
                                ),
                                TextButton(
                                  onPressed: _navigateToSellerPage,
                                  child: Text(
                                    "Brand: ${widget.product.company}",
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
                              widget.product.description,
                              style: GoogleFonts.lora(fontSize: 16, color: Colors.white70),
                            ),
                            SizedBox(height: 15),
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
                              "Available Sizes",
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
                                  "₹${widget.product.price}",
                                  style: GoogleFonts.lora(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                Text(
                                  "Quantity: ${widget.product.quantity}",
                                  style: GoogleFonts.lora(fontSize: 16, color: Colors.white70),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            // Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
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
                                  onPressed: _navigateToCart,
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
