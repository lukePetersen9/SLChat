import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'conversationPage.dart';

class FirestoreMain {
  String profileImage =
      'https://cdn150.picsart.com/upscale-245339439045212.png?r1024x1024';

  void makeNewConversation(
      String userEmail, List<String> otherUserEmails) async {
    var now = new DateTime.now();
    String docID = userEmail + otherUserEmails.toString();
    await Firestore.instance
        .collection("conversations")
        .document(docID)
        .setData(
      {
        'started': now,
        'members': [userEmail] + otherUserEmails,
        'lastOpened' + userEmail: now.toString(),
        'lastMessage': 'send a message!',
        'lastMessageTime': now.toString(),
      },
    );
  }

  void addInteraction(
      String type, String email, String docID, String time) async {
    await Firestore.instance
        .collection("conversations")
        .document(docID)
        .collection('messages')
        .document(time)
        .updateData(
      {
        'interactions': FieldValue.arrayUnion([email + '@' + type])
      },
    );
  }

  void updateProfileImage(String email, String profileImage) async {
    await Firestore.instance.collection('users').document(email).updateData(
      {
        'profile_image': profileImage,
      },
    );
  }

  Widget showConversations(String email) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('conversations')
          .where('members', arrayContains: email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return new Text('${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            if (!snapshot.hasData) return Text('No data found!');
            List<String> times = new List<String>();
            Map<String, Widget> tiles = new Map<String, Widget>();
            for (DocumentSnapshot s in snapshot.data.documents) {
              String time = s.data['lastMessageTime'];
              String lastMsg = s.data['lastMessage'];
              List<dynamic> members = new List<dynamic>();
              members.addAll(s.data['members']);
              members.remove(email);
              times.add(time);
              tiles[time] = GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ConversationPage(email, s.documentID, members);
                      },
                    ),
                  );
                },
                child: Container(
                  color: Colors.grey[100],
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 10,
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: <Widget>[
                      displayProfileImages(members),
                      Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        direction: Axis.vertical,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                                child: getUsersInGroup(
                                    email,
                                    members,
                                    TextStyle(
                                        fontSize: 18, color: Colors.black))),
                          ),
                          Expanded(
                            child: lastMsg.length <= 40
                                ? Text(lastMsg,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromRGBO(43, 158, 179, 1)))
                                : Text(lastMsg.substring(0, 40) + "...",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color.fromRGBO(43, 158, 179, 1))),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            List<Widget> orderedTiles = new List<Widget>();
            times.sort();
            for (int i = times.length - 1; i >= 0; i--) {
              orderedTiles.add(tiles[times[i]]);
            }
            return Column(
              children: orderedTiles,
            );
          default:
            return Text('error');
        }
      },
    );
  }

  Widget getUsersInGroup(
      String currentUserEmail, List<dynamic> members, TextStyle s) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        List<String> names = new List<String>();
        for (String user in members) {
          String first = snapshot.data.documents.singleWhere(
            (DocumentSnapshot d) {
              return d.documentID == user;
            },
          ).data['firstName'];
          String last = snapshot.data.documents.singleWhere(
            (DocumentSnapshot d) {
              return d.documentID == user;
            },
          ).data['lastName'];
          if (user != currentUserEmail) {
            names.add(first + ' ' + last);
          }
        }
        String formattedNames = "";
        for (int i = 0; i < names.length - 2; i++) {
          formattedNames += names[i] + ', ';
        }
        if (names.length > 2) {
          formattedNames +=
              names[names.length - 2] + ' & ' + names[names.length - 1];
        } else if (names.length == 2) {
          formattedNames += names[0] + ' & ' + names[1];
        } else {
          formattedNames = names[0];
        }
        return Text(
          formattedNames,
          style: s,
        );
      },
    );
  }

  Widget displayProfileImages(List<dynamic> emails) {
    List<Widget> images = new List<Widget>();
    for (int i = 0; i < emails.length; i++) {
      images.add(
        Positioned(
          left: i * 25.0,
          child: getUserProfileImage(emails[i]),
        ),
      );
    }
    return Container(
      height: 75,
      width: 75,
      child: Stack(
        children: images,
      ),
    );
  }

  Widget getUserProfileImage(String email) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return _profileImage(profileImage);
        }
        String e = snapshot.data.documents
            .firstWhere((test) => test.documentID == email)
            .data['profile_image'];
        profileImage = e;
        return _profileImage(e);
      },
    );
  }

  Widget _profileImage(String url) {
    return Container(
      padding: EdgeInsets.all(5),
      child: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(url),
      ),
    );
  }
}
