import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/Troup_model.dart';
import 'package:flutter/material.dart';

class TroupeController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  List<String> images = [];
  List<Map<String, String>> selectedArtists = [];

  Future<void> submitForm() async {
    if (formKey.currentState!.validate()) {
      final troupe = Troupe(
        id: FirebaseFirestore.instance.collection('troupes').doc().id,
        name: nameController.text,
        location: locationController.text,
        description: descriptionController.text,
        images: images,
        artists: selectedArtists,
        creator: 'admin (you)',
      );
      await FirebaseFirestore.instance.collection('troupes').doc(troupe.id).set(troupe.toMap());
    }
  }

  Future<void> sendRequestToArtists() async {
    for (var artist in selectedArtists) {
      await FirebaseFirestore.instance.collection('artist_requests').add({
        'artist': artist['name'],
        'type': artist['type'],
        'troupe': nameController.text,
      });
    }
  }

  Widget buildImageCarousel() {
    return Container(); // Implement image carousel UI
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? 'Required' : null,
    );
  }

  Widget buildArtistDropdownWithDialog() {
    return Container(); // Implement dropdown with artist list and selection
  }

  void removeArtist(Map<String, String> artist) {
    selectedArtists.remove(artist);
  }
}
