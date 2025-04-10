import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/SuccessScreen.dart';
import 'package:dupepro/Teacher_dash.dart';
import 'package:dupepro/controller/session.dart';
import 'package:dupepro/controller/teacher_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherAdd extends StatefulWidget {
  const TeacherAdd({super.key});

  @override
  State<TeacherAdd> createState() => _TeacherAddState();
}

class _TeacherAddState extends State<TeacherAdd> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> selectedNotes = [];
  final List<TextEditingController> descriptionControllers = [];

  XFile? _image;
  bool _isEditing = false;

  // ✅ TextEditingControllers for all fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _profileImage = ""; // This will hold the image URL
  bool _isLoading = false;

  final TeacherController _teacherController = TeacherController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetch user details from Firebase Authentication & Firestore
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

        print("User Data from Firestore: $data");

        if (data != null) {
          setState(() {
            _nameController.text = data['name'] ?? "Unknown User";
            _emailController.text = data['email'] ?? "unknown@gmail.com";
            _profileImage = data['userProfile'] ?? "";
          });

          print("Fetched Name: ${_nameController.text}");
          print("Fetched Email: ${_emailController.text}");
          print("Fetched Profile Image: $_profileImage");
        } else {
          print("Error: No user data found in Firestore");
        }
      } else {
        print("Error: No user document found in Firestore");
      }
    } else {
      print("Error: No user signed in");
    }
  }

  /// Pick an image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  /// Upload image to Firebase Storage and return the URL
  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      String fileName =
          'teachers/${FirebaseAuth.instance.currentUser!.uid}.png';
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref()
          .child(fileName)
          .putFile(File(_image!.path));
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  /// Save teacher details to Firestore
  Future<void> _saveTeacher() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Retrieve session details to get UID
        Map<String, String?> session = await Session.getSession();
        String? uid = session['uid'];

        if (uid == null) {
          throw Exception("User ID is null");
        }

        String? imageUrl = await _uploadImage(); // Upload image and get URL

        // Use the fetched image URL from the users collection if no new image is selected
        String finalImageUrl = imageUrl ?? _profileImage;

        String? errorMessage = await _teacherController.registerTeacher(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          category: _categoryController.text,
          qualification: _qualificationController.text,
          experience: _experienceController.text,
          address: _addressController.text,
          imageUrl: finalImageUrl, // Use the fetched image URL if no new image is selected
        );

        if (errorMessage == null) {
          // Update the 'users' collection to mark the user as a teacher
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'isTeacher': true,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Teacher registered successfully!")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SuccessScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $errorMessage")),
          );
        }
      } catch (e) {
        print("Error saving teacher: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          if (file.size < 5000000) {
            selectedNotes.add({"file": file, "description": ""});
            descriptionControllers.add(TextEditingController());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(
                  "File '${file.name}' exceeds 5MB limit and was not added.")),
            );
          }
        }
      });
    }
  }

  Future<void> uploadNotes() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    for (int i = 0; i < selectedNotes.length; i++) {
      File file = File(selectedNotes[i]['file'].path!);
      String fileName = selectedNotes[i]['file'].name;
      String noteId = FirebaseFirestore.instance
          .collection("notes")
          .doc()
          .id;

      TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('notes/${user.uid}/$fileName')
          .putFile(file);
      String fileUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("notes").doc(noteId).set({
        "noteId": noteId,
        "teacherId": user.uid,
        "noteName": fileName,
        "fileUrl": fileUrl,
        "description": descriptionControllers[i].text,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("${selectedNotes.length} PDFs uploaded successfully")),
    );
    setState(() {
      selectedNotes.clear();
      descriptionControllers.clear();
    });
  }

  void viewPDF(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PDFViewer(filePath: filePath)),
    );
  }

  Future<void> editDescription(String noteId, String newDescription) async {
    await FirebaseFirestore.instance.collection("notes").doc(noteId).update({
      "description": newDescription,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Description updated successfully")),
    );
  }

  Future<void> deleteNote(String noteId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text("Delete Note"),
            content: Text("Are you sure you want to delete this note?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    ) ?? false;

    if (confirmDelete) {
      await FirebaseFirestore.instance.collection("notes").doc(noteId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Note deleted successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Registration",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF380230),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("teachers")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> data = snapshot.data!.data() as Map<
                String,
                dynamic>;
            return _isEditing
                ? _buildRegistrationForm(data)
                : _buildProfileCard(data);
          } else {
            // User is not registered - show registration form
            return _buildRegistrationForm(null);
          }
        },
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> data) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 70),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF380230), Color(0xFF6A0D54)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome Music Teacher", style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
                SizedBox(height: 2),
                Text("Manage your notes and chats",
                    style: TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Spacing between header and profile card

          // Profile Card
          Container(
            width: 360,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF380230), Colors.blueGrey.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage.isNotEmpty
                      ? NetworkImage(
                      _profileImage) // Display the fetched profile image
                      : const AssetImage(
                      'asset/210379377.png') as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(data['name'] ?? "Unknown User",
                    style: const TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 5),
                Text(data['email'] ?? "unknown@gmail.com",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 5),
                Text("Phone: ${data['phone'] ?? "N/A"}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 5),
                Text("Category: ${data['category'] ?? "N/A"}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 5),
                Text("Qualification: ${data['qualification'] ?? "N/A"}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 5),
                Text("Experience: ${data['experience'] ?? "N/A"}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 5),
                Text("Address: ${data['address'] ?? "N/A"}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  child: const Text("Edit Profile"),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Spacing between profile card and notes section

          // Upload Notes Section
          _buildUploadNotesSection(),
          SizedBox(height: 20),
          // Spacing between upload and view notes sections

          // View Notes Section
          _buildViewNotesSection(),
        ],
      ),
    );
  }

  Widget _buildUploadNotesSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: pickFiles,
            icon: Icon(Icons.upload_file, color: Colors.white),
            label: Text(
                "Select PDF Notes", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF380230)),
          ),
          Column(
            children: List.generate(selectedNotes.length, (index) {
              return Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () =>
                        viewPDF(selectedNotes[index]['file'].path!),
                    icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: Text(
                        "View PDF", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF380230)),
                  ),
                  TextField(
                    controller: descriptionControllers[index],
                    decoration: InputDecoration(labelText: "Description"),
                  ),
                  SizedBox(height: 8),
                ],
              );
            }),
          ),
          if (selectedNotes.isNotEmpty)
            ElevatedButton(
              onPressed: uploadNotes,
              child: Text("Upload Notes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF380230),
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

// View Notes Section
  Widget _buildViewNotesSection() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Center(child: Text("Please log in"));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("notes")
          .where("teacherId", isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        final notes = snapshot.data!.docs;

        if (notes.isEmpty) {
          return Center(child: Text("No notes uploaded yet."));
        }

        return Column(
          children: notes.map((note) {
            TextEditingController editController = TextEditingController(
                text: note['description']);
            bool isEditing = false;

            return StatefulBuilder(
              builder: (context, setState) {
                return Card(
                  child: ListTile(
                    title: Text(note['noteName']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isEditing) Text(note['description']),
                        if (isEditing)
                          TextField(
                            controller: editController,
                            decoration: InputDecoration(
                                labelText: "Edit Description"),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEditing)
                          IconButton(
                            icon: Icon(Icons.save),
                            onPressed: () async {
                              await editDescription(
                                  note.id, editController.text);
                              setState(() {
                                isEditing = false;
                              });
                            },
                          ),
                        if (!isEditing)
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                isEditing = true;
                              });
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          onPressed: () => launch(note['fileUrl']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteNote(note.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRegistrationForm(Map<String, dynamic>? data) {
    if (data != null) {
      _nameController.text = data['name'] ?? "";
      _emailController.text = data['email'] ?? "";
      _phoneController.text = data['phone'] ?? "";
      _categoryController.text = data['category'] ?? "";
      _qualificationController.text = data['qualification'] ?? "";
      _experienceController.text = data['experience'] ?? "";
      _addressController.text = data['address'] ?? "";
      _profileImage = data['imageUrl'] ?? "";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _image != null
                    ? FileImage(File(_image!.path))
                    : _profileImage.isNotEmpty
                    ? NetworkImage(_profileImage)
                    : const AssetImage('asset/210379377.png') as ImageProvider,
                child: _image == null && _profileImage.isEmpty
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : null,
              ),
            ),

            const SizedBox(height: 20),
            _buildTextField("Teacher Name", _nameController),
            _buildTextField("Email", _emailController,
                keyboardType: TextInputType.emailAddress),
            _buildTextField("Phone Number", _phoneController,
                keyboardType: TextInputType.phone),
            _buildTextField("Category", _categoryController),
            _buildTextField("Qualification", _qualificationController),
            _buildTextField("Experience", _experienceController),
            _buildTextField("Address", _addressController),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF380230),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _saveTeacher,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a text input field
  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      controller: controller,
      validator: (value) {
        if (value == null || value
            .trim()
            .isEmpty) {
          return "Please enter a $label";
        }

        if (label.toLowerCase().contains("email")) {
          // Email validation using RegExp
          final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
          if (!emailRegex.hasMatch(value.trim())) {
            return "Please enter a valid email address";
          }
        }

        if (label.toLowerCase().contains("phone")) {
          // Basic phone number validation: must be digits and 10 characters long
          final phoneRegex = RegExp(r"^[0-9]{10}$");
          if (!phoneRegex.hasMatch(value.trim())) {
            return "Please enter a valid 10-digit phone number";
          }
        }

        return null;
      },
    );
  }
}