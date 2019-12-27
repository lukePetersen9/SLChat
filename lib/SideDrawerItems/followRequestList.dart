import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/Firestore/firestoreMain.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/User/otheruserprofilepage.dart';

class FollowRequestList extends StatefulWidget {
  final FirestoreMain fire = new FirestoreMain();
  final String currentUserEmail;

  FollowRequestList(this.currentUserEmail);
  @override
  State<StatefulWidget> createState() {
    return FollowRequestListState();
  }
}

class FollowRequestListState extends State<FollowRequestList> {
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
          title: Text('Follow Requests')),
      body: displayFollowerSearch(searchText),
    );
  }

  Widget displayFollowerSearch(String s) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.currentUserEmail)
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
            List<dynamic> requests =
                snapshot.data.documents.first['notifications'];
            List<Widget> searchResultTextBox = new List<Widget>();
            if(requests == null)
            {
              return Text('You have no follow requests');
            }
            else{
               for (String email in requests) {
              searchResultTextBox.add(
                profileSnippetInRequestList(email, widget.currentUserEmail,
                    MediaQuery.of(context).size.width, 100),
              );
            }
           
            }
            if (searchResultTextBox.length == 0) {
              searchResultTextBox.add(Text('You have no follow requests'));
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

  Widget profileSnippetInRequestList(
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
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 3,
                              color: Colors.teal[200],
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              fire.acceptFollowRequest(loggedInUser, email);
                            },
                            icon: Icon(Icons.check),
                            color: Colors.green[300],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 3,
                              color: Colors.teal[200],
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              fire.rejectFollowRequest(loggedInUser, email);
                            },
                            icon: Icon(Icons.cancel),
                            color: Colors.red[300],
                          ),
                        ),
                      ],
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

// Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                           width: 3,
//                           color: Colors.teal[200],
//                         ),
//                       ),
//                       child: Text(
//                         'cancel',
//                         style: TextStyle(
//                           fontSize: width / 19,
//                           fontFamily: 'Garamond',
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     )
