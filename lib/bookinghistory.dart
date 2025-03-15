import 'package:dupepro/view/Bookeddetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBookingsPage extends StatefulWidget {
  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  String? userId;
  bool isDialogShowing = false; // Prevent multiple pop-ups

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('uid');
    });
  }

  Future<void> _cancelBooking(String bookingId) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('bookings')
                    .doc(bookingId)
                    .update({'status': 'Cancelled'});
                Navigator.pop(context);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRating(String bookingId, double rating) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'rating': rating});
  }

  void _showRatingDialog(String bookingId) {
    if (isDialogShowing) return; // Prevent multiple popups
    isDialogShowing = true;

    double _selectedRating = 0; // Start with 0 stars

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Rate Your Experience'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Please rate the event experience:'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _selectedRating ? Icons.star : Icons.star_border, // Initially empty stars
                          color: Colors.amber,
                          size: 35,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            _selectedRating = (index + 1).toDouble(); // Update selected rating
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    isDialogShowing = false;
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (_selectedRating > 0) { // Ensure user selects at least 1 star
                      _submitRating(bookingId, _selectedRating);
                      isDialogShowing = false;
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => isDialogShowing = false); // Reset flag when dialog closes
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Bookings')),
      body: userId == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No bookings found.'));
          }

          return ListView(
            padding: EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String status = data['status'];

              // Show the rating dialog only once when status is "Event Happened" and no rating is given
              if (status == 'Event Happened' && data['rating'] == null) {
                Future.delayed(Duration.zero, () {
                  _showRatingDialog(doc.id);
                });
              }

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('${data['groupName']} - ${data['eventLocation']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${data['programDate']}'),
                      Text('Time: ${data['programTime']}'),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetailsPage(
                          bookingData: data,
                          bookingId: doc.id,
                          onCancel: _cancelBooking,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Booked':
        return Colors.green;
      case 'Confirmed':
        return Colors.blue;
      case 'Event Happened':
        return Colors.green;
      case 'Cancelled':
      case 'Denied':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
