import 'package:dupepro/controller/artist_controller.dart';
import 'package:dupepro/model/artist_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtistProfile extends StatefulWidget {
  @override
  _ArtistProfileState createState() => _ArtistProfileState();
}

class _ArtistProfileState extends State<ArtistProfile> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? artistType;
  String? bio;
  bool joinBands = false;

  final ArtistController _controller = ArtistController();

  void _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      String artistId = FirebaseFirestore.instance.collection('artists').doc().id;
      Artist artist = Artist(
        id: artistId,
        name: name!,
        artistType: artistType!,
        bio: bio!,
        joinBands: joinBands,
      );
      await _controller.addArtist(artist);
      _showSubmissionDialog();
    }
  }

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

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Enter your name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onChanged: (value) => name = value,
              ),
              SizedBox(height: 20),
              Text('What type of artist are you?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                items: ['Singer', 'Instrumentalist', 'Composer', 'DJ', 'Other']
                    .map((label) => DropdownMenuItem(child: Text(label), value: label))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    artistType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your artist type';
                  }
                  return null;
                },
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Select your artist type'),
              ),
              if (artistType == 'Other') ...[
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Please specify'),
                  onChanged: (value) => {},
                ),
              ],
              SizedBox(height: 20),
              Text('Tell us about yourself', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Enter your bio here...'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bio';
                  }
                  return null;
                },
                onChanged: (value) => bio = value,
              ),
              SizedBox(height: 20),
              Text('Are you open to joining bands?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SwitchListTile(
                title: Text(joinBands ? 'Yes, I want to join bands' : 'No, I don’t want to join bands'),
                value: joinBands,
                onChanged: (value) {
                  setState(() {
                    joinBands = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitProfile,
                  child: Text('Submit Profile', style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Color(0xFF380230),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
