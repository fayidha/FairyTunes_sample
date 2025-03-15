import 'package:dupepro/view/TroupManageBookings.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GroupProfile extends StatefulWidget {
  final String groupId;

  const GroupProfile({Key? key, required this.groupId}) : super(key: key);

  @override
  State<GroupProfile> createState() => _GroupProfileState();
}

class _GroupProfileState extends State<GroupProfile> {
  Map<String, dynamic>? groupData;
  Map<String, Map<String, dynamic>> membersData = {};
  Map<String, dynamic>? adminData;
  bool isLoading = true;



  @override
  void initState() {
    super.initState();
    _fetchGroupDetails();
  }

  Future<void> _fetchGroupDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (doc.exists) {
        groupData = doc.data() as Map<String, dynamic>;
        await _fetchAdminAndMembersData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group not found')),
        );
      }
    } catch (e) {
      print("Error fetching group: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load group data')),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchAdminAndMembersData() async {
    String? adminId = groupData?['admin'];
    List<dynamic> memberIds = groupData?['members'] ?? [];

    if (adminId != null) {
      adminData = await _fetchUserData(adminId);
    }

    for (String memberId in memberIds) {
      membersData[memberId] = await _fetchUserData(memberId);
    }
  }

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    Map<String, dynamic> userData = {};

    try {
      // Fetch user details
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>;
      }

      // Fetch artist type
      DocumentSnapshot artistDoc = await FirebaseFirestore.instance
          .collection('artists')
          .doc(userId)
          .get();

      if (artistDoc.exists) {
        userData['artistType'] = artistDoc['artistType'] ?? 'Unknown';
      } else {
        userData['artistType'] = 'Not an artist';
      }
    } catch (e) {
      print("Error fetching user data for $userId: $e");
    }

    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Group Profile")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : groupData == null
          ? Center(child: Text("No group data available"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              groupData!['groupName'] ?? 'No Name',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              groupData!['groupDescription'] ?? 'No Description',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Created At: ${groupData!['createdAt'] != null ? DateFormat('yyyy-MM-dd – kk:mm').format(groupData!['createdAt'].toDate()) : 'Unknown'}",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text("Admin:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            adminData != null
                ? ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text(adminData!['name'] ?? 'Unknown Admin'),
              subtitle: Text(adminData!['email'] ?? 'No email'),
              trailing: Text(adminData!['artistType'] ?? 'Unknown'),
            )
                : Text("Admin not found"),
            SizedBox(height: 16),
            Text("Members:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            membersData.isNotEmpty
                ? Column(
              children: membersData.entries.map((entry) {
                String memberId = entry.key;
                Map<String, dynamic> member = entry.value;
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(member['name'] ?? 'Unknown Member'),
                  subtitle: Text(member['email'] ?? 'No email'),
                  trailing: Text(member['artistType'] ?? 'Unknown'),
                );
              }).toList(),
            )
                : Text("No members yet."),
            SizedBox(height: 16),
            Text("Images:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            if (groupData!['images'] != null &&
                groupData!['images'].isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: groupData!['images'].map<Widget>((imgUrl) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(imgUrl,
                          height: 100, width: 100, fit: BoxFit.cover),
                    );
                  }).toList(),
                ),
              )
            else
              Text("No images available."),
            SizedBox(height: 24),
            // View Bookings Button
            ElevatedButton(
              onPressed: () {
                if (groupData != null && groupData!['admin'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TroupManageBooking(
                        groupId: widget.groupId,
                        // Correctly passing admin ID
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Admin ID not available')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF380230),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 5,
              ),
              child: Text(
                "View Bookings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

          ],
        ),
      ),
    );
  }
}