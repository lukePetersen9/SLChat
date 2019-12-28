import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/Firestore/firestoreMain.dart';
import 'package:flutter_with_firebase/Scoped/userModel.dart';

class StartANewConversationDialog extends StatefulWidget {
  final String userEmail;
  StartANewConversationDialog(this.userEmail);
  @override
  State<StatefulWidget> createState() {
    return StartANewConversationDialogState();
  }
}

class StartANewConversationDialogState
    extends State<StartANewConversationDialog> {
  FirestoreMain fire = new FirestoreMain();
  final databaseReference = Firestore.instance;
  String searchText = "";
  Map<String, String> users = new Map<String, String>();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.grey[100],
      title: Text('Start a New Conversation'),
      content: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
            child: usersInGroup(users),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  cursorColor: Colors.white38,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Garamond',
                        color: Colors.white54),
                  ),
                  style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Garamond',
                      color: Colors.white54),
                  onChanged: (change) {
                    setState(() {
                      searchText = change;
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: displaySearch(searchText),
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text("Close",
              style: TextStyle(color: Color.fromRGBO(43, 158, 179, 1))),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: new Text("Start Conversation",
              style: TextStyle(color: Color.fromRGBO(43, 158, 179, 1))),
          onPressed: () {
            if (users.length > 0) {
             // print(widget.userEmail + users.keys.toList().toString());
              fire.makeNewConversation(
                  widget.userEmail, users.keys.toList(), context);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget usersInGroup(Map<String, String> names) {
    List<Widget> people = new List<Widget>();
    for (String name in names.values) {
      people.add(
        Row(
          children: <Widget>[
            Container(
              child: Text(name),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal, width: 2),
              ),
            ),
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  users.removeWhere(
                    (k, v) {
                      return v == name;
                    },
                  );
                });
              },
            )
          ],
        ),
      );
    }
    return SingleChildScrollView(
      child: Row(children: people),
      scrollDirection: Axis.horizontal,
    );
  }

  Widget canCreate() {
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
            print(snapshot.data.documents.length);
            return Container();

          default:
            return Text('error');
        }
      },
    );
  }

  Widget displaySearch(String s) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.userEmail)
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

            List<dynamic> followers =
                List.from(snapshot.data.documents.first['followers']);
            List<dynamic> following =
                List.from(snapshot.data.documents.first['following']);
            followers.retainWhere((d) {
              return following.contains(d);
            });
            List<Widget> searchResultTextBox = new List<Widget>();
            for (String email in followers) {
              if (email != widget.userEmail && !users.containsKey(email)) {
                searchResultTextBox.add(
                  profileSnippetConvoSearch(email, widget.userEmail,
                      MediaQuery.of(context).size.width, 130, searchText),
                );
              }
            }
            return SingleChildScrollView(
              child: Column(
                children: searchResultTextBox,
              ),
            );

          default:
            return Text('error');
        }
      },
    );
  }

  Widget profileSnippetConvoSearch(String email, String loggedInUser,
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
        return GestureDetector(
          onTap: () {
            setState(
              () {
                users[snapshot.data.documents.first['email']] = wholeName;
              },
            );
          },
          child: Container(
            width: width,
            height: height,
            child: Flex(
              children: <Widget>[
                Expanded(
                  child: fire.getUserProfileImage(email, 35),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {},
                ))
              ],
              direction: Axis.horizontal,
            ),
          ),
        );
      },
    );
  }
}
