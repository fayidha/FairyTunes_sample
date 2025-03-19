import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/booknow.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TroupDetail extends StatefulWidget {
  final String groupId;

  TroupDetail({required this.groupId});

  @override
  _TroupDetailState createState() => _TroupDetailState();
}

class _TroupDetailState extends State<TroupDetail> {
  Map<String, dynamic>? groupData;
  Map<String, dynamic>? adminData;
  List<String> memberNames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroupData();
  }

  Future<void> _fetchGroupData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (snapshot.exists) {
        groupData = snapshot.data() as Map<String, dynamic>;

        if (groupData?['admin'] != null) {
          adminData = await _fetchUserData(groupData!['admin']);
        }

        if (groupData?['members'] != null) {
          await _fetchMemberNames(groupData!['members']);
        }

        setState(() => isLoading = false);
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching group details: $e");
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return {};
  }

  Future<void> _fetchMemberNames(List<dynamic> memberIds) async {
    try {
      List<String> names = [];
      for (String id in memberIds) {
        Map<String, dynamic> userData = await _fetchUserData(id);
        if (userData.isNotEmpty) {
          names.add(userData['name'] ?? "Unknown");
        }
      }
      setState(() => memberNames = names);
    } catch (e) {
      print("Error fetching member names: $e");
    }
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Color(0xFF6A0D83)),
            SizedBox(width: 10),
            Expanded(
                child: Text(text,
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Members",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 5),
        if (memberNames.isEmpty)
          Text("No members available.", style: TextStyle(fontSize: 16, color: Colors.grey[700]))
        else
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: memberNames.map((name) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 20, color: Color(0xFF6A0D83)),
                        SizedBox(width: 8),
                        Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(groupData?['groupName'] ?? "Loading...",style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF380230), Color(0xFF6A0D83)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : groupData == null
          ? Center(child: Text("Troupe not found", style: TextStyle(fontSize: 18)))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (groupData!['images'] != null && groupData!['images'].isNotEmpty)
                CarouselSlider(
                  items: groupData!['images'].map<Widget>((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
                    );
                  }).toList(),
                  options: CarouselOptions(height: 220, autoPlay: true),
                ),
              SizedBox(height: 10),
              Text(groupData!['groupName'] ?? "Troupe", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              RatingBarIndicator(
                rating: groupData?['rating']?.toDouble() ?? 4.0,
                itemBuilder: (context, index) => Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 24.0,
              ),
              SizedBox(height: 10),
              _buildInfoCard(Icons.person, "Admin: ${adminData?['name'] ?? 'Unknown'}"),
              _buildInfoCard(Icons.date_range, "Created: ${groupData!['createdAt'] != null ? DateFormat('dd MMM yyyy').format(groupData!['createdAt'].toDate()) : 'N/A'}"),
              SizedBox(height: 10),
              _buildMembersList(),
              SizedBox(height: 20),
              Text("About Us", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(groupData!['groupDescription'] ?? "No description available."),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    backgroundColor: Color(0xFF6A0D83),
                  ),
                  onPressed: () {
                    if (groupData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookNow(
                            groupId: widget.groupId,
                            groupName: groupData!['groupName'] ?? "Unknown Group",
                            location: groupData!['location'] ?? "",
                          ),
                        ),
                      );
                    }
                  },


                  child: Text("Book Now", style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
