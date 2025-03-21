import 'package:dupepro/view/product.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, String?> shippingAddress; // Allow null values
  final List<String> productIds; // List of product IDs

  const PaymentScreen({super.key, required this.shippingAddress, required this.productIds});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  final _razorpay = Razorpay();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful! Order placed.')),
    );

    // Get the current user's UID
    final User? user = _auth.currentUser;
    final String uid = user?.uid ?? '';

    // Prepare initial order data (without payment details)
    final orderData = {
      'uid': uid, // Add the user's UID
      'productIds': widget.productIds, // Add the list of product IDs
      'amount': widget.shippingAddress['amount'],
      'email': widget.shippingAddress['email'] ?? '', // Handle null email
      'shippingAddress': widget.shippingAddress, // Phone is included here
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending', // Initial status
    };

    try {
      // Step 1: Create the Firestore document first
      DocumentReference orderRef = await FirebaseFirestore.instance.collection('orders').add(orderData);

      // Step 2: Use the auto-generated Firestore document ID as the orderId
      final String orderId = orderRef.id;

      // Step 3: Update the document with payment details
      await orderRef.update({
        'orderId': orderId, // Add the document ID as the orderId
        'paymentId': response.paymentId,
        'status': 'completed', // Update status to completed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order saved successfully!')),
      );

      // Navigate to the ProductList screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProductList()),
      );
    } catch (e) {
      debugPrint('Error saving order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save order: $e')),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  void _openRazorpay() {
    // Parse the amount as a double first, then convert it to an integer
    final amountInRupees = double.parse(widget.shippingAddress['amount']!);
    final amountInPaise = (amountInRupees * 100).toInt(); // Convert to paise

    final options = {
      'key': 'rzp_test_zrejXWOWxRf29k', // Replace with your Razorpay key
      'amount': amountInPaise, // Use the converted amount
      'currency': 'INR',
      'name': 'FairyTunes',
      'description': 'Payment for Order',
      'prefill': {
        'contact': widget.shippingAddress['phone'] ?? '', // Handle null phone
        'email': widget.shippingAddress['email'] ?? '', // Handle null email
      },
      'notes': {'country': 'India'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final shippingAddress = widget.shippingAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF380230),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF380230), // Deep Purple
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Name', shippingAddress['name'] ?? 'N/A'),
                    _buildDetailRow('Address', shippingAddress['address'] ?? 'N/A'),
                    _buildDetailRow('City', shippingAddress['city'] ?? 'N/A'),
                    _buildDetailRow('State', shippingAddress['state'] ?? 'N/A'),
                    _buildDetailRow('Zip', shippingAddress['zip'] ?? 'N/A'),
                    _buildDetailRow('Country', shippingAddress['country'] ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Payment Details Section
            Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF380230), // Deep Purple
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentDetailRow('Amount', '₹${shippingAddress['amount']}'),
            _buildPaymentDetailRow('Email', shippingAddress['email'] ?? 'N/A'),
            _buildPaymentDetailRow('Phone Number', shippingAddress['phone'] ?? 'N/A'),
            const SizedBox(height: 24),
            // Pay Button
            Center(
              child: ElevatedButton(
                onPressed: _openRazorpay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFEBB21D), // Golden Yellow
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Pay Now",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black), // Black text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF380230), // Deep Purple
              ),
            ),
            Text(
              value,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}