import 'package:dupepro/view/Vendor_add_product.dart';
import 'package:flutter/material.dart';

class SellerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient Header
            _buildGradientHeader(),
            SizedBox(height: 20),

            // Sales Stats Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDashboardCard("Total Sales", "1,200", Icons.shopping_cart),
                _buildDashboardCard("Orders", "340", Icons.receipt),
                _buildDashboardCard("Revenue", "₹12,500", Icons.currency_rupee),
              ],
            ),
            SizedBox(height: 20),

            // Add Product & View Orders Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGradientButton("Add Product", Icons.add, () {
                 Navigator.push(context, MaterialPageRoute(builder:  (context) => AddProduct(),)); // Navigate to Add Product Page
                }),
                _buildGradientButton("Recent Orders", Icons.history, () {
                  _showRecentOrdersDialog(context);
                }),
              ],
            ),
            SizedBox(height: 20),

            // Best Selling Products
            Text(
              "Best Selling Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF380230)),
            ),
            SizedBox(height: 10),

            _buildProductItem("Music Album", "₹799", "asset/music.jpg"),
            _buildProductItem("Wireless Headphones", "₹4,999", "asset/music.jpg"),
            _buildProductItem("Gaming Mouse", "₹2,499", "asset/music.jpg"),
            _buildProductItem("Mechanical Keyboard", "₹5,999", "asset/music.jpg"),
          ],
        ),
      ),
    );
  }

  // 🔥 Gradient Header
  Widget _buildGradientHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 50, horizontal: 70),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF380230), Color(0xFF6A0D54)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            " Welcome Seller",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 2),
          Text(
            "Manage your store effectively",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // 📊 Dashboard Cards
  Widget _buildDashboardCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        color: Color(0xFF380230).withOpacity(0.15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Color(0xFF380230)),
              SizedBox(height: 10),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF380230))),
              SizedBox(height: 5),
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 Gradient Button
  Widget _buildGradientButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: TextStyle(fontSize: 16),
        backgroundColor: Color(0xFF380230),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // 🛍️ Best Selling Products
  Widget _buildProductItem(String name, String price, String imagePath) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imagePath.startsWith("http")
              ? Image.network(imagePath, width: 50, height: 50, fit: BoxFit.cover)
              : Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF380230))),
        trailing: Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
      ),
    );
  }

  // 🛒 Show Recent Orders Dialog
  void _showRecentOrdersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Recent Orders", style: TextStyle(color: Color(0xFF380230))),
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
              child: Text("Close", style: TextStyle(color: Color(0xFF380230))),
            ),
          ],
        );
      },
    );
  }

  // 🛍️ Recent Orders List Item
  Widget _buildRecentOrderItem(String orderId, String status, String amount) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(orderId, style: TextStyle(color: Color(0xFF380230))),
        subtitle: Text("Status: $status"),
        trailing: Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SellerDashboard()));
}
