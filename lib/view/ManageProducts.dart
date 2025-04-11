import 'package:dupepro/view/Advertisements_Add.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dupepro/model/Product_model.dart';
import 'package:dupepro/controller/Product_Controller.dart';


class ManageProducts extends StatefulWidget {
  const ManageProducts({super.key});

  @override
  State<ManageProducts> createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  final ProductController _productController = ProductController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  void _viewProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Products",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF380230),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('uid', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products found"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Product product = Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              return GestureDetector(
                onTap: () => _viewProductDetails(product),
                child: Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            product.imageUrls[0],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Price: \$${product.price.toStringAsFixed(2)}"),
                            Text("Sizes: ${product.sizes.join(', ')}"),
                            Text("Colors: ${product.colors.join(', ')}"),
                            Text("Description: ${product.description}"),
                          ],
                        ),
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
}


class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: const Color(0xFF380230),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.imageUrls.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      product.imageUrls[0],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text("Category: ${product.category}", style: const TextStyle(fontSize: 16)),
              Text("Company: ${product.company}", style: const TextStyle(fontSize: 16)),
              Text("Price: \$${product.price}", style: const TextStyle(fontSize: 16)),
              Text("Quantity: ${product.quantity}", style: const TextStyle(fontSize: 16)),
              Text("Sizes: ${product.sizes.join(', ')}", style: const TextStyle(fontSize: 16)),
              Text("Colors: ${product.colors.join(', ')}", style: const TextStyle(fontSize: 16)),
              Text("Description: ${product.description}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),

              /// Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A0572), Color(0xFFB0256F)], // Gradient for Edit
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProductScreen(product: product)),
                        ),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text("Edit Product", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Space between buttons
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF380230), Color(0xFF7A1F5F)], // Gradient for Ad
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddAdvertisementPage(productId: product.id),
                          ),
                        ),
                        icon: const Icon(Icons.campaign, color: Colors.white),
                        label: const Text("Add Advertisement", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10), // Space between button rows
              // New View Orders Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF880E4F)], // Gradient for View Orders
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Add your navigation logic for viewing orders here
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewOrdersScreen(productId: product.id)),
                    );
                  },
                  icon: const Icon(Icons.list_alt, color: Colors.white),
                  label: const Text("View Orders", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewOrdersScreen extends StatelessWidget {
  final String productId;

  const ViewOrdersScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Product Orders'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A148C), Color(0xFF880E4F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF4F3F8),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading orders.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A148C)),
              ),
            );
          }

          final matchingOrders = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final cartItems = (data['cartItems'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            return cartItems.any((item) => item['productId'] == productId);
          }).toList();

          if (matchingOrders.isEmpty) {
            return const Center(
              child: Text(
                'No orders found for this product.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matchingOrders.length,
            itemBuilder: (context, index) {
              final order = matchingOrders[index];
              final data = order.data() as Map<String, dynamic>;
              final cartItems = (data['cartItems'] as List).cast<Map<String, dynamic>>();
              final productItems = cartItems.where((item) => item['productId'] == productId).toList();

              return _buildOrderCard(
                context,
                orderId: order.id,
                data: data,
                productItems: productItems,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, {
        required String orderId,
        required Map<String, dynamic> data,
        required List<Map<String, dynamic>> productItems,
      }) {
    final shippingAddress = data['shippingAddress'] as Map<String, dynamic>?;
    final timestamp = data['timestamp'] as Timestamp?;
    final status = data['status'] as String? ?? 'completed';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${orderId.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusTextColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...productItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (item['imageUrl'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['imageUrl'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] ?? 'Product',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                        Text('Qty: ${item['quantity']}  Size: ${item['size']}'),
                        Text('Color: ${item['color']}  Price: ₹${item['price']}'),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const Divider(height: 24),
            const Text('Customer Info',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 4),
            _buildOrderDetailRow('Name', shippingAddress?['name'] ?? 'N/A'),
            _buildOrderDetailRow('Phone', shippingAddress?['phone'] ?? 'N/A'),
            _buildOrderDetailRow('Email', data['email'] ?? 'N/A'),
            _buildOrderDetailRow('Total', '₹${data['amount'] ?? '0.00'}'),
            _buildOrderDetailRow('Date', timestamp != null ? _formatDate(timestamp) : 'N/A'),
            const SizedBox(height: 16),
            if (status == 'completed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateOrderStatus(context, orderId, 'shipped'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Mark as Shipped',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(BuildContext context, String orderId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': status,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order status')),
      );
    }
  }

  Widget _buildOrderDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'shipped':
        return Colors.blue.shade100;
      case 'delivered':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default: // completed
        return Colors.orange.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'shipped':
        return Colors.blue.shade800;
      case 'delivered':
        return Colors.green.shade800;
      case 'cancelled':
        return Colors.red.shade800;
      default: // completed
        return Colors.orange.shade800;
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _companyController;
  late TextEditingController _quantityController;
  late TextEditingController _sizesController;
  late TextEditingController _colorsController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _categoryController = TextEditingController(text: widget.product.category);
    _companyController = TextEditingController(text: widget.product.company);
    _quantityController = TextEditingController(text: widget.product.quantity.toString());
    _sizesController = TextEditingController(text: widget.product.sizes.join(', '));
    _colorsController = TextEditingController(text: widget.product.colors.join(', '));
    _descriptionController = TextEditingController(text: widget.product.description);
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('products').doc(widget.product.id).update({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'category': _categoryController.text,
        'company': _companyController.text,
        'quantity': int.parse(_quantityController.text),
        'sizes': _sizesController.text.split(',').map((e) => e.trim()).toList(),
        'colors': _colorsController.text.split(',').map((e) => e.trim()).toList(),
        'description': _descriptionController.text,
      });
      Navigator.pop(context);
    }
  }

  Future<void> _deleteProduct() async {
    await FirebaseFirestore.instance.collection('products').doc(widget.product.id).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Product Name")),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
              TextFormField(controller: _categoryController, decoration: const InputDecoration(labelText: "Category")),
              TextFormField(controller: _companyController, decoration: const InputDecoration(labelText: "Company")),
              TextFormField(controller: _quantityController, decoration: const InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
              TextFormField(controller: _sizesController, decoration: const InputDecoration(labelText: "Sizes")),
              TextFormField(controller: _colorsController, decoration: const InputDecoration(labelText: "Colors")),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Description")),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(onPressed: _updateProduct, child: const Text("Update")),
                  ElevatedButton(
                    onPressed: () async {
                      bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Product"),
                          content: const Text("Are you sure you want to delete this product?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        _deleteProduct();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}