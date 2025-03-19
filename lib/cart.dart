import 'package:dupepro/view/Checkout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dupepro/controller/cart_controller.dart';
import 'package:dupepro/model/cart_model.dart';

class CartPage extends StatefulWidget {
  final String uid;

  const CartPage({required this.uid});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartController _cartController = CartController();
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  // Load cart items for the current user
  Future<void> _loadCartItems() async {
    try {
      List<CartItem> items = await _cartController.fetchCartItems(widget.uid);
      setState(() {
        cartItems = items;
      });
    } catch (e) {
      print("Error loading cart items: $e");
    }
  }

  // Calculate the total price of all items in the cart
  double getTotalPrice() {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  // Update the quantity of a cart item
  void updateQuantity(String id, int change) async {
    await _cartController.updateQuantity(id, change);
    _loadCartItems(); // Refresh the cart items
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart", style: GoogleFonts.lora(color: Colors.white)),
        backgroundColor: Color(0xFF380230),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF380230), Colors.grey.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          cartItems.isEmpty
              ? Center(
            child: Text(
              "Your cart is empty",
              style: GoogleFonts.lora(fontSize: 18, color: Colors.white70),
            ),
          )
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      color: Colors.grey.shade900,
                      child: ListTile(
                        leading: Image.network(
                          item.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.name, style: GoogleFonts.lora(color: Colors.white)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("₹${item.price}", style: GoogleFonts.lora(color: Colors.greenAccent)),
                            Text("Color: ${item.color}", style: GoogleFonts.lora(color: Colors.white70)),
                            Text("Size: ${item.size}", style: GoogleFonts.lora(color: Colors.white70)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, color: Colors.red),
                              onPressed: () => updateQuantity(item.id, item.quantity - 1),
                            ),
                            Text("${item.quantity}", style: GoogleFonts.lora(color: Colors.white)),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.green),
                              onPressed: () => updateQuantity(item.id, item.quantity + 1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total: ₹${getTotalPrice().toStringAsFixed(2)}",
                      style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,MaterialPageRoute(builder: (context) => CheckoutPage(totalAmount: getTotalPrice(),),));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Proceeding to Checkout')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEBB21D),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Checkout",
                          style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}