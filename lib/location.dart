import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DraggableContainerExample extends StatefulWidget {
  @override
  _DraggableContainerExampleState createState() =>
      _DraggableContainerExampleState();
}

class _DraggableContainerExampleState extends State<DraggableContainerExample> {
  double _containerHeight = 300;
  double _maxHeight = 600;
  double _minHeight = 150;
  User? _currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _saveLocation({String? docId}) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please log in first.")));
      return;
    }

    String name = _nameController.text;
    String address = _addressController.text;
    String city = _cityController.text;
    String state = _stateController.text;
    String zip = _zipController.text;
    String country = _countryController.text;
    String landmark = _landmarkController.text;
    String phone = _phoneController.text;

    if (name.isEmpty || address.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all required fields.")));
      return;
    }

    try {
      if (docId == null) {
        await FirebaseFirestore.instance.collection('locations').add({
          'userId': _currentUser!.uid, // Store user ID
          'name': name,
          'address': address,
          'city': city,
          'state': state,
          'zip': zip,
          'country': country,
          'landmark': landmark,
          'phone': phone,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance.collection('locations').doc(docId).update({
          'name': name,
          'address': address,
          'city': city,
          'state': state,
          'zip': zip,
          'country': country,
          'landmark': landmark,
          'phone': phone,
        });
      }
      _clearFields();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Location saved successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to save location: $e")));
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  docId == null ? "Add New Location" : "Edit Location",
                  style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold),
                ),
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
                  onPressed: () {
                    _saveLocation(docId: docId);
                    Navigator.pop(context);
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

  Stream<QuerySnapshot> _getUserLocations() {
    if (_currentUser == null) {
      return Stream<QuerySnapshot>.empty();
    }

    return FirebaseFirestore.instance
        .collection('locations')
        .where('userId', isEqualTo: _currentUser!.uid) // Show only current user's locations
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Locations", style: GoogleFonts.lora(color: Colors.white)),
        backgroundColor: Color(0xFF380230),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLocationBottomSheet(),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFFEBB21D),
      ),
      body: Stack(
        children: [
          Container(
            color: Color(0xFF380230),
            child: Center(
              child: Text("Background Content", style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
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
                child: _currentUser == null
                    ? Center(child: Text("Please log in to view locations."))
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
                                      docId: location.id, location: location.data() as Map<String, dynamic>),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => FirebaseFirestore.instance.collection('locations').doc(location.id).delete(),
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
    );
  }
}