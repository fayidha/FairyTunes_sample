import 'package:dupepro/view/groupProfile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No invitations available."));
          }

          // **Filter requests where the current user is invited**
          var userRequests = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>?;

            if (data == null ||
                !data.containsKey('artists') ||
                data['artists'] is! List) {
              return false; // Ignore if artists field is missing or invalid
            }

            var artists = data['artists'] as List<dynamic>;
            return artists.any((artist) =>
                artist is Map<String, dynamic> &&
                artist['artistUid'] == currentUser?.uid &&
                artist['status'] == 'pending');
          }).toList();

          if (userRequests.isEmpty) {
            return Center(child: Text("No invitations available."));
          }

          return ListView.builder(
            itemCount: userRequests.length,
            itemBuilder: (context, index) {
              var request = userRequests[index];
              var data = request.data() as Map<String, dynamic>?;

              if (data == null || !data.containsKey('artists')) {
                return SizedBox.shrink(); // Skip if data is missing
              }

              var groupId = data['groupId'] ?? "Unknown Group";
              var groupName = data['groupName'] ?? "Unnamed Group";

              // Find the current user's artist data
              var artistData = (data['artists'] as List).firstWhere(
                (artist) =>
                    artist is Map<String, dynamic> &&
                    artist['artistUid'] == currentUser?.uid,
                orElse: () => null,
              );

              if (artistData == null || artistData is! Map<String, dynamic>) {
                return SizedBox.shrink(); // Skip if no valid artist data
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupProfile(groupId: groupId),
                      ));
                },
                child: Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(groupName,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Status: ${artistData['status']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => _acceptRequest(groupId, request.id),
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _rejectRequest(groupId, request.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _acceptRequest(String groupId, String requestId) async {
    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([currentUser!.uid]),
    });

    await _updateRequestStatus(requestId, 'accepted');

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Joined the group!")));
  }

  Future<void> _rejectRequest(String groupId, String requestId) async {
    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([currentUser!.uid]),
    });

    await _updateRequestStatus(requestId, 'rejected');

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Request rejected.")));
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    DocumentReference requestRef =
        FirebaseFirestore.instance.collection('requests').doc(requestId);

    var requestData = await requestRef.get();
    if (requestData.exists) {
      Map<String, dynamic>? data = requestData.data() as Map<String, dynamic>?;

      if (data == null || !data.containsKey('artists')) return;

      List<dynamic> artists = data['artists'];
      for (var artist in artists) {
        if (artist is Map<String, dynamic> &&
            artist['artistUid'] == currentUser!.uid) {
          artist['status'] = status;
        }
      }
      await requestRef.update({'artists': artists});
    }
  }
}
