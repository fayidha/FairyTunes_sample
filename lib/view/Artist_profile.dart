import 'package:dupepro/controller/session.dart';
import 'package:dupepro/view/login.dart';
import 'package:flutter/material.dart';
import 'package:dupepro/controller/artist_controller.dart';
import 'package:dupepro/model/artist_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtistProfile extends StatefulWidget {
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

  final ArtistController _controller = ArtistController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch user details from Session
  Future<void> _fetchUserDetails() async {
    try {
      Map<String, String?> sessionData = await Session.getSession();
      setState(() {
        userEmail = sessionData['email']; // Get email from session
        String? userUUID = sessionData['uid']; // Get UUID from session
        userName = sessionData['name']; // Assuming name is stored in session
        if (userUUID != null) {
          _fetchUserFromFirestore(userUUID); // Fetch user details from Firestore using UUID
        }
      });
    } catch (e) {
      print("Error fetching user details from session: $e");
    }
  }

  // Fetch user details from Firestore using the user's UUID
  Future<void> _fetchUserFromFirestore(String uuid) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uuid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var userData = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          userName = userData['name']; // Get the name from Firestore
        });
      } else {
        print("No user found with this UUID.");
      }
    } catch (e) {
      print("Error fetching user from Firestore: $e");
    }
  }

  // Submit the profile to Firestore
  void _submitProfile() async {
    if (_formKey.currentState!.validate() && !isSubmitting) {
      setState(() {
        isSubmitting = true; // Disable the button while submitting
      });

      artistType = artistType == 'Other' ? otherArtistType : artistType;
      String artistId = FirebaseFirestore.instance.collection('artists').doc().id;

      Artist artist = Artist(
        uid: _auth.currentUser!.uid,
        id: artistId,
        artistType: artistType!,
        bio: bio!,
        joinBands: joinBands,
      );

      await _controller.addArtist(artist);
      _showSubmissionDialog();

      setState(() {
        isSubmitting = false; // Re-enable the button after submission
      });
    }
  }

  // Show dialog after submission
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

  // Skip profile setup
  void _skipProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginForm()), // Navigate back to login or any other route
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(); // Fetch user details from session when the widget is initialized
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
                  // Display the username and email inside FormFields
                  userName != null && userEmail != null
                      ? Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Updated heading with customized font style and effect
                        Text(
                          'If you are an artist! This is the golden chance for you to join a band...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            letterSpacing: 2.0,
                            fontStyle: FontStyle.italic,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Username:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextFormField(
                          initialValue: userName, // Set the fetched username
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                            hintText: 'Enter your username',
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                          onChanged: (value) => userName = value, // Update userName on change
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Email:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextFormField(
                          initialValue: userEmail, // Set the fetched email
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                            hintText: 'Enter your email',
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          onChanged: (value) => userEmail = value, // Update userEmail on change
                        ),
                      ],
                    ),
                  )
                      : CircularProgressIndicator(), // Show loading indicator while fetching data
                  SizedBox(height: 20),
                  Text('What type of artist are you?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    items: ['Singer', 'Instrumentalist', 'Composer', 'DJ', 'Other']
                        .map((label) => DropdownMenuItem(child: Text(label), value: label))
                        .toList(),
                    value: artistType, // Pre-select the fetched artistType
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      hintText: 'Select your artist type',
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  if (artistType == 'Other') ...[
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        hintText: 'Please specify',
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      onChanged: (value) {
                        setState(() {
                          otherArtistType = value; // Save the input from the "Other" field
                        });
                      },
                    ),
                  ],
                  SizedBox(height: 20),
                  Text('Tell us about yourself', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextFormField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      hintText: 'Enter your bio here...',
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
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
                      onPressed: isSubmitting ? null : _submitProfile, // Disable if submitting
                      child: Text('Submit', style: TextStyle(fontSize: 14, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        backgroundColor: Color(0xFF380230),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  SizedBox(height: 80), // Added some space for the skip button
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _skipProfile,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
