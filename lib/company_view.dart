import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerDetailPage extends StatelessWidget {
  final String companyName;
  final String phone;
  final String email;
  final String address;
  final String productCategory;
  final String? profileImageUrl;

  const SellerDetailPage({
    super.key,
    required this.companyName,
    required this.phone,
    required this.email,
    required this.address,
    required this.productCategory,
    this.profileImageUrl,
  });

  // Function to open Gmail app
  void _openGmail(BuildContext context) async {
    final Uri gmailUri = Uri(
      scheme: 'https',
      host: 'mail.google.com',
      path: 'mail/u/0/',
      queryParameters: {
        'view': 'cm',
        'fs': '1',
        'to': email,
        'su': 'Inquiry from Your App',
        'body': 'Hello, I have a question about your products.',
      },
    );

    print('Gmail URI: $gmailUri'); // Debugging: Print the URI

    // Try to launch Gmail
    if (await canLaunchUrl(gmailUri)) {
      await launchUrl(gmailUri);
    } else {
      // If Gmail is not installed, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gmail app not found. Please install Gmail.')),
      );
    }
  }

  // Function to call the seller
  void _makeCall() async {
    final Uri callUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Company Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF380230), Color(0xFF69045F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image with Shadow
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.white,
                      backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null || profileImageUrl!.isEmpty
                          ? const Icon(Icons.business, size: 60, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Company Name
                  Text(
                    companyName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Details Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.phone, "Phone", phone, () => _makeCall()),
                          const Divider(thickness: 1, height: 25),
                          _buildDetailRow(Icons.email, "Email", email, () => _openGmail(context)),
                          const Divider(thickness: 1, height: 25),
                          _buildDetailRow(Icons.location_on, "Address", address, null),
                          const Divider(thickness: 1, height: 25),
                          _buildDetailRow(Icons.category, "Category", productCategory, null),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Contact Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _makeCall,
                        icon: const Icon(Icons.call, color: Colors.white),
                        label: const Text("Call"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton.icon(
                        onPressed: () => _openGmail(context),
                        icon: const Icon(Icons.email, color: Colors.white),
                        label: const Text("Email"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF380230), size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}