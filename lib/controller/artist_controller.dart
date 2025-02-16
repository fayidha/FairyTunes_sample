import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/artist_model.dart';

class ArtistController {
  final CollectionReference artistsCollection = FirebaseFirestore.instance.collection('artists');

  Future<void> addArtist(Artist artist) {
    return artistsCollection.doc(artist.id).set(artist.toMap());
  }
}
