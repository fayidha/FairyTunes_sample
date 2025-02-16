import 'package:dupepro/view/BandSuccess_message.dart';
import 'package:flutter/material.dart';
import 'package:dupepro/controller/artist_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/artist_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _groupNameController = TextEditingController();
  final _groupDescController = TextEditingController();
  final List<Artist> _members = [];
  final ArtistController _artistController = ArtistController();
  List<XFile>? _imageFiles = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    Artist currentUser = Artist(
      id: 'currentUserId',
      name: 'Admin (You)',
      artistType: 'Admin',
      bio: '',
      joinBands: true,
    );
    setState(() => _members.add(currentUser));
  }

  Future<List<Artist>> _fetchArtists() async {
    QuerySnapshot snapshot = await _artistController.artistsCollection.get();
    return snapshot.docs.map((doc) => Artist(
      id: doc.id,
      name: doc['name'],
      artistType: doc['artistType'],
      bio: doc['bio'],
      joinBands: doc['joinBands'],
    )).toList();
  }

  void _addOrRemoveMember(Artist artist) {
    setState(() {
      if (_members.any((member) => member.id == artist.id)) {
        _members.removeWhere((member) => member.id == artist.id);
      } else {
        _members.add(artist);
      }
    });
  }

  void _removeMember(int index) {
    setState(() => _members.removeAt(index));
  }

  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() => _imageFiles = images);
    }
  }

  Widget _buildArtistDropdown() {
    return FutureBuilder<List<Artist>>(
      future: _fetchArtists(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF380230),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _showArtistSelectionDialog(snapshot.data!),
              child: Text('Add Artists'),
            ),
          ],
        );
      },
    );
  }

  void _showArtistSelectionDialog(List<Artist> artists) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Artists"),
          content: SingleChildScrollView(
            child: ListBody(
              children: artists.map((artist) {
                bool isSelected = _members.any((member) => member.id == artist.id);
                return GestureDetector(
                  onTap: () => setState(() {
                    _addOrRemoveMember(artist);
                    Navigator.pop(context);
                    _showArtistSelectionDialog(artists);
                  }),
                  child: Card(
                    child: ListTile(
                      title: Text(artist.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(artist.artistType),
                          Text(artist.bio),
                          if (artist.joinBands)
                            Text("Available to join bands", style: TextStyle(color: Colors.green)),
                        ],
                      ),
                      trailing: Icon(
                        isSelected ? Icons.check_circle : Icons.add_circle,
                        color: isSelected ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [TextButton(child: Text('OK'), onPressed: () => Navigator.pop(context))],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF380230),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true, // Ensures the UI resizes when the keyboard opens
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAvatar(),
              SizedBox(height: 16),
              _buildTextField(_groupNameController, 'Group Name'),
              SizedBox(height: 16),
              _buildTextField(_groupDescController, 'Group Description'),
              SizedBox(height: 16),
              _buildArtistDropdown(),
              SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4, // Restrict height to avoid overflow
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(_members[index].name),
                        subtitle: Text(_members[index].artistType),
                        trailing: _members[index].name == 'Admin (You)'
                            ? null
                            : IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeMember(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        _imageFiles!.isEmpty
            ? CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.group, size: 60, color: Colors.white),
        )
            : Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _imageFiles!.map((file) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(file.path),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            );
          }).toList(),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: _pickImages,
            child: CircleAvatar(
              backgroundColor: Color(0xFF380230),
              radius: 24,
              child: Icon(Icons.add_a_photo, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
    ),
  );

  Widget _buildCreateButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF380230),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BandSuccess(),));
      },
      child: Text('Create Group', style: TextStyle(fontSize: 16)),
    );
  }
}
