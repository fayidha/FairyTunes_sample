import 'package:dupepro/view/ManageProducts.dart';
import 'package:dupepro/view/Vendor_add_product.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerDashboard extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<int> _getProductCount() async {
    try {
      String uid = _auth.currentUser!.uid;
      var snapshot = await _firestore
          .collection('products')
          .where('uid', isEqualTo: uid)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print("Error fetching product count: $e");
      return 0;
    }
  }

  Future<double> _getTotalRevenue() async {
    try {
      String uid = _auth.currentUser!.uid;

      // First get all product IDs for this seller
      var productsSnapshot = await _firestore
          .collection('products')
          .where('uid', isEqualTo: uid)
          .get();

      List<String> productIds = productsSnapshot.docs.map((doc) => doc.id).toList();

      if (productIds.isEmpty) return 0.0;

      // Get all completed orders that contain any of these products
      var ordersSnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'completed')
          .get();

      double totalRevenue = 0.0;

      for (var orderDoc in ordersSnapshot.docs) {
        var cartItems = orderDoc['cartItems'] as List;
        var orderAmount = double.tryParse(orderDoc['amount'] ?? '0') ?? 0.0;

        // Check if any product in this order belongs to our seller
        bool hasSellerProduct = cartItems.any((item) =>
            productIds.contains(item['productId']));

        if (hasSellerProduct) {
          // Calculate seller's share (for simplicity, we'll assume full amount goes to seller)
          // In a real app, you might want to calculate based on commission or split
          totalRevenue += orderAmount;
        }
      }

      return totalRevenue;
    } catch (e) {
      print("Error fetching revenue: $e");
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              SizedBox(height: 24),
              _buildHeaderCard(),
              SizedBox(height: 24),
              Expanded(child: _buildDashboardGrid(context)),
              SizedBox(height: 16),
              _buildAddProductButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF380230)),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          "Seller Dashboard",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF380230),
          ),
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.notifications_none, color: Color(0xFF380230)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        _getProductCount(),
        _getTotalRevenue(),
      ]).then((results) => {
        'productCount': results[0],
        'totalRevenue': results[1],
      }),
      builder: (context, snapshot) {
        int productCount = snapshot.hasData ? snapshot.data!['productCount'] : 0;
        double totalRevenue = snapshot.hasData ? snapshot.data!['totalRevenue'] : 0.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF380230), Color(0xFF6A0DAD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Seller",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Manage your store effectively",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem("Total Revenue", "₹${totalRevenue.toStringAsFixed(2)}"),
                  _buildStatItem("Products", "$productCount"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return FutureBuilder<double>(
      future: _getTotalRevenue(),
      builder: (context, revenueSnapshot) {
        double revenue = revenueSnapshot.hasData ? revenueSnapshot.data! : 0.0;

        return GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          physics: BouncingScrollPhysics(),
          children: [
            _buildDashboardCard(
              context,
              "Products",
              Icons.inventory_2_outlined,
              Color(0xFF380230),
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageProducts()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              "Revenue",
              Icons.currency_rupee,
              Colors.green,
                  () {
                // Revenue action
              },
              value: "₹${revenue.toStringAsFixed(2)}",
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashboardCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap, {
        String? value,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            if (value != null)
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProduct()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF380230),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Add Product",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}