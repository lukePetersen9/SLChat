import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/Homepage/homepage.dart';
import 'package:flutter_with_firebase/LoginAndSignup/login.dart';
import 'package:flutter_with_firebase/Firestore/firestoreMain.dart';

class UserSettings extends StatefulWidget {
  final String email;
  UserSettings(this.email);
  @override
  State<StatefulWidget> createState() {
    return UserSettingsState();
  }
}

class UserSettingsState extends State<UserSettings> {
  TextEditingController search = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController profileURL = new TextEditingController();
  FirestoreMain fire = new FirestoreMain();

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
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
        title: Text('User Settings'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    FirebaseAuth.instance.signOut();
                    return Login();
                  },
                ),
              );
            },
            child: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 75,
                ),
                Text(
                  'fName lName',
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Profile Image URL:',
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Garamond',
                            color: Colors.black54),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: profileURL,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                      child: FlatButton(
                        onPressed: () {
                          if (profileURL.text.isNotEmpty) {
                            fire.updateProfileImage(
                                widget.email, profileURL.text);
                          }
                        },
                        child: Text(
                          'update',
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Garamond',
                              color: Colors.black54),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
