import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController _streetController = TextEditingController();
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
    String street = _streetController.text;
    String city = _cityController.text;
    String state = _stateController.text;
    String zip = _zipController.text;
    String country = _countryController.text;
    String landmark = _landmarkController.text;
    String phone = _phoneController.text;

    if (name.isNotEmpty && street.isNotEmpty && city.isNotEmpty) {
      if (docId == null) {
        await FirebaseFirestore.instance.collection('locations').add({
          'userId': _currentUser!.uid, // Store user ID
          'name': name,
          'street': street,
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
          'street': street,
          'city': city,
          'state': state,
          'zip': zip,
          'country': country,
          'landmark': landmark,
          'phone': phone,
        });
      }
      _clearFields();
    }
  }

  void _clearFields() {
    _nameController.clear();
    _streetController.clear();
    _cityController.clear();
    _stateController.clear();
    _zipController.clear();
    _countryController.clear();
    _landmarkController.clear();
    _phoneController.clear();
  }

  void _showAddLocationDialog({String? docId, Map<String, dynamic>? location}) {
    if (location != null) {
      _nameController.text = location['name'];
      _streetController.text = location['street'];
      _cityController.text = location['city'];
      _stateController.text = location['state'];
      _zipController.text = location['zip'];
      _countryController.text = location['country'];
      _landmarkController.text = location['landmark'];
      _phoneController.text = location['phone'];
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? "Add New Location" : "Edit Location"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name")),
                TextField(controller: _streetController, decoration: InputDecoration(labelText: "Street")),
                TextField(controller: _cityController, decoration: InputDecoration(labelText: "City")),
                TextField(controller: _stateController, decoration: InputDecoration(labelText: "State")),
                TextField(controller: _zipController, decoration: InputDecoration(labelText: "ZIP Code")),
                TextField(controller: _countryController, decoration: InputDecoration(labelText: "Country")),
                TextField(controller: _landmarkController, decoration: InputDecoration(labelText: "Landmark")),
                TextField(controller: _phoneController, decoration: InputDecoration(labelText: "Phone")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                _saveLocation(docId: docId);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
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
      appBar: AppBar(title: Text("Manage Locations")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLocationDialog(),
        child: Icon(Icons.add),
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
                            title: Text(location['name']),
                            subtitle: Text("${location['street']}, ${location['city']}, ${location['state']}, ${location['zip']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.green),
                                  onPressed: () => _showAddLocationDialog(
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
