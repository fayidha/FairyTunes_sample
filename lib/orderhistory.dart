import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  final List<Map<String, dynamic>> orders = const [
    {
      "orderId": "ORD12345",
      "date": "Feb 15, 2025",
      "items": ["Laptop", "Mouse"],
      "total": 1200.00,
      "status": "Delivered"
    },
    {
      "orderId": "ORD67890",
      "date": "Jan 28, 2025",
      "items": ["Smartphone", "Headphones"],
      "total": 950.50,
      "status": "Shipped"
    },
    {
      "orderId": "ORD24680",
      "date": "Dec 10, 2024",
      "items": ["Gaming Chair"],
      "total": 300.99,
      "status": "Cancelled"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: Colors.deepPurple,
      ),
      body: orders.isEmpty
          ? const Center(child: Text("No past orders found"))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(order["orderId"].substring(3)),
              ),
              title: Text("Order ID: ${order["orderId"]}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date: ${order["date"]}"),
                  Text("Items: ${order["items"].join(', ')}"),
                  Text("Total: \$${order["total"].toStringAsFixed(2)}"),
                ],
              ),
              trailing: Text(
                order["status"],
                style: TextStyle(
                  color: _getStatusColor(order["status"]),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Navigate to order details page if needed
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Delivered":
        return Colors.green;
      case "Shipped":
        return Colors.orange;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
