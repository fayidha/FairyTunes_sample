import 'package:flutter/material.dart';
import 'package:dupepro/controller/artist_controller.dart';
import 'package:dupepro/model/artist_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtistProfile extends StatefulWidget {
  final String uid;

  const ArtistProfile({Key? key, required this.uid}) : super(key: key);

  @override
  _ArtistProfileState createState() => _ArtistProfileState();
}

class _ArtistProfileState extends State<ArtistProfile> {
  final _formKey = GlobalKey<FormState>();

  String? artistType;
  String? bio;
  bool joinBands = false;
  String? otherArtistType;
  bool isSubmitting = false;
  String? userName;
  String? userEmail;
  String? artistId;

  final ArtistController _controller = ArtistController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _otherArtistTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchArtistDetails();
  }

  // Fetch artist details directly using UID
  Future<void> _fetchArtistDetails() async {
    try {
      DocumentSnapshot artistDoc = await FirebaseFirestore.instance
          .collection('artists')
          .doc(widget.uid) // Fetch directly using user ID
          .get();

      if (artistDoc.exists && artistDoc.data() != null) {
        setState(() {
          artistType = artistDoc['artistType'];
          bio = artistDoc['bio'];
          joinBands = artistDoc['joinBands'] ?? false;

          _bioController.text = bio ?? "";
          if (artistType == 'Other') {
            _otherArtistTypeController.text = artistDoc['otherArtistType'] ?? "";
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Artist details not found!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching artist details: $e")),
      );
    }
  }
  // Fetch user details from Firestore using UID
  Future<void> _fetchUserDetails() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? "No Name";
          userEmail = userDoc['email'] ?? "No Email";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User details not found in Firestore!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user details: $e")),
      );
    }
  }

  // Submit the profile to Firestore
  void _submitProfile() async {
    if (_formKey.currentState!.validate() && !isSubmitting) {
      setState(() => isSubmitting = true);

      String finalArtistType =
          artistType == 'Other' ? (otherArtistType ?? '') : artistType!;

      Artist artist = Artist(
        uid: widget.uid,
        id: widget.uid,
        artistType: finalArtistType,
        bio: bio!,
        joinBands: joinBands,
      );

      await _controller.addArtist(artist);
      _showSubmissionDialog();

      setState(() => isSubmitting = false);
    }
  }

  // Show confirmation dialog after submission
  void _showSubmissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile Submitted'),
          content: Text('Your artist profile has been successfully submitted!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Navigate back after submitting
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  userName != null && userEmail != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'If you are an artist! This is the golden chance for you to join a band...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 30),
                            _buildTextField('Username', userName!,
                                (value) => userName = value),
                            SizedBox(height: 20),
                            _buildTextField('Email', userEmail!,
                                (value) => userEmail = value),
                          ],
                        )
                      : Center(child: CircularProgressIndicator()),
                  SizedBox(height: 20),
                  Text('What type of artist are you?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    items: [
                      'Singer',
                      'Instrumentalist',
                      'Composer',
                      'DJ',
                      'Other'
                    ]
                        .map((label) =>
                            DropdownMenuItem(child: Text(label), value: label))
                        .toList(),
                    value: artistType,
                    onChanged: (value) => setState(() => artistType = value),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select your artist type'
                        : null,
                    decoration: _inputDecoration(),
                  ),
                  if (artistType == 'Other') ...[
                    SizedBox(height: 10),
                    _buildTextField('Specify Other', '',
                        (value) => otherArtistType = value),
                  ],
                  SizedBox(height: 20),
                  Text('Tell us about yourself',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextFormField(
                    maxLines: 5,
                    decoration: _inputDecoration(),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your bio'
                        : null,
                    onChanged: (value) => bio = value,
                  ),
                  SizedBox(height: 20),
                  Text('Are you open to joining bands?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SwitchListTile(
                    title: Text(joinBands
                        ? 'Yes, I want to join bands'
                        : 'No, I don’t want to join bands'),
                    value: joinBands,
                    onChanged: (value) => setState(() => joinBands = value),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submitProfile,
                      child: Text('Submit',
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF380230),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable TextField Builder
  Widget _buildTextField(
      String label, String initialValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextFormField(
          initialValue: initialValue,
          decoration: _inputDecoration(),
          validator: (value) =>
              value!.isEmpty ? 'Please enter your $label' : null,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Common Input Decoration
  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      filled: true,
      fillColor: Colors.grey[200],
    );
  }
}
