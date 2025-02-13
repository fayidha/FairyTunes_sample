import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cart Page',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const OrderHistoryPage(),
    );
  }
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Map<String, dynamic>> cartItems = [
    {'name': 'Guitar', 'price': 120.0, 'quantity': 1},
    {'name': 'Piano', 'price': 300.0, 'quantity': 2},
    {'name': 'Violin', 'price': 150.0, 'quantity': 1},
  ];

  double get totalPrice => cartItems.fold(0, (sum, item) => sum + item['price'] * item['quantity']);

  void _updateQuantity(int index, int change) {
    setState(() {
      cartItems[index]['quantity'] = (cartItems[index]['quantity'] + change).clamp(1, 100);
    });
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text('Price: \$${item['price']} x ${item['quantity']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _updateQuantity(index, -1),
                        ),
                        Text('${item['quantity']}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _updateQuantity(index, 1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Total: \$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: cartItems.isEmpty ? null : () => _showCheckoutDialog(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text('Checkout', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Checkout'),
        content: Text('Total: \$${totalPrice.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => cartItems.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order placed successfully!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
