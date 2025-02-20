import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/artist_model.dart';

class ArtistController {
  final CollectionReference _artistCollection =
  FirebaseFirestore.instance.collection('artists');

  // **1️⃣ Add a New Artist Profile**
  Future<void> addArtist(Artist artist) async {
    try {
      await _artistCollection.doc(artist.id).set(artist.toJson());
      print("Artist profile added successfully!");
    } catch (e) {
      print("Error adding artist profile: $e");
    }
  }

  // **2️⃣ Get Artist Profile by User UID**
  Future<Artist?> getArtistByUid(String uid) async {
    try {
      QuerySnapshot snapshot =
      await _artistCollection.where('uid', isEqualTo: uid).limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        return Artist.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error fetching artist profile: $e");
      return null;
    }
  }

  // **3️⃣ Update Artist Profile**
  Future<void> updateArtist(String artistId, Map<String, dynamic> updatedData) async {
    try {
      await _artistCollection.doc(artistId).update(updatedData);
      print("Artist profile updated successfully!");
    } catch (e) {
      print("Error updating artist profile: $e");
    }
  }

  // **4️⃣ Delete Artist Profile**
  Future<void> deleteArtist(String artistId) async {
    try {
      await _artistCollection.doc(artistId).delete();
      print("Artist profile deleted successfully!");
    } catch (e) {
      print("Error deleting artist profile: $e");
    }
  }

  // ✅ **5. Get All Artists**
  Future<List<Artist>> getAllArtists() async {
    try {
      CollectionReference artistsRef = FirebaseFirestore.instance.collection('artists');
      QuerySnapshot snapshot = await artistsRef.get();

      if (snapshot.docs.isEmpty) {
        print("⚠️ No artists found.");
        return [];
      }

      return snapshot.docs.map((doc) => Artist.fromDocument(doc)).toList();
    } catch (e) {
      print("❌ Error fetching artists: $e");
      return [];
    }
  }


}
