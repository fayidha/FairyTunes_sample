// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:dupepro/model/troup_model.dart'; // Import the Troup model
//
// class TroupController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   // Get the 'troups' collection reference
//   CollectionReference get troupCollection => _firestore.collection('troups');
//
//   // Generate a unique Troup ID
//   String _generateTroupId() {
//     return 'TROUP-${DateTime.now().millisecondsSinceEpoch}';
//   }
//
//   // Register a new group (Create Troup)
//   Future<String?> createTroup({
//     required String name,
//     required String description,
//     required List<String> members,
//     String? imageUrl,
//   }) async {
//     try {
//       String troupId = _generateTroupId();
//       Troup troup = Troup(
//         id: troupId,
//         name: name,
//         description: description,
//         members: members,
//         imageUrl: imageUrl,
//       );
//
//       await troupCollection.doc(troupId).set(troup.toMap());
//       return null; // Success
//     } catch (e) {
//       print("Error creating group: $e");
//       return "Failed to create group";
//     }
//   }
//
//   // Fetch all groups (Troups) from Firestore
//   Future<List<Troup>> getTroups() async {
//     try {
//       QuerySnapshot snapshot = await troupCollection.get();
//       return snapshot.docs
//           .map((doc) => Troup.fromMap(doc.data() as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       print("Error fetching groups: $e");
//       return [];
//     }
//   }
//
//   // Fetch a single group (Troup) by ID
//   Future<Troup?> getTroupById(String troupId) async {
//     try {
//       DocumentSnapshot doc = await troupCollection.doc(troupId).get();
//       if (doc.exists) {
//         return Troup.fromMap(doc.data() as Map<String, dynamic>);
//       }
//       return null;
//     } catch (e) {
//       print("Error fetching group: $e");
//       return null;
//     }
//   }
//
//   // Update group details (e.g., change name, description, or members)
//   Future<String?> updateTroup({
//     required String troupId,
//     String? name,
//     String? description,
//     List<String>? members,
//     String? imageUrl,
//   }) async {
//     try {
//       Map<String, dynamic> updatedData = {};
//
//       if (name != null) updatedData['name'] = name;
//       if (description != null) updatedData['description'] = description;
//       if (members != null) updatedData['members'] = members;
//       if (imageUrl != null) updatedData['imageUrl'] = imageUrl;
//
//       await troupCollection.doc(troupId).update(updatedData);
//       return null; // Success
//     } catch (e) {
//       print("Error updating group: $e");
//       return "Failed to update group";
//     }
//   }
//
//   // Delete a group (Troup)
//   Future<String?> deleteTroup(String troupId) async {
//     try {
//       await troupCollection.doc(troupId).delete();
//       return null; // Success
//     } catch (e) {
//       print("Error deleting group: $e");
//       return "Failed to delete group";
//     }
//   }
// }
