import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dupepro/model/artist_model.dart';
import 'package:dupepro/controller/artist_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();
  final ArtistController _artistController = ArtistController();

  List<Artist> _selectedArtists = [];
  List<Artist> _allArtists = [];
  bool _isLoading = true;
  List<String> artistNames = [];
  List<String> artistEmails = [];
  List<File> _selectedImages = []; // List to store selected images

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

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      String groupId = FirebaseFirestore.instance.collection('groups').doc().id;

      // Upload images and get URLs
      List<String> imageUrls = await _uploadImages(groupId);

      // Create a list of member UIDs from selected artists
      List<String> memberUids = _selectedArtists.map((artist) => artist.uid).toList();

      // Create the group with image URLs and members list
      await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
        'groupId': groupId,
        'groupName': _groupNameController.text,
        'groupDescription': _groupDescriptionController.text,
        'images': imageUrls, // Add image URLs here
        'members': memberUids, // Add member UIDs here
        'createdAt': Timestamp.now(),
      });

      // Prepare artist request list
      List<Map<String, dynamic>> artistRequests = _selectedArtists.asMap().entries.map((entry) {
        int index = entry.key;
        Artist artist = entry.value;
        return {
          'index': index, // Numbering artists 0,1,2...
          'artistUid': artist.uid,
          'artistName': artistNames[index], // Use previously fetched names
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
  }

  // Method to upload images to Firebase Storage
  Future<List<String>> _uploadImages(String groupId) async {
    List<String> imageUrls = [];
    final FirebaseStorage _storage = FirebaseStorage.instance;

    for (var image in _selectedImages) {
      String fileName = 'groups/$groupId/${DateTime.now().millisecondsSinceEpoch}.jpg';
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
        title: Text('Create Group'),
        backgroundColor: Color(0xFF380230),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImageSection(), // Image section with image picker
              SizedBox(height: 24),

              // Group Name Field
              TextFormField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
                validator: (value) => value!.isEmpty ? 'Enter a group name' : null,
              ),
              SizedBox(height: 16),

              // Group Description Field
              TextFormField(
                controller: _groupDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Group Description',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
                validator: (value) => value!.isEmpty ? 'Enter a group description' : null,
              ),
              SizedBox(height: 16),

              // Add Artist Button
              ElevatedButton(
                onPressed: () {

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
              SizedBox(height: 24),

              // Selected Artists List
              Text('Selected Artists', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _selectedArtists.isEmpty
                  ? Center(child: Text('No artists added yet', style: TextStyle(color: Colors.grey)))
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
                      title: Text(artistNames[index], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Type: ${artist.artistType}"),
                          Text("Bio: ${artist.bio}"),
                          Text("Email: ${artistEmails[index]}"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {

                        },
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 24),

              // Create Group Button
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
                          onPressed: () {

                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            if (_selectedImages.isNotEmpty)
              SizedBox(height: 8),
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

/*
  @override
  void initState() {
    super.initState();
    _fetchAllArtists();
  }


  Future<void> _fetchAllArtists() async {
    List<Artist> artists = await _artistController.getAllArtists();

    List<String> names = [];
    List<String> emails = [];

    for (var artist in artists) {
      var userData = await Session.getUserDetailsByUid(artist.uid);
      if (userData != null) {
        names.add(userData['name']);
        emails.add(userData['email']);
      } else {
        names.add("Unknown Name");
        emails.add("N/A");
      }
    }

    setState(() {
      _allArtists = artists;
      artistNames = names;
      artistEmails = emails;
      _isLoading = false;
    });
  }



  void _addArtistToGroup(Artist artist) {
    if (!_selectedArtists.contains(artist)) {
      print("Artists: @@@@@@@@@@@@@ $artist");
      setState(() {
        _selectedArtists.add(artist);
      });
    }
  }

  void _removeArtistFromGroup(Artist artist) {
    setState(() {
      _selectedArtists.remove(artist);
    });
  }



  // Method to remove an image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }



 */


/*
  void _showArtistSelectionDialog() async {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Artists'),
          content: _isLoading
              ? Center(child: CircularProgressIndicator())
              : SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _allArtists.length,
              itemBuilder: (context, index) {
                final artist = _allArtists[index];
                return ListTile(
                  title: Text(artistNames[index]),
                  subtitle: Text(artistEmails[index]),
                  trailing: _selectedArtists.contains(artist)
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    _addArtistToGroup(artist);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }*/
}