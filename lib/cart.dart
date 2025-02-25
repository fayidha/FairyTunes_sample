import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [
    {"name": "Laptop", "price": 999.99, "quantity": 1},
    {"name": "Headphones", "price": 199.99, "quantity": 1},
    {"name": "Smartphone", "price": 799.99, "quantity": 1},
  ];

  double get totalPrice => cartItems.fold(
      0, (sum, item) => sum + (item["price"] * item["quantity"]));

  void updateQuantity(int index, int change) {
    setState(() {
      if (cartItems[index]["quantity"] + change > 0) {
        cartItems[index]["quantity"] += change;
      } else {
        cartItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Cart"),
        backgroundColor: Colors.deepPurple,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(item["name"][0], style: const TextStyle(color: Colors.deepPurple)),
              ),
              title: Text(item["name"]),
              subtitle: Text("\$${item["price"].toStringAsFixed(2)}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.red),
                    onPressed: () => updateQuantity(index, -1),
                  ),
                  Text(item["quantity"].toString()),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () => updateQuantity(index, 1),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total: \$${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Checkout not implemented")),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text("Checkout"),
            ),
          ],
        ),
      ),
    );
  }
}
