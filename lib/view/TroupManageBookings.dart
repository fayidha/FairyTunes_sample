import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TroupManageBooking extends StatefulWidget {
  final String groupId;

  TroupManageBooking({required this.groupId});

  @override
  _TroupManageBookingState createState() => _TroupManageBookingState();
}

class _TroupManageBookingState extends State<TroupManageBooking> {
  String? adminId;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchAdminId();
    _fetchCurrentUser();
  }

  Future<void> _fetchAdminId() async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (groupSnapshot.exists) {
        setState(() {
          adminId = groupSnapshot['admin'];
        });
        print("Fetched Group Admin ID: $adminId");
      }
    } catch (e) {
      print("Error fetching admin ID: $e");
    }
  }

  void _fetchCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
      print("Current User ID: $currentUserId");
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    if (currentUserId == adminId) {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': newStatus,
      });
    } else {
      print("Unauthorized: Only the group admin can update bookings.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Troupe Bookings')),
      body: adminId == null || currentUserId == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('groupId', isEqualTo: widget.groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No bookings found for your troupe.'));
          }

          return ListView(
            padding: EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String status = data['status'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('${data['eventLocation']} - ${data['programDate']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Event Type: ${data['eventType']}'),
                      Text('Program Time: ${data['programTime']}'),
                      Text('User: ${data['userName']}'),
                      Text('Email: ${data['userEmail']}'),
                      Text('Phone: ${data['phone']}'),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: currentUserId == adminId
                      ? _buildAdminControls(doc.id, status)
                      : null,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildAdminControls(String bookingId, String status) {
    if (status == 'Booked') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.check_circle, color: Colors.blue),
            onPressed: () => _updateBookingStatus(bookingId, 'Confirmed'),
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: Colors.red),
            onPressed: () => _updateBookingStatus(bookingId, 'Denied'),
          ),
        ],
      );
    } else if (status == 'Confirmed') {
      return IconButton(
        icon: Icon(Icons.event_available, color: Colors.green),
        onPressed: () => _updateBookingStatus(bookingId, 'Event Happened'),
      );
    }
    return SizedBox(); // Empty space if no action is needed
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
