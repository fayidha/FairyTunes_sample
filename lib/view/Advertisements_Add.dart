import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAdvertisementPage extends StatefulWidget {
  final String? productId;

  const AddAdvertisementPage({Key? key, this.productId}) : super(key: key);

  @override
  _AddAdvertisementPageState createState() => _AddAdvertisementPageState();
}

class _AddAdvertisementPageState extends State<AddAdvertisementPage> {
  List<File> _images = [];
  List<File> _videos = [];
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _pickVideos() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videos.add(File(pickedFile.path));
      });
    }
  }
  void _removeFile(List<File> files, int index) {
    setState(() {
      files.removeAt(index);
    });
  }

  Future<List<String>> _uploadFiles(List<File> files, String folder) async {
    List<String> urls = [];
    for (File file in files) {
      try {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        Reference ref = _storage.ref().child('$folder/$fileName');
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String url = await snapshot.ref.getDownloadURL();
        urls.add(url);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e")),
        );
      }
    }
    return urls;
  }

  Future<void> _submitAd() async {
    if (_images.isEmpty && _videos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select images or videos to upload")),
      );
      return;
    }
    String? productId=widget.productId;
    List<String> imageUrls = await _uploadFiles(_images, "advertisements/images");
    List<String> videoUrls = await _uploadFiles(_videos, "advertisements/videos");

    await _firestore.collection('products').doc(productId).update({
      'advertisementImageUrls': imageUrls,
      'advertisementVideoUrls': videoUrls,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Advertisement Posted Successfully!")),
    );

    setState(() {
      _images.clear();
      _videos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Advertisement", style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF380230), Color(0xFF6A0572)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildUploadSection("Upload Images", _images, _pickImages),
              SizedBox(height: 20),
              _buildUploadSection("Upload Videos", _videos, _pickVideos),
              SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: _submitAd,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF380230), Color(0xFF6A0572)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "Post Advertisement",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection(String label, List<File> files, VoidCallback pickFunction) {
    return Column(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.purple, width: 2),
            gradient: LinearGradient(
              colors: [Color(0xFF380230), Color(0xFF6A0572)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: files.isEmpty
                ? Text(label, style: TextStyle(color: Colors.white, fontSize: 16))
                : Wrap(
              spacing: 10,
              children: files.asMap().entries.map((entry) => Stack(
                alignment: Alignment.topRight,
                children: [
                  entry.value.path.endsWith("mp4")

                      ? Icon(Icons.video_collection, size: 50, color: Colors.red)
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(entry.value, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.white),
                    onPressed: () => _removeFile(files, entry.key),
                  ),
                ],
              )).toList(),
            ),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: pickFunction,
          icon: Icon(Icons.upload, color: Colors.white),
          label: Text("Upload", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}
