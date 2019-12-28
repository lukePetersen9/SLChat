import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/Firestore/firestoreMain.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/Scoped/userModel.dart';
import 'package:flutter_with_firebase/User/otheruserprofilepage.dart';

class FollowerList extends StatefulWidget {
  final FirestoreMain fire = new FirestoreMain();
  final String currentUserEmail;
  final String otherUserEmail;
  FollowerList(this.currentUserEmail, this.otherUserEmail, UserModel model);
  @override
  State<StatefulWidget> createState() {
    return FollowerListState();
  }
}

class FollowerListState extends State<FollowerList> {
  FirestoreMain fire = new FirestoreMain();
  String searchText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text('Followers')),
      body: Flex(
        direction: Axis.vertical,
        children: <Widget>[
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
            flex: 10,
            child: displayFollowerSearch(searchText),
          ),
        ],
      ),
    );
  }

  Widget displayFollowerSearch(String s) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.otherUserEmail)
          .limit(1)
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
                snapshot.data.documents.first['followers'];
            List<Widget> searchResultTextBox = new List<Widget>();
            for (String email in followers) {
              searchResultTextBox.add(
                profileSnippetInFollowerSearch(email, widget.currentUserEmail,
                    MediaQuery.of(context).size.width, 100, s),
              );
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

  Widget profileSnippetInFollowerSearch(String email, String loggedInUser,
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
          List<dynamic> requests =
              snapshot.data.documents.first['notifications'];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return OtherUserProfilePage(loggedInUser, email);
                  },
                ),
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
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
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Icon(
                                    snapshot.data.documents[0].data['isPrivate']
                                        ? Icons.lock
                                        : Icons.lock_open),
                              ),
                              followers != null &&
                                      followers.contains(loggedInUser)
                                  ? Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Text(
                                        'following',
                                        style: TextStyle(
                                          fontSize: width / 20,
                                          fontFamily: 'Garamond',
                                          color: Colors.grey[800],
                                        ),
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
                    child: following != null &&
                            !followers.contains(loggedInUser) &&
                            loggedInUser != email &&
                            requests != null &&
                            !requests.contains(loggedInUser)
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FlatButton(
                                onPressed: () {
                                  fire.followUser(
                                      loggedInUser,
                                      email,
                                      snapshot
                                          .data.documents.first['isPrivate']);
                                },
                                child: Icon(Icons.add)),
                          )
                        : requests != null && requests.contains(loggedInUser)
                            ? Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.blue, width: 3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Pending',
                                  style: TextStyle(
                                    fontSize: width / 19,
                                    fontFamily: 'Garamond',
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : Container(),
                  )
                ],
                direction: Axis.horizontal,
              ),
            ),
          );
        });
  }
}
