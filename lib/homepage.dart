import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/conversationPage.dart';
import 'searchDialog.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  final String email;
  HomePage(this.email);
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final databaseReference = Firestore.instance;
  String searchText = "";
  String firstUser = "";
  String secondUser = "";
  TextEditingController search = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Conversations'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  FirebaseAuth.instance.signOut();
                  return Login();
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showDialog();
        },
      ),
      body: SingleChildScrollView(
        child: showConversations(widget.email),
      ),
    );
  }

  // user defined function
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SearchDialog(widget.email);
      },
    );
  }

  Widget showConversations(String email) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('conversations').snapshots(),
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
            List<String> convoEmails = new List<String>();
            for (DocumentSnapshot d in snapshot.data.documents) {
              if (d.documentID.contains(email)) {
                convoEmails.add(d.documentID.replaceFirst(email, '').trim());
              }
            }

            List<Widget> conversations = new List<Widget>();
            for (String name in convoEmails) {
              conversations.add(
                new GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ConversationPage(email, name);
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
                        getUserData(name, 'profile_image', 'userdata', null),
                        Flex(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          direction: Axis.vertical,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: Row(
                                  children: <Widget>[
                                    getUserData(
                                      name,
                                      'firstName',
                                      'userdata',
                                      TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Garamond',
                                        color: Colors.grey[850],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 7,
                                    ),
                                    getUserData(
                                      name,
                                      'lastName',
                                      'userdata',
                                      TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Garamond',
                                        color: Colors.grey[850],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    getUserData(
                                      name,
                                      'username',
                                      'userdata',
                                      TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Garamond',
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: getUserData(
                                name,
                                widget.email,
                                'conversations',
                                TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Garamond',
                                  color: Colors.grey[700],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: conversations,
            );
          default:
            return Text('error');
        }
      },
    );
  }

  Widget getUserData(String email, String type, String path, TextStyle style) {
    String wantedData = "";
    if (path == 'userdata') {
      return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');
          for (DocumentSnapshot d in snapshot.data.documents) {
            if (d.documentID == email) {
              wantedData = d.data[type];
            }
          }
          switch (type) {
            case 'firstName':
              return Text(
                wantedData,
                style: style,
              );
            case 'lastName':
              return Text(
                wantedData,
                style: style,
              );
            case 'profile_image':
              return profileImage(wantedData);
            case 'username':
              return Text(
                wantedData,
                style: style,
              );
            default:
              return Text('error');
          }
        },
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('conversations').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');

          for (DocumentSnapshot d in snapshot.data.documents) {
            if (d.documentID.contains(widget.email) &&
                d.documentID.contains(email) &&
                d.documentID.length == widget.email.length + email.length + 1) {
              firstUser = d.documentID.substring(0, d.documentID.indexOf(' '));
              secondUser =
                  d.documentID.substring(d.documentID.indexOf(' ') + 1);
            }
          }
          DocumentSnapshot s = snapshot.data.documents.where(
            (DocumentSnapshot d) {
              return d.documentID == firstUser + ' ' + secondUser;
            },
          ).first;
          List<dynamic> i = s.data['allTexts'];
          wantedData = i[i.length - 1]['content'];
          return Text(
            wantedData,
            style: style,
          );
        },
      );
    }
  }
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
