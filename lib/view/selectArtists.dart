import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/controller/session.dart';
import 'package:dupepro/view/creategrp.dart';
import 'package:flutter/material.dart';

class SelectArtistsPage extends StatefulWidget {
  SelectArtistsPage({Key? key}) : super(key: key);

  @override
  _SelectArtistsPageState createState() => _SelectArtistsPageState();
}

class _SelectArtistsPageState extends State<SelectArtistsPage> {
  List<Map<String, dynamic>> _allArtists = [];
  List<Map<String, dynamic>> _selectedArtists = [];
  bool _isLoading = true;
  String? _currentArtistId; // Store the current user's UID

  @override
  void initState() {
    super.initState();
    _fetchArtists();
  }

  Future<void> _fetchArtists() async {
    try {
      Map<String, String?> sessionData = await Session.getSession();
      String? currentArtistId = sessionData['uid'];

      if (currentArtistId == null) {
        print("No user session found.");
        setState(() => _isLoading = false);
        return;
      }

      setState(() => _currentArtistId = currentArtistId);

      QuerySnapshot artistSnapshot = await FirebaseFirestore.instance
          .collection('artists')
          .where('uid', isNotEqualTo: currentArtistId)
          .get();

      List<Map<String, dynamic>> artists = [];

      for (var artistDoc in artistSnapshot.docs) {
        String uid = artistDoc['uid'];

        // Fetch user details using uid
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          artists.add({
            'uid': uid,
            'name': userDoc['name'],
            'email': userDoc['email'],
            'artistType': artistDoc['artistType'],
            'bio': artistDoc['bio'],
          });
        }
      }

      setState(() {
        _allArtists = artists;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching artists: $e');
      setState(() => _isLoading = false);
    }
  }

  void _toggleSelection(Map<String, dynamic> artist) {
    setState(() {
      if (_selectedArtists.contains(artist)) {
        _selectedArtists.remove(artist);
      } else {
        _selectedArtists.add(artist);
      }
    });
  }

  Future<void> _saveSelection() async {
    if (_currentArtistId == null) return;

    try {
      // Prepare data for Firestore
      List<String> selectedArtistIds =
          _selectedArtists.map((artist) => artist['uid'] as String).toList();

      await FirebaseFirestore.instance
          .collection('artistSelections')
          .doc(_currentArtistId)
          .set({
        'adminId': _currentArtistId,
        // Current artist is the admin
        'selectedArtists': selectedArtistIds,
        'timestamp': FieldValue.serverTimestamp(),
        // Store when the selection was made
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Artists added')),
      );
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateGroupPage(),
          ));
    } catch (e) {
      print("Error saving artist selection: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Artists")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allArtists.length,
              itemBuilder: (context, index) {
                final artist = _allArtists[index];
                final isSelected = _selectedArtists.contains(artist);

                return ListTile(
                  title: Text(artist['name']),
                  subtitle: Text(artist['email']),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (value) => _toggleSelection(artist),
                  ),
                  onTap: () => _toggleSelection(artist),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveSelection,
        child: Icon(Icons.check),
      ),
    );
  }
}
