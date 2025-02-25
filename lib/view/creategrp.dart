import 'package:dupepro/controller/session.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/artist_model.dart';
import 'package:dupepro/controller/artist_controller.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchAllArtists();
  }

  Future<void> _fetchAllArtists() async {
    List<Artist> artists = await _artistController.getAllArtists();
    setState(() {
      _allArtists = artists;
      _isLoading = false;
    });
  }

  void _addArtistToGroup(Artist artist) {
    if (!_selectedArtists.contains(artist)) {
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

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      String groupId = FirebaseFirestore.instance.collection('groups').doc().id;

      // Create the group with an empty members list
      await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
        'groupId': groupId,
        'groupName': _groupNameController.text,
        'groupDescription': _groupDescriptionController.text,
        'members': [], // Members will be added here when they accept
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Group Image Placeholder
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/default_group_image.png'),
              ),
              SizedBox(height: 16),

              // Group Name Field
              TextFormField(
                controller: _groupNameController,
                decoration: InputDecoration(labelText: 'Group Name'),
                validator: (value) => value!.isEmpty ? 'Enter a group name' : null,
              ),
              SizedBox(height: 16),

              // Group Description Field
              TextFormField(
                controller: _groupDescriptionController,
                decoration: InputDecoration(labelText: 'Group Description'),
                validator: (value) => value!.isEmpty ? 'Enter a group description' : null,
              ),
              SizedBox(height: 16),

              // Add Artist Button
              ElevatedButton(
                onPressed: _showArtistSelectionDialog,
                child: Text('Add Artist'),
              ),
              SizedBox(height: 16),

              // Selected Artists List
              Expanded(
                child: _selectedArtists.isEmpty
                    ? Center(child: Text('No artists added yet'))
                    : ListView.builder(
                  itemCount: _selectedArtists.length,
                  itemBuilder: (context, index) {
                    final artist = _selectedArtists[index];
                    return Card(
                      child: ListTile(
                        title: Text(artistNames[index]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          //  Text("Artist ID: ${artist.id}"),
                            Text("Type: ${artist.artistType}"),
                            Text("Bio: ${artist.bio}"),
                            Text("Email: ${artistEmails[index]}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeArtistFromGroup(artist),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Create Group Button
              ElevatedButton(
                onPressed: _createGroup,
                child: Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showArtistSelectionDialog() async {


    // Fetch user details for all artists before showing the dialog
    for (var artist in _allArtists) {
      var userData = await Session.getUserDetailsByUid(artist.uid);
      if (userData != null) {
        artistNames.add(userData['name']);
        artistEmails.add(userData['email']);
      } else {
        artistNames.add("Unknown Name");
        artistEmails.add("N/A");
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Artists'),
          content: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _allArtists.length,
              itemBuilder: (context, index) {
                final artist = _allArtists[index];

                return ListTile(
                  title: Text(artistNames[index]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Type: ${artist.artistType}"),
                      Text("Bio: ${artist.bio}"),
                      Text("Email: ${artistEmails[index]}"),
                    ],
                  ),
                  trailing: _selectedArtists.contains(artist)
                      ? const Icon(Icons.check_circle, color: Colors.green)
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
  }




}
