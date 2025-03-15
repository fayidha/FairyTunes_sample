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
  String? adminId; // Store group admin ID
  String? currentUserId; // Store logged-in user ID

  @override
  void initState() {
    super.initState();
    _fetchAdminId(); // Fetch adminId when screen loads
    _fetchCurrentUser(); // Get currently logged-in user
  }

  Future<void> _fetchAdminId() async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (groupSnapshot.exists) {
        setState(() {
          adminId = groupSnapshot['admin']; // Ensure correct field name
        });
        print("Fetched Group Admin ID: $adminId");
      } else {
        print("Group document does not exist!");
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
          ? Center(child: CircularProgressIndicator()) // Show loader until data is fetched
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
                        'Status: ${data['status']}',
                        style: TextStyle(
                          color: data['status'] == 'Booked'
                              ? Colors.green
                              : (data['status'] == 'Confirmed' ? Colors.blue : Colors.red),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: currentUserId == adminId && data['status'] == 'Booked'
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _updateBookingStatus(doc.id, 'Confirmed'),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _updateBookingStatus(doc.id, 'Denied'),
                      ),
                    ],
                  )
                      : null, // Only show buttons if user is the admin
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
