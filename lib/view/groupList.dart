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
      // Get the current user ID
      Map<String, String?> sessionData = await Session.getSession();
      userId = sessionData['uid'];

      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      // Query Firestore for groups where the user is admin OR in the members list
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where(
        Filter.or(
          Filter('admin', isEqualTo: userId),
          Filter('members', arrayContains: userId),
        ),
      )
          .get();

      // Convert to a list of maps
      setState(() {
        groups = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching groups: $e");
      setState(() => isLoading = false);
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
          return ListTile(
            leading: group['images'] != null && group['images'].isNotEmpty
                ? CircleAvatar(
              backgroundImage: NetworkImage(group['images'][0]),
            )
                : CircleAvatar(child: Icon(Icons.group)),
            title: Text(group['groupName'] ?? 'Unnamed Group'),
            subtitle: Text(group['groupDescription'] ?? 'No description'),
            onTap: () {
              // Navigate to Group Profile (Assuming you have a GroupProfile screen)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupProfile(
                groupId: group['groupId'],
              ),
                )
              );
            },
          );
        },
      ),
    );
  }
}
