import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdvertisementsAdd extends StatefulWidget {
  @override
  _AdvertisementsAddState createState() => _AdvertisementsAddState();
}

class _AdvertisementsAddState extends State<AdvertisementsAdd> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  List<File> _selectedVideos = [];
  bool _isUploading = false;

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _pickVideos() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideos.add(File(video.path));
      });
    }
  }

  void _removeFile(File file) {
    setState(() {
      _selectedImages.remove(file);
      _selectedVideos.remove(file);
    });
  }

  Future<void> _uploadAdvertisements() async {
    if (_selectedImages.isEmpty && _selectedVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select images or videos to upload.")),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      List<String> imageUrls = [];
      List<String> videoUrls = [];

      // Upload Images
      for (File image in _selectedImages) {
        String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
        UploadTask uploadTask = storage.ref(fileName).putFile(image);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // Upload Videos
      for (File video in _selectedVideos) {
        String fileName = 'videos/${DateTime.now().millisecondsSinceEpoch}.mp4';
        UploadTask uploadTask = storage.ref(fileName).putFile(video);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        videoUrls.add(downloadUrl);
      }

      // Save to Firestore
      await firestore.collection('advertisements').add({
        'images': imageUrls,
        'videos': videoUrls,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Advertisements uploaded successfully!")),
      );

      // Clear selected files after upload
      setState(() {
        _selectedImages.clear();
        _selectedVideos.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A0D54), Color(0xFF380230)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button with Title
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Add Advertisements",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Main Content (Scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "Upload Advertisements",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6A0D54)),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Selected Files Grid
                          if (_selectedImages.isNotEmpty || _selectedVideos.isNotEmpty)
                            _buildSelectedFilesGrid(),

                          SizedBox(height: 20),

                          // Buttons for Image & Video Selection with Proper Spacing
                          Row(
                            children: [
                              Expanded(child: _buildGradientButton("Pick Images", Icons.image, _pickImages)),
                              SizedBox(width: 16),
                              Expanded(child: _buildGradientButton("Pick Videos", Icons.video_library, _pickVideos)),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Upload Advertisement Button (Full Width)
                          _isUploading
                              ? Center(child: CircularProgressIndicator())
                              : _buildWideGradientButton("Upload Advertisements", Icons.cloud_upload, _uploadAdvertisements),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFilesGrid() {
    List<File> allFiles = [..._selectedImages, ..._selectedVideos];

    return SizedBox(
      height: 220,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(vertical: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 12,
        ),
        itemCount: allFiles.length,
        itemBuilder: (context, index) {
          File file = allFiles[index];
          bool isVideo = _selectedVideos.contains(file);

          return Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isVideo
                    ? Container(
                  width: 140,
                  color: Colors.black,
                  child: Center(
                    child: Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
                  ),
                )
                    : Image.file(file, width: 140, height: 140, fit: BoxFit.cover),
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.redAccent),
                onPressed: () => _removeFile(file),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Standard Gradient Button
Widget _buildGradientButton(String text, IconData icon, VoidCallback onPressed) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF6A0D54), Color(0xFF380230)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: TextStyle(fontSize: 16, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        backgroundColor: Colors.transparent, // Transparent to show gradient
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

// Wide Gradient Button (for Upload)
Widget _buildWideGradientButton(String text, IconData icon, VoidCallback onPressed) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF6A0D54), Color(0xFF380230)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: TextStyle(fontSize: 16, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

