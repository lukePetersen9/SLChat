import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/Homepage/homepage.dart';
import 'package:flutter_with_firebase/Scoped/userModel.dart';
import 'package:flutter_with_firebase/User/editUserProfile.dart';
import 'package:scoped_model/scoped_model.dart';

import '../FollowingAndFollowerLists/followerList.dart';
import '../FollowingAndFollowerLists/followingList.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  final UserModel model;
  ProfilePage(this.email, this.model);
  @override
  State<StatefulWidget> createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  String firstName = '',
      lastName = '',
      username = '',
      profilePicture =
          'https://previews.123rf.com/images/salamatik/salamatik1801/salamatik180100019/92979836-profile-anonymous-face-icon-gray-silhouette-person-male-default-avatar-photo-placeholder-isolated-on.jpg',
      bio = '';
  bool isPrivate = false;
  int followerCount = 0, followingCount = 0;
  @override
  void initState() {
    super.initState();
    getProfileInfo(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model: widget.model,
          child: Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
            leading: IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return HomePage(widget.email);
                    },
                  ),
                );
              },
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return EditUserProfilePage(widget.email, widget.model);
                      },
                    ),
                  );
                },
                icon: Icon(Icons.edit),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            firstName + ' ' + lastName,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.height / 25),
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
                                    fontSize:
                                        MediaQuery.of(context).size.width / 5)),
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return FollowerList(widget.email, widget.email, widget.model);
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
                                    fontSize:
                                        MediaQuery.of(context).size.width / 5)),
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return FollowingList(widget.email, widget.email, widget.model);
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
                    Text('Bio',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 35)),
                    ScopedModelDescendant<UserModel>(
                      builder: (context, child, model){
                        return Text(model.bio);
                      }
                    )
                  ],
                )
              ],
            ),
          ),
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
        isPrivate = data.documents[0].data['isPrivate'];
        followerCount = data.documents[0].data['followers'].length;
        followingCount = data.documents[0].data['following'].length;
      });
    });
  }
}
