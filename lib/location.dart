import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraggableContainerExample extends StatefulWidget {
  @override
  _DraggableContainerExampleState createState() => _DraggableContainerExampleState();
}

class _DraggableContainerExampleState extends State<DraggableContainerExample> {
  double _containerHeight = 300;
  double _maxHeight = 600;
  double _minHeight = 150;

  String? _userId;
  bool _isLoadingUserId = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('uid');
      _isLoadingUserId = false;
    });
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter valid email address';
    }
    return null;
  }

  void _saveLocation({String? docId}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please log in first.")));
      return;
    }

    try {
      if (docId == null) {
        await FirebaseFirestore.instance.collection('locations').add({
          'userId': _userId,
          'name': _nameController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'zip': _zipController.text,
          'country': _countryController.text,
          'landmark': _landmarkController.text,
          'phone': _phoneController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance.collection('locations').doc(docId).update({
          'name': _nameController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'zip': _zipController.text,
          'country': _countryController.text,
          'landmark': _landmarkController.text,
          'phone': _phoneController.text,
        });
      }

      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location saved successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save location: $e")));
    }
  }

  void _clearFields() {
    _nameController.clear();
    _addressController.clear();
    _cityController.clear();
    _stateController.clear();
    _zipController.clear();
    _countryController.clear();
    _landmarkController.clear();
    _phoneController.clear();
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType? keyboardType,
        String? Function(String?)? validator,
        int? maxLength,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: keyboardType,
        validator: validator,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
      ),
    );
  }

  void _showAddLocationBottomSheet({String? docId, Map<String, dynamic>? location}) {
    if (location != null) {
      _nameController.text = location['name'];
      _addressController.text = location['address'];
      _cityController.text = location['city'];
      _stateController.text = location['state'];
      _zipController.text = location['zip'];
      _countryController.text = location['country'];
      _landmarkController.text = location['landmark'];
      _phoneController.text = location['phone'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    docId == null ? "Add New Location" : "Edit Location",
                    style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(_nameController, "Full Name", validator: (value) => _validateRequired(value, "name")),
                  _buildTextField(_addressController, "Address", validator: (value) => _validateRequired(value, "address")),
                  _buildTextField(_cityController, "City", validator: (value) => _validateRequired(value, "city")),
                  _buildTextField(_stateController, "State", validator: (value) => _validateRequired(value, "state")),
                  _buildTextField(_zipController, "ZIP Code", validator: (value) => _validateRequired(value, "ZIP code")),
                  _buildTextField(_countryController, "Country", validator: (value) => _validateRequired(value, "country")),
                  _buildTextField(_landmarkController, "Landmark (optional)"),
                  _buildTextField(
                    _phoneController,
                    "Phone Number",
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
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
                        _saveLocation(docId: docId);
                        Navigator.pop(context);
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
                        "Save Location",
                        style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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

  Stream<QuerySnapshot> _getUserLocations() {
    if (_isLoadingUserId || _userId == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('locations')
        .where('userId', isEqualTo: _userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Manage Locations",
          style: GoogleFonts.lora(color: Color(0xFF380230), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF380230)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLocationBottomSheet(),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFFEBB21D),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Please ensure your address is complete and accurate for smooth delivery.",
                        style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Standard delivery takes 3-5 business days.",
                        style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        _containerHeight -= details.delta.dy;
                        _containerHeight = _containerHeight.clamp(_minHeight, _maxHeight);
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      height: _containerHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -5))],
                      ),
                      child: _isLoadingUserId
                          ? Center(child: CircularProgressIndicator())
                          : StreamBuilder<QuerySnapshot>(
                        stream: _getUserLocations(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text("Error: ${snapshot.error}"));
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(child: Text("No locations added yet."));
                          }

                          var locations = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: locations.length,
                            itemBuilder: (context, index) {
                              var location = locations[index];
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: Icon(Icons.location_on, color: Colors.blueAccent),
                                  title: Text(location['name'], style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${location['address']}, ${location['city']}"),
                                      Text("${location['state']}, ${location['zip']}"),
                                      Text("${location['country']}"),
                                      if (location['landmark'] != null && location['landmark'].isNotEmpty)
                                        Text("Landmark: ${location['landmark']}"),
                                      Text("Phone: ${location['phone']}"),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.green),
                                        onPressed: () => _showAddLocationBottomSheet(
                                            docId: location.id,
                                            location: location.data() as Map<String, dynamic>),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => FirebaseFirestore.instance
                                            .collection('locations')
                                            .doc(location.id)
                                            .delete(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
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