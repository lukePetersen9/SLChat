import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/IndividualConversationPage/conversationPage.dart';

class FirestoreMain {
  String defaultProfileImage =
      'https://cdn150.picsart.com/upscale-245339439045212.png?r1024x1024';

  void makeNewConversation(String userEmail, List<String> otherUserEmails,
      BuildContext context) async {
    Firestore.instance
        .collection('conversations')
        .where('members', arrayContains: userEmail)
        .snapshots()
        .listen(
      (data) {
        bool alreadyExists = false;
        String docID = '';
        for (DocumentSnapshot d in data.documents) {
          bool everyEmail = true;
          for (String email in otherUserEmails) {
            if (!d.documentID.contains(email)) {
              everyEmail = false;
            }
          }
          if (everyEmail &&
              d.documentID.length ==
                  (userEmail + otherUserEmails.toList().toString()).length) {
            alreadyExists = true;
            docID = d.documentID;
          }
        }
        if (!alreadyExists) {
          var now = new DateTime.now();
          String docID = userEmail + otherUserEmails.toString();
          Firestore.instance
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
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ConversationPage(userEmail, docID, otherUserEmails);
              },
            ),
          );
        }
      },
    );
  }

  void createNewUser(String email, String username, String f, String l) async {
    await Firestore.instance.collection('users').document(email).setData(
      {
        'followers': [],
        'following': [],
        'email': email,
        'username': username,
        'firstName': f,
        'lastName': l,
        'username': username,
        'profile_image':
            'https://i.pinimg.com/236x/10/ae/df/10aedff18fca7367122784b4453c86bb--geometric-art-geometric-patterns.jpg',
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
          top: 15,
          left: i * 25.0,
          child: getUserProfileImage(emails[i], 20),
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

  Widget getUserProfileImage(String email, double rad) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return profileImage(defaultProfileImage, rad);
        }
        String e = snapshot.data.documents
            .firstWhere((test) => test.documentID == email)
            .data['profile_image'];
        defaultProfileImage = e;
        return profileImage(e, rad);
      },
    );
  }

  Widget profileSnippetInGeneralSearch(
      String email, String loggedInUser, double width, double height) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot == null || snapshot.data == null) {
            return Container();
          }
          List<dynamic> followers = snapshot.data.documents.first['followers'];

          List<dynamic> following = snapshot.data.documents.first['following'];
          // print(following.toString() + ' ' + email);
          return Container(
            width: width,
            height: height,
            child: Flex(
              children: <Widget>[
                Expanded(
                  child: getUserProfileImage(email, 35),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              snapshot.data.documents.first['firstName'] +
                                  ' ' +
                                  snapshot.data.documents.first['lastName'],
                              style: TextStyle(
                                fontSize: width / 15,
                                fontFamily: 'Garamond',
                                color: Colors.grey[800],
                              ),
                            ),
                            following != null &&
                                    following.contains(loggedInUser)
                                ? Text(
                                    'follows you',
                                    style: TextStyle(
                                      fontSize: width / 20,
                                      fontFamily: 'Garamond',
                                      color: Colors.grey[800],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        Text(
                          '  ' + snapshot.data.documents.first['username'],
                          style: TextStyle(
                            fontSize: width / 19,
                            fontFamily: 'Garamond',
                            color: Colors.grey[600],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: following != null && !followers.contains(loggedInUser)
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FlatButton(
                              onPressed: () {
                                followUser(loggedInUser, email);
                              },
                              child: Icon(Icons.add)),
                        )
                      : Container(),
                )
              ],
              direction: Axis.horizontal,
            ),
          );
        });
  }

  Widget profileSnippetInFollowSearch(String email, String loggedInUser,
      double width, double height, String searchText) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot == null || snapshot.data == null) {
            return Container();
          }
          String wholeName = snapshot.data.documents.first['firstName'] +
              ' ' +
              snapshot.data.documents.first['lastName'];
          if (!wholeName.contains(searchText) &&
              !snapshot.data.documents.first['username']
                  .toString()
                  .contains(searchText)) {
            return Container();
          }
          List<dynamic> followers = snapshot.data.documents.first['followers'];
          List<dynamic> following = snapshot.data.documents.first['following'];
          return Container(
            width: width,
            height: height,
            child: Flex(
              children: <Widget>[
                Expanded(
                  child: getUserProfileImage(email, 35),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              snapshot.data.documents.first['firstName'] +
                                  ' ' +
                                  snapshot.data.documents.first['lastName'],
                              style: TextStyle(
                                fontSize: width / 15,
                                fontFamily: 'Garamond',
                                color: Colors.grey[800],
                              ),
                            ),
                            followers != null &&
                                    followers.contains(loggedInUser)
                                ? Text(
                                    'following',
                                    style: TextStyle(
                                      fontSize: width / 20,
                                      fontFamily: 'Garamond',
                                      color: Colors.grey[800],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        Text(
                          '  ' + snapshot.data.documents.first['username'],
                          style: TextStyle(
                            fontSize: width / 19,
                            fontFamily: 'Garamond',
                            color: Colors.grey[600],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: following != null && !followers.contains(loggedInUser)
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FlatButton(
                              onPressed: () {
                                followUser(loggedInUser, email);
                              },
                              child: Icon(Icons.add)),
                        )
                      : Container(),
                )
              ],
              direction: Axis.horizontal,
            ),
          );
        });
  }

  void followUser(String currentUser, String otherUser) async {
    print(currentUser + ' is trying to follow ' + otherUser);
    await Firestore.instance
        .collection('users')
        .document(currentUser)
        .updateData(
      {
        'following': FieldValue.arrayUnion(
          [otherUser],
        )
      },
    );
    await Firestore.instance.collection('users').document(otherUser).updateData(
      {
        'followers': FieldValue.arrayUnion(
          [currentUser],
        )
      },
    );
  }

  Widget profileImage(String url, double rad) {
    return CircleAvatar(
      radius: rad,
      backgroundImage: NetworkImage(url),
    );
  }
}
