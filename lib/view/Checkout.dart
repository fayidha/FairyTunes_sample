import 'package:dupepro/view/payment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPage extends StatefulWidget {
  final double totalAmount;
  final List<String> productIds;

  const CheckoutPage({required this.totalAmount, required this.productIds});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  User? _currentUser = FirebaseAuth.instance.currentUser;
  String? selectedAddressId;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Stream<QuerySnapshot> _getUserAddresses() {
    return FirebaseFirestore.instance
        .collection('locations')
        .where('userId', isEqualTo: _currentUser!.uid)
        .snapshots();
  }

  void _confirmOrder() {
    if (selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an address")),
      );
      return;
    }

    // Fetch the selected address details
    FirebaseFirestore.instance
        .collection('locations')
        .doc(selectedAddressId)
        .get()
        .then((doc) {
      if (doc.exists) {
        Map<String, String?> shippingAddress = {
          'name': doc['name'],
          'address': doc['address'],
          'city': doc['city'],
          'state': doc['state'],
          'zip': doc['zip'],
          'country': doc['country'],
          'landmark': doc['landmark'], // This can be null
          'phone': doc['phone'],
          'amount': widget.totalAmount.toString(),
          'email': _currentUser!.email, // This can be null
        };

        // Navigate to the PaymentScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              shippingAddress: shippingAddress,
              productIds: widget.productIds, // Pass the list of product IDs
            ),
          ),
        );
      }
    });
  }

  void _addNewAddress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add New Address", style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                _buildTextField(_nameController, "Full Name"),
                _buildTextField(_addressController, "Address"),
                _buildTextField(_cityController, "City"),
                _buildTextField(_stateController, "State"),
                _buildTextField(_zipController, "ZIP Code"),
                _buildTextField(_countryController, "Country"),
                _buildTextField(_landmarkController, "Landmark (optional)"),
                _buildTextField(_phoneController, "Phone Number"),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEBB21D),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Save Address",
                      style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  void _saveAddress() async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _zipController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('locations').add({
      'userId': _currentUser!.uid,
      'name': _nameController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'zip': _zipController.text,
      'country': _countryController.text,
      'landmark': _landmarkController.text,
      'phone': _phoneController.text,
    });

    // Clear controllers
    _nameController.clear();
    _addressController.clear();
    _cityController.clear();
    _stateController.clear();
    _zipController.clear();
    _countryController.clear();
    _landmarkController.clear();
    _phoneController.clear();

    Navigator.pop(context); // Close the bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout", style: GoogleFonts.lora(color: Colors.white)),
        backgroundColor: Color(0xFF380230),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Select Address:", style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _addNewAddress,
                  child: Text("+ Add New", style: GoogleFonts.lora(color: Color(0xFFEBB21D), fontSize: 16)),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getUserAddresses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No saved addresses. Add one first."));
                }

                var addresses = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    var address = addresses[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: RadioListTile(
                        title: Text(address['name'], style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${address['address']}, ${address['city']}"),
                            Text("${address['state']}, ${address['zip']}"),
                            Text("${address['country']}"),
                            if (address['landmark'] != null && address['landmark'].isNotEmpty)
                              Text("Landmark: ${address['landmark']}"),
                            Text("Phone: ${address['phone']}"),
                          ],
                        ),
                        value: address.id,
                        groupValue: selectedAddressId,
                        onChanged: (value) {
                          setState(() {
                            selectedAddressId = value as String?;
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total: ₹${widget.totalAmount.toStringAsFixed(2)}",
                    style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEBB21D),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Proceed to Payment",
                      style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}