import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/Firestore/firestoreMain.dart';
import 'package:flutter_with_firebase/Scoped/userModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'profilepage.dart';
import '../FollowingAndFollowerLists/followerList.dart';
import '../FollowingAndFollowerLists/followingList.dart';
import 'package:flutter_with_firebase/AlertDialogs/leaveEditingProfilePageConfirmation.dart';

class EditUserProfilePage extends StatefulWidget {
  final String email;
  EditUserProfilePage(this.email);
  @override
  State<StatefulWidget> createState() {
    return EditUserProfilePageState();
  }
}

class EditUserProfilePageState extends State<EditUserProfilePage> {
  String initialUsername = '';
  String profilePicture =
      'https://previews.123rf.com/images/salamatik/salamatik1801/salamatik180100019/92979836-profile-anonymous-face-icon-gray-silhouette-person-male-default-avatar-photo-placeholder-isolated-on.jpg';
  bool isPrivate = false;
  TextEditingController first = new TextEditingController();
  TextEditingController last = new TextEditingController();
  TextEditingController user = new TextEditingController();
  TextEditingController profileImageUrl = new TextEditingController();
  TextEditingController b = new TextEditingController();
  FirestoreMain fire = new FirestoreMain();
  bool goodUsername = true;

  @override
  Widget build(BuildContext context) {
    getProfileInfo();
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
             //showDialog();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              fire.profileImage(profilePicture, 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('First Name:'),
                  TextField(
                    controller: first,
                  ),
                  Text('Last Name:'),
                  TextField(
                    controller: last,
                  ),
                  Text('Username:'),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 200,
                        child: TextField(
                          controller: user,
                          onChanged: (change) {
                            checkUserName(change);
                          },
                        ),
                      ),
                      Icon(
                        goodUsername ? Icons.mood : Icons.mood_bad,
                        color: goodUsername ? Colors.green : Colors.red,
                      )
                    ],
                  ),
                  Text('Bio:'),
                  TextField(
                    maxLines: null,
                    controller: b,
                  ),
                  Text('Profile Image URL:'),
                  TextField(
                    controller: profileImageUrl,
                  ),
                  Row(
                    children: <Widget>[
                      Text('Private '),
                      Icon(isPrivate ? Icons.lock : Icons.lock_open),
                      Switch(
                        value: isPrivate,
                        onChanged: (b) {
                          setState(() {
                            isPrivate = b;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              FlatButton(
                child: Text('save changes'),
                onPressed: () {
                  if (first.text.isNotEmpty &&
                      last.text.isNotEmpty &&
                      b.text.isNotEmpty &&
                      goodUsername) {
                    fire.updateUserData(widget.email, user.text, first.text,
                        last.text, b.text, isPrivate);
                    if (profileImageUrl.text.isNotEmpty &&
                        profileImageUrl.text != profilePicture) {
                      fire.updateProfileImage(
                          widget.email, profileImageUrl.text);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ProfilePage(widget.email);
                        },
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void checkUserName(String username) {
    var userQuery = Firestore.instance
        .collection('users')
        .where('username', isEqualTo: username);
    userQuery.getDocuments().then(
      (data) {
        print(goodUsername);
        setState(
          () {
            data.documents.length == 0 || username == initialUsername
                ? goodUsername = true
                : goodUsername = false;
          },
        );
      },
    );
  }

  void _showDialog() {
    var model = ScopedModel.of<UserModel>(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LeaveEditingProfilePageConfirmationDialog(model.email);
      },
    );
  }

  void getProfileInfo() {
    var model = ScopedModel.of<UserModel>(context, rebuildOnChange: true);
    setState(() {
      first = new TextEditingController(
              text: model.firstName);
          last = new TextEditingController(
              text: model.lastName);
          initialUsername = model.username;
          user = new TextEditingController(text: initialUsername);
          profilePicture = model.profileImage;
          isPrivate = model.isPrivate;
          b = new TextEditingController(text: model.bio);
          profileImageUrl = new TextEditingController(text: profilePicture);
    });
    
  }
}
