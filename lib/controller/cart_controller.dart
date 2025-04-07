import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/cart_model.dart';

class CartController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a product to the cart for a specific user
  Future<void> addToCart(CartItem item) async {
    try {
      await _firestore.collection('cart').doc(item.id).set(item.toMap());
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  // Fetch cart items for a specific user
  Future<List<CartItem>> fetchCartItems(String uid) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('cart')
          .where('uid', isEqualTo: uid) // Filter by user ID
          .get();
      return snapshot.docs
          .map((doc) => CartItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error fetching cart items: $e");
      return [];
    }
  }

  // Update the quantity of a cart item
  Future<void> updateQuantity(String id, int quantity) async {
    if (quantity > 0) {
      await _firestore.collection('cart').doc(id).update({'quantity': quantity});
    } else {
      await removeItem(id); // Remove the item if quantity is 0 or less
    }
  }

  // Remove a cart item
  Future<void> removeItem(String id) async {
    await _firestore.collection('cart').doc(id).delete();
  }
}
