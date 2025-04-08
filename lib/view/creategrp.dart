import 'package:dupepro/controller/session.dart';
import 'package:dupepro/view/selectArtists.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dupepro/model/artist_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();

  List<Artist> _selectedArtists = [];
  List<String> artistNames = [];
  List<String> artistEmails = [];
  List<File> _selectedImages = []; // List to store selected images
  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSelectedArtists();

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _fetchSelectedArtists() async {
    try {
      Map<String, String?> sessionData = await Session.getSession();
      _currentUserId = sessionData['uid'];

      if (_currentUserId == null) return;

      // Fetch selected artist IDs from artistSelections
      DocumentSnapshot selectionDoc = await FirebaseFirestore.instance
          .collection('artistSelections')
          .doc(_currentUserId)
          .get();

      if (!selectionDoc.exists) return;

      List<String> selectedArtistIds =
          List<String>.from(selectionDoc['selectedArtists'] ?? []);

      List<Artist> artists = [];
      List<String> names = [];
      List<String> emails = [];

      for (String artistId in selectedArtistIds) {
        // Fetch artist details from "artists" collection
        DocumentSnapshot artistDoc = await FirebaseFirestore.instance
            .collection('artists')
            .doc(artistId)
            .get();
        if (!artistDoc.exists) continue;

        Artist artist = Artist.fromDocument(artistDoc);

        // Fetch user details from "users" collection for name & email
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(artistId)
            .get();
        String name = userDoc.exists ? userDoc['name'] ?? 'Unknown' : 'Unknown';
        String email =
            userDoc.exists ? userDoc['email'] ?? 'No Email' : 'No Email';

        // Store artist & user details
        artists.add(artist);
        names.add(name);
        emails.add(email);
      }

      // Update UI
      setState(() {
        _selectedArtists = artists;
        artistNames = names;
        artistEmails = emails;
      });
    } catch (e) {
      print("Error fetching selected artists: $e");
    }
  }

  // Method to pick multiple images
  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  /*Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      String groupId = FirebaseFirestore.instance.collection('groups').doc().id;

      // Upload images and get URLs
      List<String> imageUrls = await _uploadImages(groupId);

      // Create a list of member UIDs from selected artists
      List<String> memberUids =
          _selectedArtists.map((artist) => artist.uid).toList();

      // Create the group with image URLs and members list
      await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
        'groupId': groupId,
        'groupName': _groupNameController.text,
        'groupDescription': _groupDescriptionController.text,
        'images': imageUrls, // Add image URLs here
        'members': memberUids,
        'createdAt': Timestamp.now(),
      });

      // Prepare artist request list
      List<Map<String, dynamic>> artistRequests =
          _selectedArtists.asMap().entries.map((entry) {
        int index = entry.key;
        Artist artist = entry.value;
        return {
          'index': index,
          'artistUid': artist.uid,
          'artistName': artistNames[index],
          'status': 'pending',
          'sentAt': Timestamp.now(),
        };
      }).toList();

      // Store all requests under a single document
      await FirebaseFirestore.instance.collection('requests').doc(groupId).set({
        'groupId': groupId,
        'groupName': _groupNameController.text,
        'artists': artistRequests,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group created and requests sent!')),
      );

      _groupNameController.clear();
      _groupDescriptionController.clear();
      setState(() {
        _selectedArtists.clear();
        _selectedImages.clear();
      });
    }
  }*/

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, String?> sessionData = await Session.getSession();
        String? adminId = sessionData['uid'];
        if (adminId == null) return;

        String groupId =
            FirebaseFirestore.instance.collection('groups').doc().id;

        // Upload images and get URLs
        List<String> imageUrls = await _uploadImages(groupId);

        // Create the group with admin ID (NO MEMBERS YET)
        await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
          'groupId': groupId,
          'groupName': _groupNameController.text,
          'groupDescription': _groupDescriptionController.text,
          'images': imageUrls,
          'admin': adminId, // Set current user as admin
          'createdAt': Timestamp.now(),
        });

        // Prepare artist request list (for invitations)
        List<Map<String, dynamic>> artistRequests =
            _selectedArtists.asMap().entries.map((entry) {
          int index = entry.key;
          Artist artist = entry.value;
          return {
            'index': index,
            'artistUid': artist.uid,
            'artistName': artistNames[index],
            'status': 'pending', // They need to accept first
            'sentAt': Timestamp.now(),
          };
        }).toList();

        // Store all requests under a single document
        await FirebaseFirestore.instance
            .collection('requests')
            .doc(groupId)
            .set({
          'groupId': groupId,
          'groupName': _groupNameController.text,
          'admin': adminId,
          'artists': artistRequests,
        });

        // 🔥 Delete artist documents where admin == current userId
        QuerySnapshot artistDocs = await FirebaseFirestore.instance
            .collection('artistSelections')
            .where('adminId', isEqualTo: adminId)
            .get();

        for (var doc in artistDocs.docs) {
          print('Doc: ..................... $doc');
          await doc.reference.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group created! Invitations sent.')),
        );

        // Clear inputs & selections
        _groupNameController.clear();
        _groupDescriptionController.clear();
        setState(() {
          _selectedArtists.clear();
          _selectedImages.clear();
        });
      } catch (e) {
        print("Error creating group: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group.')),
        );
      }
    }
  }

  // Method to upload images to Firebase Storage
  Future<List<String>> _uploadImages(String groupId) async {
    List<String> imageUrls = [];
    final FirebaseStorage _storage = FirebaseStorage.instance;

    for (var image in _selectedImages) {
      String fileName =
          'groups/$groupId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);
      await storageRef.putFile(image);
      String downloadUrl = await storageRef.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Group',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white), // AppBar back icon white
        backgroundColor: Color(0xFF380230),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Add Artist Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectArtistsPage(),
                      ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A0D54),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Add Artist', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 16),

              // 2. Artist List
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _selectedArtists.isEmpty
                  ? Center(
                  child: Text('No artists added yet',
                      style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _selectedArtists.length,
                itemBuilder: (context, index) {
                  final artist = _selectedArtists[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(
                        artistNames[index],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Type: ${artist.artistType}"),
                          Text("Bio: ${artist.bio}"),
                          Text("Email: ${artistEmails[index]}"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle,
                            color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedArtists.removeAt(index);
                            artistNames.removeAt(index);
                            artistEmails.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),

              // 3. Image Picker Section
              _buildImageSection(),
              SizedBox(height: 24),

              // 4. Group Name
              TextFormField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Enter a group name' : null,
              ),
              SizedBox(height: 16),

              // 5. Group Description
              TextFormField(
                controller: _groupDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Group Description',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Enter a group description' : null,
              ),
              SizedBox(height: 24),

              // 6. Create Group Button
              ElevatedButton(
                onPressed: _createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A0D54),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Create Group', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF380230), Color(0xFF6A0D54)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            if (_selectedImages.isEmpty)
              Icon(Icons.add_a_photo, size: 40, color: Colors.white),
            if (_selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  );
                },
              ),
            if (_selectedImages.isNotEmpty) SizedBox(height: 8),
            if (_selectedImages.isNotEmpty)
              Text(
                'Tap to add more images',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
