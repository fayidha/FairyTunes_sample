import 'package:dupepro/home.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, String> shippingAddress;
  const PaymentScreen({super.key, required this.shippingAddress});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _razorpay = Razorpay();

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
      SnackBar(content: Text('Payment Success: ${response.paymentId}')),
    );

    final orderData = {
      'paymentId': response.paymentId,
      'amount': widget.shippingAddress['amount'],
      'email': widget.shippingAddress['email'],
      'phone': widget.shippingAddress['phone'],
      'shippingAddress': widget.shippingAddress,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('orders').add(orderData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order saved successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
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
    final options = {
      'key': 'rzp_test_zrejXWOWxRf29k', // Replace with your Razorpay key
      'amount': int.parse(widget.shippingAddress['amount']!) * 100,
      'currency': 'INR',
      'name': 'My App',
      'description': 'Payment for Order',
      'prefill': {
        'contact': widget.shippingAddress['phone'],
        'email': widget.shippingAddress['email'],
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
        title: const Text('Payment',style: TextStyle(color: Colors.white),),
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
                    _buildDetailRow('Name', shippingAddress['name']!),
                    _buildDetailRow('Address', shippingAddress['address']!),
                    _buildDetailRow('City', shippingAddress['city']!),
                    _buildDetailRow('State', shippingAddress['state']!),
                    _buildDetailRow('Zip', shippingAddress['zip']!),
                    _buildDetailRow('Country', shippingAddress['country']!),
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
            _buildPaymentDetailRow('Email', shippingAddress['email']!),
            _buildPaymentDetailRow('Phone Number', shippingAddress['phone']!),
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