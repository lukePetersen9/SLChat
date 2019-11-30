import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/GeneralMessageWithInteractionsForCurrentUser.dart';
import 'package:flutter_with_firebase/user.dart';
import 'conversationPage.dart';

class FirestoreMain {
  final databaseReference = Firestore.instance;
  Map<String, User> convoPeople = new Map<String, User>();
  Map<String, Map<String, Widget>> convoTile =
      new Map<String, Map<String, Widget>>();
  Map<String, String> order = new Map<String, String>();

  Widget getMessages(String id) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('conversations/' + id + '/messages')
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
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return Text('No data found!');
            }
            List<Widget> messages = new List<Widget>();
            final Map<String, String> interactions = new Map<String, String>();
            for (DocumentSnapshot d in snapshot.data.documents) {
              messages.add(
                GeneralMessageWithInteractionsForCurrentUser(
                    d.data['content'],
                    'ljpete22@yahoo.com',
                    d.documentID,
                    interactions,
                    'null',
                    true,
                    'read'),
              );
            }
            return Column(
              children: messages,
            );
          default:
            return Text('error');
        }
      },
    );
  }

  void makeNewConversation(
      String userEmail, List<String> otherUserEmails) async {
    var now = new DateTime.now();
    List<String> copy = otherUserEmails;
    String docID = userEmail + otherUserEmails.toString();
    await databaseReference.collection("conversations").document(docID).setData(
      {
        'started': now,
        'members': [userEmail] + otherUserEmails,
        'lastOpened' + userEmail: now.toString(),
        'lastMessage': 'send a message!',
        'lastMessageTime': now.toString(),
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
                        return ConversationPage(email, s.documentID);
                      },
                    ),
                  );
                },
                child: Container(
                  color: Colors.white,
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
                            flex: 3,
                            child: Container(
                                child: getUsersInGroup(
                                    email, members, TextStyle())),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(s.data['lastMessage']),
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
            for (int i = 0; i < times.length; i++) {
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
          String username = snapshot.data.documents.singleWhere(
            (DocumentSnapshot d) {
              return d.documentID == user;
            },
          ).data['username'];
          String profileImage = snapshot.data.documents.singleWhere(
            (DocumentSnapshot d) {
              return d.documentID == user;
            },
          ).data['profile_image'];
          String email = snapshot.data.documents.singleWhere(
            (DocumentSnapshot d) {
              return d.documentID == user;
            },
          ).data['email'];
          convoPeople[user] =
              new User(first, last, email, profileImage, username);

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
    print(emails);
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
      stream: Firestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        print(snapshot.data.documents.first.data['profile_image']);
        return profileImage(
            snapshot.data.documents.first.data['profile_image']);
      },
    );
  }

  Widget profileImage(String url) {
    return Padding(
      padding: EdgeInsets.only(right: 7, left: 10),
      child: Container(
        child: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(url),
        ),
      ),
    );
  }
}
