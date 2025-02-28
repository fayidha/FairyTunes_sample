import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/cart_model.dart';

class CartController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveCart(String userId, List<CartItem> cartItems) async {
    await _firestore.collection('carts').doc(userId).set({
      'items': cartItems.map((item) => item.toMap()).toList(),
      'totalPrice': cartItems.fold(0.0, (double sum, CartItem item) => sum + (item.price * item.quantity)),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<CartItem>> loadCart(String userId) async {
    DocumentSnapshot cartSnapshot = await _firestore.collection('carts').doc(userId).get();
    if (cartSnapshot.exists) {
      List<dynamic> items = cartSnapshot['items'];
      return items.map((item) => CartItem.fromMap(item)).toList();
    }
    return [];
  }

  Future<void> clearCart(String userId) async {
    await _firestore.collection('carts').doc(userId).delete();
  }
}
