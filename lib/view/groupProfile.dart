import 'package:dupepro/view/TroupManageBookings.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GroupProfile extends StatefulWidget {
  final String groupId;
  final String currentUserId;

  const GroupProfile({
    Key? key,
    required this.groupId,
    required this.currentUserId,
  }) : super(key: key);

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

    membersData = {}; // Clear existing data before fetching
    for (String memberId in memberIds) {
      if (memberId != adminId) { // Don't fetch admin as member
        membersData[memberId] = await _fetchUserData(memberId);
      }
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

  Future<void> _changeAdmin(String newAdminId) async {
    if (groupData == null || groupData!['admin'] == null) return;

    final String currentAdminId = groupData!['admin'];
    final List<dynamic> members = groupData!['members'] ?? [];

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'admin': newAdminId,
        'members': FieldValue.arrayUnion([currentAdminId]),
      });

      // Refresh the data
      await _fetchGroupDetails();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin changed successfully')),
      );
    } catch (e) {
      print("Error changing admin: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change admin')),
      );
    }
  }

  Future<void> _removeMember(String memberId) async {
    if (groupData == null || groupData!['admin'] == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'members': FieldValue.arrayRemove([memberId]),
      });

      // Refresh the data
      await _fetchGroupDetails();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member removed successfully')),
      );
    } catch (e) {
      print("Error removing member: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove member')),
      );
    }
  }

  Future<void> _leaveGroup() async {
    if (groupData == null) return;

    bool isAdmin = adminData != null && adminData!['uid'] == widget.currentUserId;

    if (isAdmin) {
      // Admin wants to leave - need to assign new admin first
      if (membersData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot leave as last member. Delete group instead.')),
        );
        return;
      }

      // Show dialog to select new admin
      await _showSelectNewAdminDialog();
    } else {
      // Regular member can just leave
      await _confirmLeaveGroup();
    }
  }

  Future<void> _confirmLeaveGroup() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Leave Group"),
          content: Text("Are you sure you want to leave this group?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Leave"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .update({
          'members': FieldValue.arrayRemove([widget.currentUserId]),
        });

        // Close the group profile page after leaving
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have left the group')),
        );
      } catch (e) {
        print("Error leaving group: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave group')),
        );
      }
    }
  }

  Future<void> _showSelectNewAdminDialog() async {
    String? selectedMemberId = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? tempSelectedId;

        return AlertDialog(
          title: Text("Select New Admin"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: membersData.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.value['name'] ?? 'Unknown Member'),
                  value: entry.key,
                  groupValue: tempSelectedId,
                  onChanged: (String? value) {
                    tempSelectedId = value;
                    Navigator.pop(context, value);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );

    if (selectedMemberId != null) {
      // First change admin, then leave
      await _changeAdmin(selectedMemberId!);
      await _confirmLeaveGroup();
    }
  }

  void _showChangeAdminDialog(String memberId, String memberName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Admin"),
          content: Text("Are you sure you want to make $memberName the new admin?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _changeAdmin(memberId);
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveMemberDialog(String memberId, String memberName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove Member"),
          content: Text("Are you sure you want to remove $memberName from the group?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _removeMember(memberId);
              },
              child: Text("Remove"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentUserAdmin = adminData != null &&
        adminData!['uid'] == widget.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text("Group Profile"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'leave_group') {
                _leaveGroup();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'leave_group',
                child: Text('Leave Group'),
              ),
            ],
          ),
        ],
      ),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(member['artistType'] ?? 'Unknown'),
                      if (isCurrentUserAdmin)
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'change_admin') {
                              _showChangeAdminDialog(
                                  memberId,
                                  member['name'] ?? 'this member'
                              );
                            } else if (value == 'remove_member') {
                              _showRemoveMemberDialog(
                                  memberId,
                                  member['name'] ?? 'this member'
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'change_admin',
                              child: Text('Make Admin'),
                            ),
                            PopupMenuItem<String>(
                              value: 'remove_member',
                              child: Text('Remove Member'),
                            ),
                          ],
                        ),
                    ],
                  ),
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