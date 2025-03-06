import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageRequestsPage extends StatefulWidget {
  @override
  _ManageRequestsPageState createState() => _ManageRequestsPageState();
}

class _ManageRequestsPageState extends State<ManageRequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid;
  }

  Future<void> _updateRequestStatus(String groupId, String artistUid, String status) async {
    try {
      DocumentReference requestRef = _firestore.collection('requests').doc(groupId);
      DocumentSnapshot requestSnapshot = await requestRef.get();
      if (!requestSnapshot.exists) return;

      List<dynamic> artists = requestSnapshot['artists'];
      for (var artist in artists) {
        if (artist['artistUid'] == artistUid) {
          artist['status'] = status;
        }
      }

      await requestRef.update({'artists': artists});

      if (status == 'accepted') {
        // Add artist to the group members list
        DocumentReference groupRef = _firestore.collection('groups').doc(groupId);
        await groupRef.update({
          'members': FieldValue.arrayUnion([artistUid])
        });

        // Update artist's collection status
        await _firestore.collection('artists').doc(artistUid).update({
          'status': 'joined'
        });
      } else {
        // Remove artist from the group's request list
        await requestRef.update({
          'artists': artists.where((artist) => artist['artistUid'] != artistUid).toList()
        });
      }
    } catch (e) {
      print("Error updating request status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Requests'),
        backgroundColor: Color(0xFF380230),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('requests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var requests = snapshot.data!.docs.where((doc) {
            var artists = doc['artists'] as List<dynamic>;
            return artists.any((artist) => artist['artistUid'] == userId && artist['status'] == 'pending');
          }).toList();

          if (requests.isEmpty) {
            return Center(child: Text('No pending requests'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              var groupId = request['groupId'];
              var groupName = request['groupName'];
              var artistData = (request['artists'] as List<dynamic>).firstWhere((artist) => artist['artistUid'] == userId);

              return Card(
                elevation: 4,
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Group: $groupName', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Status: ${artistData['status']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _updateRequestStatus(groupId, userId!, 'accepted'),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _updateRequestStatus(groupId, userId!, 'rejected'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
