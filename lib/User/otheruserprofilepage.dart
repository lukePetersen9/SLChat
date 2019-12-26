import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/FollowingAndFollowerLists/followerList.dart';
import '../Firestore/firestoreMain.dart';
import '../FollowingAndFollowerLists/followingList.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String otherUser;
  final String currentUser;
  OtherUserProfilePage(this.currentUser, this.otherUser);
  @override
  State<StatefulWidget> createState() {
    return OtherUserProfilePageState();
  }
}

class OtherUserProfilePageState extends State<OtherUserProfilePage> {
  String firstName = '',
      lastName = '',
      username = '',
      profilePicture =
          'https://previews.123rf.com/images/salamatik/salamatik1801/salamatik180100019/92979836-profile-anonymous-face-icon-gray-silhouette-person-male-default-avatar-photo-placeholder-isolated-on.jpg',
      bio = '';
  String followButton = '';
  bool isPrivate = false;
  int followerCount = 0, followingCount = 0;
  FirestoreMain fire = FirestoreMain();
  @override
  void initState() {
    super.initState();
    getProfileInfo(widget.otherUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        firstName + ' ' + lastName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.height / 25),
                      ),
                      isPrivate
                          ? Container(
                              child: Icon(
                                Icons.lock,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.only(left: 10),
                            )
                          : Container(
                              child: Icon(
                                Icons.lock_open,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.only(left: 10),
                            ),
                    ],
                  ),
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
                    Text(
                      'Followers',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width / 15),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return FollowerList(
                                  widget.currentUser, widget.otherUser);
                            },
                          ),
                        );
                      },
                      child: Text(
                        followerCount.toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 5),
                      ),
                    ),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return FollowingList(
                                  widget.currentUser, widget.otherUser);
                            },
                          ),
                        );
                      },
                      child: Text(followingCount.toString(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width / 5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 35),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Bio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35)),
              Text(bio),
            ],
          ),
        ],
      ),
      floatingActionButton: widget.currentUser == widget.otherUser
          ? null
          : FloatingActionButton.extended(
              label: Text(followButton),
              onPressed: () {
                if (followButton == 'Unfollow') {
                  fire.unfollowUser(widget.currentUser, widget.otherUser);
                  setState(() {
                    followerCount--;
                    followButton = 'Follow';
                  });
                } else {
                  fire.followUser(
                      widget.currentUser, widget.otherUser, isPrivate);
                  setState(() {
                    followerCount++;
                    followButton = 'Unfollow';
                  });
                }
              },
            ),
    );
  }

  void getProfileInfo(String email) async {
    var userQuery = Firestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1);
    userQuery.getDocuments().then((data) {
      setState(() {
        firstName = data.documents[0].data['firstName'];
        lastName = data.documents[0].data['lastName'];
        username = data.documents[0].data['username'];
        bio = data.documents[0].data['bio'];
        isPrivate = data.documents[0].data['isPrivate'];
        profilePicture = data.documents[0].data['profile_image'];
        followerCount = data.documents[0].data['followers'].length;
        followingCount = data.documents[0].data['following'].length;
        if (data.documents[0].data['followers'].contains(widget.currentUser)) {
          followButton = 'Unfollow';
        } else {
          followButton = 'Follow';
        }
      });
    });
  }
}
