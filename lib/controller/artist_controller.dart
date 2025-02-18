import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dupepro/model/artist_model.dart';

class ArtistController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a getter for the artists collection
  CollectionReference get artistsCollection => _firestore.collection('artists');

  // Generate a unique artist ID
  String _generateArtistId() {
    return 'ARTIST-${DateTime.now().millisecondsSinceEpoch}';
  }

  // Register an artist and save their data
  Future<String?> registerArtist({
    required String artistType,
    required String bio,
    required bool joinBands,
    String? imageUrl,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return "User not logged in";
      }

      String artistId = _generateArtistId();
      Artist artist = Artist(
        uid: user.uid,
        id: artistId,
        artistType: artistType,
        bio: bio,
        joinBands: joinBands,
        imageUrl: imageUrl, // Include image URL
      );

      await _firestore.collection('artists').doc(artistId).set(artist.toMap());
      return null; // Success
    } catch (e) {
      print("Error registering artist: $e");
      return "Failed to register artist";
    }
  }

  // Add an artist
  Future<void> addArtist(Artist artist) async {
    try {
      await _firestore.collection('artists').doc(artist.id).set(artist.toMap());
    } catch (e) {
      print("Error adding artist: $e");
      rethrow;
    }
  }

  // Fetch all artists from Firestore
  Future<List<Artist>> getArtists() async {
    try {
      QuerySnapshot snapshot = await artistsCollection.get();
      return snapshot.docs
          .map((doc) => Artist.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching artists: $e");
      return [];
    }
  }

  // Fetch an artist by ID
  Future<Artist?> getArtistById(String artistId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('artists').doc(artistId).get();
      if (doc.exists) {
        return Artist.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error fetching artist: $e");
      return null;
    }
  }

  // Fetch the current logged-in user's name (if needed elsewhere)
  // This method is now optional and can be removed if no longer necessary.
  Future<String?> getCurrentUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return user.displayName ?? 'Anonymous'; // Fallback to 'Anonymous' if no display name is set
      }
      return null;
    } catch (e) {
      print("Error fetching user name: $e");
      return null;
    }
  }
  // Fetch all artists from Firestore
  Future<List<Artist>> fetchArtists() async {
    try {
      QuerySnapshot snapshot = await artistsCollection.get();
      return snapshot.docs.map((doc) {
        return Artist(
          id: doc.id,
          uid: doc['uid'],
          artistType: doc['artistType'],
          bio: doc['bio'],
          joinBands: doc['joinBands'],
        );
      }).toList();
    } catch (e) {
      print("Error fetching artists: $e");
      return [];
    }
  }
}
