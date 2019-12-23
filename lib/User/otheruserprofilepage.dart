import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Firestore/firestoreMain.dart';
import '../FollowingAndFollowerLists/followingList.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String otherUser;
  final String currentUser;
  OtherUserProfilePage(this.currentUser,this.otherUser);
  @override
  State<StatefulWidget> createState() {
    return OtherUserProfilePageState();
  }
}

class OtherUserProfilePageState extends State<OtherUserProfilePage> {
  String firstName, lastName, username, profilePicture, bio;
  String followButton;
  int followerCount, followingCount;
  FirestoreMain fire = FirestoreMain();
  @override
  Widget build(BuildContext context) {
    getProfileInfo(widget.otherUser);
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3,
              color: Color.fromRGBO(43, 158, 179, 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.width / 5,
                    backgroundImage: NetworkImage(profilePicture),
                  ),
                  Text('${firstName} ${lastName}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.height / 25)),
                  Text(username,
                      style: TextStyle(
                          color: Colors.grey[100],
                          fontSize: MediaQuery.of(context).size.height / 35)),
                ],
              )),
          Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 5,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(width: 0.25, color: Colors.black),
                    bottom: BorderSide(width: 0.5, color: Colors.black),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Text('Followers',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 15)),
                    Text(followerCount.toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 5)),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 5,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(width: 0.25, color: Colors.black),
                    bottom: BorderSide(width: 0.5, color: Colors.black),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Text('Following',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 15)),
                    Text(followingCount.toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 5)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(followButton),
        onPressed: () {
          if (followButton == 'Unfollow') {
            fire.unfollowUser(widget.currentUser, widget.otherUser);
            followButton = 'Follow';
            }
          else
          {
            fire.followUser(widget.currentUser, widget.otherUser);
            followButton = 'Unfollow';
          }
        },
      ),
    );
  }

  void getProfileInfo(String email) {
    var userQuery = Firestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1);
    userQuery.getDocuments().then((data) {
      setState(() {
        firstName = data.documents[0].data['firstName'];
        lastName = data.documents[0].data['lastName'];
        username = data.documents[0].data['username'];
        profilePicture = data.documents[0].data['profile_image'];
        followerCount = data.documents[0].data['followers'].length;
        followingCount = data.documents[0].data['following'].length;
        if (data.documents[0].data['followers'].contains('s@s.net')) {
          followButton = 'Unfollow';
        }
        else
        {
          followButton = 'Follow';
        }
      });
    });
  }
}
