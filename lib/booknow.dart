import 'package:dupepro/booksuccess.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BookNow extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? location; // Optional location from the troupe

  BookNow({required this.groupId, required this.groupName, this.location});

  @override
  _BookNowState createState() => _BookNowState();
}

class _BookNowState extends State<BookNow> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _programDateController = TextEditingController();
  final _programTimeController = TextEditingController();
  final _eventLocationController = TextEditingController();

  String? _userName;
  String? _userEmail;
  bool _isLoading = true;
  String? _selectedEventType; // New variable to store the selected event type

  // List of event types for the dropdown
  final List<String> _eventTypes = [
    'Wedding',
    'College Events',
    'Hostel Events',
    'School Events',
    'Anniversary',
    'Birthday',
    'Bachelor Party',
    'Residents Events',
    'Film Shows',
    'Club Events',
    'Seasonal Party',
    'New Year Party',
    'Onam Celebration',
    'Christmas',
    'Eid',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    if (widget.location != null) {
      _eventLocationController.text = widget.location!;
    }
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userUid = prefs.getString('uid');

    if (userUid != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userUid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name'] ?? 'Unknown';
            _userEmail = userDoc['email'] ?? 'Unknown';
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _programDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _programTimeController.text = picked.format(context);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userUid = prefs.getString('uid'); // Get logged-in user ID

      if (userUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in!')),
        );
        return;
      }

      // Prepare booking data
      Map<String, dynamic> bookingData = {
        'userId': userUid,
        'userName': _userName,
        'userEmail': _userEmail,
        'phone': _phoneController.text.trim(),
        'groupId': widget.groupId,
        'groupName': widget.groupName,
        'programDate': _programDateController.text,
        'programTime': _programTimeController.text,
        'eventLocation': _eventLocationController.text,
        'eventType': _selectedEventType, // Add selected event type
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Booked'
      };

      try {
        await FirebaseFirestore.instance.collection('bookings').add(bookingData);

        // Navigate to Success Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Success(
              groupId: widget.groupId,
              groupName: widget.groupName,
            ),
          ),
        );

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('')),
        // );
      } catch (e) {
        print("Error saving booking: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error booking. Please try again!')),
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _programDateController.dispose();
    _programTimeController.dispose();
    _eventLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Book Now', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'asset/img1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(13.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: _userName,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          prefixIcon: Icon(Icons.person),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _userEmail,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          prefixIcon: Icon(Icons.email),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length < 10) {
                            return 'Phone number must be at least 10 digits long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _programDateController,
                            decoration: InputDecoration(
                              labelText: 'Program Date',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                              prefixIcon: Icon(Icons.date_range),
                            ),
                            validator: (value) => value!.isEmpty ? 'Please enter the program date' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _programTimeController,
                            decoration: InputDecoration(
                              labelText: 'Program Time',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            validator: (value) => value!.isEmpty ? 'Please enter the program time' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _eventLocationController,
                        decoration: InputDecoration(
                          labelText: 'Event Location',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter the event location' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedEventType,
                        decoration: InputDecoration(
                          labelText: 'Event Type',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          prefixIcon: Icon(Icons.event),
                        ),
                        items: _eventTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedEventType = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Please select an event type' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.purple.shade900; // Darker color when pressed
                              } else if (states.contains(MaterialState.hovered)) {
                                return Colors.purple.shade700; // Lighter shade on hover
                              }
                              return Color(0xFF380230); // Default color
                            },
                          ),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                        child: Text(
                          'Book',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}