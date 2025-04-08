import 'package:dupepro/controller/session.dart';
import 'package:dupepro/view/groupProfile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupList extends StatefulWidget {
  const GroupList({Key? key}) : super(key: key);

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  String? userId;
  bool isLoading = true;
  List<Map<String, dynamic>> groups = [];

  @override
  void initState() {
    super.initState();
    _fetchUserGroups();
  }

  Future<void> _fetchUserGroups() async {
    try {
      Map<String, String?> sessionData = await Session.getSession();
      userId = sessionData['uid'];

      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where(
        Filter.or(
          Filter('admin', isEqualTo: userId),
          Filter('members', arrayContains: userId),
        ),
      )
          .get();

      setState(() {
        groups = querySnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['groupId'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching groups: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _cancelGroup(String groupId) async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Confirm Cancellation"),
          content: Text("Are you sure you want to cancel this group?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Yes"),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Delete the group from Firestore
      await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();

      // Refresh the group list
      _fetchUserGroups();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Group cancelled successfully")),
      );
    } catch (e) {
      print("Error cancelling group: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel group")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Groups")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : groups.isEmpty
          ? Center(child: Text("No groups found"))
          : ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          var group = groups[index];
          bool isAdmin = group['admin'] == userId;

          return ListTile(
            leading: group['images'] != null && group['images'].isNotEmpty
                ? CircleAvatar(
              backgroundImage: NetworkImage(group['images'][0]),
            )
                : CircleAvatar(child: Icon(Icons.group)),
            title: Text(group['groupName'] ?? 'Unnamed Group'),
            subtitle: Text(group['groupDescription'] ?? 'No description'),
            trailing: isAdmin
                ? PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'cancel') {
                  _cancelGroup(group['groupId']);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'cancel',
                    child: Text("Cancel Group"),
                  ),
                ];
              },
            )
                : null, // No menu for non-admin groups
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupProfile(
                    groupId: group['groupId'],
                    currentUserId: userId!,
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