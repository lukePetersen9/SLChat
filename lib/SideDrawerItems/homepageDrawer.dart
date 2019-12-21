import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/SideDrawerItems/userSettings.dart';
import 'package:flutter_with_firebase/Firestore/firestoreMain.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/FollowingAndFollowerLists/followingList.dart';
import 'package:flutter_with_firebase/FollowingAndFollowerLists/followerList.dart';

class HomepageDrawer extends StatelessWidget {
  final FirestoreMain fire = new FirestoreMain();
  final String email;
  HomepageDrawer(this.email);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                getUserNameAndUsernameCurrentUser(
                    email, MediaQuery.of(context).size.width, 130),
              ],
            ),
            decoration: BoxDecoration(
              color: Color.fromRGBO(43, 158, 179, 1),
            ),
          ),
          ListTile(
            title: Text('Your Profile'),
            onTap: () {},
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return UserSettings(email);
                  },
                ),
              );
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget getUserNameAndUsernameCurrentUser(
      String email, double width, double height) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot == null || snapshot.data == null) {
          return Container();
        } else {}
        List<dynamic> followers = snapshot.data.documents.first['followers'];
        List<dynamic> following = snapshot.data.documents.first['following'];
        int numFollowers = followers == null ? 0 : followers.length;
        int numFollowing = following == null ? 0 : following.length;
        return Container(
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flex(
                children: <Widget>[
                  Expanded(
                      child: fire.profileImage(
                          snapshot.data.documents.first['profile_image'], 30)),
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
                ],
                direction: Axis.horizontal,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return FollowerList(email);
                          },
                        ),
                      );
                    },
                    child: Text(numFollowers.toString() + ' followers'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return FollowingList(email);
                          },
                        ),
                      );
                    },
                    child: Text(numFollowing.toString() + ' following'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
