import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dupepro/chat.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("chat_rooms").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No chats available"));
          }

          var chatRooms = snapshot.data!.docs.where((doc) {
            List<String> userIds = doc.id.split("_");
            return userIds.contains(currentUserId);
          }).toList();

          if (chatRooms.isEmpty) {
            return Center(child: Text("No active chats found"));
          }

          return FutureBuilder<QuerySnapshot>(
            future: _firestore.collection("users").get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var users = userSnapshot.data!.docs.map((doc) {
                return doc.data() as Map<String, dynamic>;
              }).toList();

              return ListView.builder(
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  var chatRoom = chatRooms[index];
                  List<String> userIds = chatRoom.id.split("_");
                  String otherUserId = userIds.firstWhere((id) => id != currentUserId);

                  var userData = users.firstWhere((user) => user["uid"] == otherUserId, orElse: () => {});
                  String otherUserName = userData["name"] ?? "Unknown User";

                  return StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection("chat_rooms")
                        .doc(chatRoom.id)
                        .collection("messages")
                        .orderBy("timestamp", descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, messageSnapshot) {
                      if (!messageSnapshot.hasData || messageSnapshot.data!.docs.isEmpty) {
                        return SizedBox.shrink(); // Hide empty chats
                      }

                      var lastMessage = messageSnapshot.data!.docs.first;
                      String lastMessageText = lastMessage["message"];
                      Timestamp lastMessageTime = lastMessage["timestamp"];

                      return Card(
                        child: ListTile(
                          title: Text(otherUserName),
                          subtitle: Text(lastMessageText),
                          trailing: Text(_formatTimestamp(lastMessageTime)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(otherUserId, otherUserName),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.hour}:${date.minute}"; // Format as HH:MM
  }
}