import 'package:dupepro/model/cart_model.dart';
import 'package:dupepro/view/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPage extends StatefulWidget {
  final double totalAmount;
  final List<CartItem> cartItems;

  const CheckoutPage({required this.totalAmount, required this.cartItems});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  User? _currentUser = FirebaseAuth.instance.currentUser;
  String? selectedAddressId;
  final _formKey = GlobalKey<FormState>();
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

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Enter exactly 10-digit phone number';
    }
    return null;
  }

  void _confirmOrder() {
    if (selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an address")),
      );
      return;
    }

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
          'landmark': doc['landmark'],
          'phone': doc['phone'],
          'amount': widget.totalAmount.toString(),
          'email': _currentUser!.email,
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              shippingAddress: shippingAddress,
              cartItems: widget.cartItems,
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Add New Address",
                      style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  _buildTextField(_nameController, "Full Name",
                      validator: (value) => _validateRequired(value, "name")),
                  _buildTextField(_addressController, "Address",
                      validator: (value) => _validateRequired(value, "address")),
                  _buildTextField(_cityController, "City",
                      validator: (value) => _validateRequired(value, "city")),
                  _buildTextField(_stateController, "State",
                      validator: (value) => _validateRequired(value, "state")),
                  _buildTextField(_zipController, "ZIP Code",
                      validator: (value) => _validateRequired(value, "ZIP code")),
                  _buildTextField(_countryController, "Country",
                      validator: (value) => _validateRequired(value, "country")),
                  _buildTextField(_landmarkController, "Landmark (optional)"),
                  _buildTextField(
                    _phoneController,
                    "Phone Number",
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveAddress();
                      }
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
                        "Save Address",
                        style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        String? Function(String?)? validator,
        TextInputType? keyboardType,
        int? maxLength,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
      ),
    );
  }

  Future<void> _saveAddress() async {
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

    _nameController.clear();
    _addressController.clear();
    _cityController.clear();
    _stateController.clear();
    _zipController.clear();
    _countryController.clear();
    _landmarkController.clear();
    _phoneController.clear();

    Navigator.pop(context);
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
                Text("Select Address:",
                    style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _addNewAddress,
                  child: Text("+ Add New",
                      style: GoogleFonts.lora(color: Color(0xFFEBB21D), fontSize: 16)),
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
                        title: Text(address['name'],
                            style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
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
                      style: GoogleFonts.lora(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
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