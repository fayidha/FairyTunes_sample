import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dupepro/model/seller_model.dart';

class SellerDetailPage extends StatelessWidget {
  final Seller seller;

  const SellerDetailPage({Key? key, required this.seller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF380230), Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 60),
            // Seller Profile Image
            CircleAvatar(
              radius: 50,
              backgroundImage: seller.profileImage != null
                  ? NetworkImage(seller.profileImage!)
                  : AssetImage('assets/default_logo.png') as ImageProvider,
            ),
            SizedBox(height: 20),

            // Seller Info
            Text(
              seller.companyName,
              style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              seller.productCategory,
              style: GoogleFonts.lora(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 20),

            // Seller Contact Details
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildInfoRow(Icons.email, seller.email),
                  _buildInfoRow(Icons.phone, seller.phone),
                  _buildInfoRow(Icons.location_on, seller.address),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lora(fontSize: 16, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
