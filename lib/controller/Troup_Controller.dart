import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/model/Troup_model.dart';

class TroupController {
  final CollectionReference troupsCollection = FirebaseFirestore.instance.collection('troups');

  Future<void> createTroup(Troup troup) async {
    await troupsCollection.doc(troup.id).set(troup.toMap());
  }

  Stream<List<Troup>> getTroups() {
    return troupsCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Troup.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }
}