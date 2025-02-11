import 'package:dupepro/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetail extends StatelessWidget {
  final int productIndex;

  ProductDetail({required this.productIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Detail", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF380230),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product description
            Text(
              'Product ${productIndex + 1} - A great choice for your needs!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'This is a detailed description of the product that explains its features, quality, and benefits. It is made with high-quality materials and offers great value.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 20),

            // Carousel Slider
            CarouselSlider(
              items: [
                'asset/210379377.png',
                'asset/img1.jpg',
                'asset/music.jpg'
              ]
                  .map((item) => Image.asset(
                item,
                fit: BoxFit.cover,
                width: double.infinity,
              ))
                  .toList(),
              options: CarouselOptions(
                height: 150,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
              ),
            ),

            // Price and Company Name
            SizedBox(height: 20),
            Text(
              'Company Name',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            Text(
              '\ ₹${(productIndex + 1) * 20}',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF380230)),
            ),
            SizedBox(height: 20),

            // Additional Description
            Text(
              'More about this product:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'This product is designed for those who love to experience comfort and style. It offers long-lasting durability and comes with a satisfaction guarantee.',
              style: TextStyle(color: Colors.grey[700]),
            ),

            // Add to Cart and Buy Buttons
            SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OrderHistoryPage(),));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF380230),
                      foregroundColor: Color(0xFFFFFFFF),
                    ),
                    child: Text('Add to Cart'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Buy functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Color(0xFFFFFFFF),
                    ),
                    child: Text('Buy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}