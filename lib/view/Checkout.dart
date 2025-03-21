// import 'package:dupepro/view/payment.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class CheckoutPage extends StatefulWidget {
//   final double totalAmount;
//
//   const CheckoutPage({required this.totalAmount});
//
//   @override
//   _CheckoutPageState createState() => _CheckoutPageState();
// }
//
// class _CheckoutPageState extends State<CheckoutPage> {
//   User? _currentUser = FirebaseAuth.instance.currentUser;
//   String? selectedAddressId;
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _zipController = TextEditingController();
//   final TextEditingController _countryController = TextEditingController();
//   final TextEditingController _landmarkController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//
//   Stream<QuerySnapshot> _getUserAddresses() {
//     return FirebaseFirestore.instance
//         .collection('locations')
//         .where('userId', isEqualTo: _currentUser!.uid)
//         .snapshots();
//   }
//
//   void _confirmOrder() {
//     if (selectedAddressId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please select an address")),
//       );
//       return;
//     }
//
//     // Fetch the selected address details
//     FirebaseFirestore.instance
//         .collection('locations')
//         .doc(selectedAddressId)
//         .get()
//         .then((doc) {
//       if (doc.exists) {
//         Map<String, String> shippingAddress = {
//           'name': doc['name'],
//           'address': doc['address'],
//           'city': doc['city'],
//           'state': doc['state'],
//           'zip': doc['zip'],
//           'country': doc['country'],
//           'landmark': doc['landmark'] ?? '',
//           'phone': doc['phone'],
//           'amount': widget.totalAmount.toString(),
//           'email': _currentUser!.email ?? '',
//         };
//
//         // Navigate to the PaymentScreen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => PaymentScreen(shippingAddress: shippingAddress),
//           ),
//         );
//       }
//     });
//   }
//
//   void _addNewAddress() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return SingleChildScrollView(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: Container(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Add New Address", style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 16),
//                 _buildTextField(_nameController, "Full Name"),
//                 _buildTextField(_addressController, "Address"),
//                 _buildTextField(_cityController, "City"),
//                 _buildTextField(_stateController, "State"),
//                 _buildTextField(_zipController, "ZIP Code"),
//                 _buildTextField(_countryController, "Country"),
//                 _buildTextField(_landmarkController, "Landmark (optional)"),
//                 _buildTextField(_phoneController, "Phone Number"),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _saveAddress,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFFEBB21D),
//                     padding: EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       "Save Address",
//                       style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _saveAddress() async {
//     if (_nameController.text.isEmpty ||
//         _addressController.text.isEmpty ||
//         _cityController.text.isEmpty ||
//         _stateController.text.isEmpty ||
//         _zipController.text.isEmpty ||
//         _countryController.text.isEmpty ||
//         _phoneController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please fill all required fields")),
//       );
//       return;
//     }
//
//     await FirebaseFirestore.instance.collection('locations').add({
//       'userId': _currentUser!.uid,
//       'name': _nameController.text,
//       'address': _addressController.text,
//       'city': _cityController.text,
//       'state': _stateController.text,
//       'zip': _zipController.text,
//       'country': _countryController.text,
//       'landmark': _landmarkController.text,
//       'phone': _phoneController.text,
//     });
//
//     // Clear controllers
//     _nameController.clear();
//     _addressController.clear();
//     _cityController.clear();
//     _stateController.clear();
//     _zipController.clear();
//     _countryController.clear();
//     _landmarkController.clear();
//     _phoneController.clear();
//
//     Navigator.pop(context); // Close the bottom sheet
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Checkout", style: GoogleFonts.lora(color: Colors.white)),
//         backgroundColor: Color(0xFF380230),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Select Address:", style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold)),
//                 TextButton(
//                   onPressed: _addNewAddress,
//                   child: Text("+ Add New", style: GoogleFonts.lora(color: Color(0xFFEBB21D), fontSize: 16)),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _getUserAddresses(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(child: Text("No saved addresses. Add one first."));
//                 }
//
//                 var addresses = snapshot.data!.docs;
//                 return ListView.builder(
//                   itemCount: addresses.length,
//                   itemBuilder: (context, index) {
//                     var address = addresses[index];
//                     return Card(
//                       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       elevation: 2,
//                       child: RadioListTile(
//                         title: Text(address['name'], style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("${address['address']}, ${address['city']}"),
//                             Text("${address['state']}, ${address['zip']}"),
//                             Text("${address['country']}"),
//                             if (address['landmark'] != null && address['landmark'].isNotEmpty)
//                               Text("Landmark: ${address['landmark']}"),
//                             Text("Phone: ${address['phone']}"),
//                           ],
//                         ),
//                         value: address.id,
//                         groupValue: selectedAddressId,
//                         onChanged: (value) {
//                           setState(() {
//                             selectedAddressId = value as String?;
//                           });
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Total: ₹${widget.totalAmount.toStringAsFixed(2)}",
//                     style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: _confirmOrder,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFFEBB21D),
//                     padding: EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       "Proceed to Payment",
//                       style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:dupepro/view/payment.dart';
import 'package:flutter/material.dart';
class ShippingAddress extends StatefulWidget {
  const ShippingAddress({super.key});
  @override
  State<ShippingAddress> createState() => _ShippingAddressState();
}
class _ShippingAddressState extends State<ShippingAddress> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();

    _countryController.dispose();
    _amountController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final address = _addressController.text;
      final city = _cityController.text;
      final state = _stateController.text;
      final zip = _zipController.text;
      final country = _countryController.text;
      final amount = _amountController.text;
      final email = _emailController.text;
      final phone = _phoneController.text;
      final shippingAddress = {
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'zip': zip,
        'country': country,
        'amount': amount,
        'email': email,
        'phone': phone,
      };
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(shippingAddress: shippingAddress),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shipping address saved successfully!')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping Address')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(

          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter your street address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'Enter your city',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State',
                  hintText: 'Enter your state',
                ),
                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return 'Please enter your state';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _zipController,
                decoration: const InputDecoration(
                  labelText: 'Zip Code',
                  hintText: 'Enter your zip code',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your zip code';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  hintText: 'Enter your country',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount in INR',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;

                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length != 10) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Address and Proceed to Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}