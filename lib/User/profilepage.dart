import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../FollowingAndFollowerLists/followerList.dart';
import '../FollowingAndFollowerLists/followingList.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  ProfilePage(this.email);
  @override
  State<StatefulWidget> createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  String firstName, lastName, username, profilePicture, bio;
  int followerCount, followingCount;
  @override
  Widget build(BuildContext context) {
    getProfileInfo(widget.email);
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
            ),
          ),
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
                child: FlatButton(
                  child: Column(
                    children: <Widget>[
                      Text('Followers',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.width / 15)),
                      Text(followerCount.toString(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width / 5)),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return FollowerList(widget.email);
                        },
                      ),
                    );
                  },
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
                child: FlatButton(
                  child: Column(
                    children: <Widget>[
                      Text('Following',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.width / 15)),
                      Text(followingCount.toString(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width / 5)),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return FollowingList(widget.email);
                      },
                    ));
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 35),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Bio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35)),
              Text(bio),
            ],
          )
        ],
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
        bio = data.documents[0].data['bio'];
        followerCount = data.documents[0].data['followers'].length;
        followingCount = data.documents[0].data['following'].length;
      });
    });
  }
}
