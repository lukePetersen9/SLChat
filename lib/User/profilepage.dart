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
  ProfilePage(this.email);
  @override
  State<StatefulWidget> createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
      var model = ScopedModel.of<UserModel>(context, rebuildOnChange: true);
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          leading: IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return HomePage();
                  },
                ),
              );
            },
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return EditUserProfilePage(widget.email);
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
                      backgroundImage: NetworkImage(model.profileImage),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          model.firstName + ' ' + model.lastName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.height / 25),
                        ),
                        model.isPrivate
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
                    Text(model.username,
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
                          Text(model.followers.length.toString(),
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
                              return FollowerList(widget.email, widget.email);
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
                          Text(model.following.length.toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 5)),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return FollowingList(widget.email, widget.email);
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
                  Text(ScopedModel.of<UserModel>(context, rebuildOnChange: true)
                      .bio),
                ],
              )
            ],
          ),
        ),
      );
    }
  }
