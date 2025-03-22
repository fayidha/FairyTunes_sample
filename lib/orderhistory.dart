import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final String uid = user?.uid ?? '';

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('uid', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderData = order.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: ${orderData['orderId']}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Total Amount: ₹${orderData['amount']}'),
                      Text('Status: ${orderData['status']}'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _showInvoice(context, orderData),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEBB21D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('View Invoice',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showInvoice(BuildContext context, Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invoice Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${orderData['orderId']}'),
                Text('Total Amount: ₹${orderData['amount']}'),
                Text('Status: ${orderData['status']}'),
                const SizedBox(height: 10),
                const Text('Items:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                for (var item in orderData['cartItems'])
                  ListTile(
                    title: Text(item['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Color: ${item['color']}'),
                        Text('Size: ${item['size']}'),
                        Text('Qty: ${item['quantity']}  - ₹${item['price']}'),
                      ],
                    ),
                    leading: Image.network(item['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 10),
                const Text('Deliver To:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Address: ${orderData['shippingAddress']['address']}'),
                Text('City: ${orderData['shippingAddress']['city']}'),
                Text('State: ${orderData['shippingAddress']['state']}'),
                Text('Zip: ${orderData['shippingAddress']['zip']}'),
                Text('Country: ${orderData['shippingAddress']['country']}'),
                Text('Landmark: ${orderData['shippingAddress']['landmark'] ?? 'N/A'}'),
                Text('Phone: ${orderData['shippingAddress']['phone']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
