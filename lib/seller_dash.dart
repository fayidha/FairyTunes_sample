
import 'package:dupepro/view/ManageProducts.dart';
import 'package:dupepro/view/Vendor_add_product.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(context),
              SizedBox(height: 20),
              _buildGradientHeader(),
              SizedBox(height: 20),
              Expanded(child: _buildDashboardGrid(context)),
              SizedBox(height: 20),
              _buildGradientButton("Add Product", Icons.add, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddProduct()));
              }),
              SizedBox(height: 20),
              _buildAdvertisementSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF6A0D54)),
          onPressed: () => Navigator.pop(context),
        ),
        Text("Seller Dashboard", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6A0D54))),
      ],
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A0D54), Color(0xFF380230)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome Seller", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 6),
          Text("Manage your store effectively", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      physics: BouncingScrollPhysics(),
      children: [
        _buildDashboardCard(context, "Added Products", "View", Icons.inventory, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ManageProducts()));
        }),
        _buildDashboardCard(context, "Orders", "340", Icons.receipt, () {
          _showRecentOrdersDialog(context);
        }),
        _buildDashboardCard(context, "Revenue", "₹12,500", Icons.currency_rupee, () {}),
        _buildDashboardCard(context, "Advertisements", "Manage", Icons.campaign, () {}),
      ],
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Color(0xFF6A0D54)),
            SizedBox(height: 10),
            Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A0D54))),
            SizedBox(height: 5),
            Text(title, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, IconData icon, VoidCallback onPressed) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: GoogleFonts.poppins(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          backgroundColor: Color(0xFF6A0D54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildAdvertisementSection(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Advertisements", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A0D54))),
            SizedBox(height: 10),
            _buildGradientButton("Add Advertisements", Icons.campaign, () {
              // Navigator.push(
              //   context,
              //   // MaterialPageRoute(
              //     // builder: (context) => AddAdvertisementPage(productId: Product ['id']),
              //   ),
              // );

            }),
          ],
        ),
      ),
    );
  }

  void _showRecentOrdersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Recent Orders", style: GoogleFonts.poppins(color: Color(0xFF6A0D54))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRecentOrderItem("Order #1234", "Completed", "₹250"),
              _buildRecentOrderItem("Order #1235", "Pending", "₹180"),
              _buildRecentOrderItem("Order #1236", "Cancelled", "₹300"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: GoogleFonts.poppins(color: Color(0xFF6A0D54))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentOrderItem(String orderId, String status, String amount) {
    return ListTile(
      title: Text(orderId, style: GoogleFonts.poppins(color: Color(0xFF6A0D54))),
      subtitle: Text("Status: $status"),
      trailing: Text(amount, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
    );
  }
}