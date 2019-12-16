import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'searchDialog.dart';
import 'login.dart';
import 'firestoreMain.dart';

class UserSettings extends StatefulWidget {
  UserSettings();
  @override
  State<StatefulWidget> createState() {
    return UserSettingsState();
  }
}

class UserSettingsState extends State<UserSettings> {
  TextEditingController search = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    FirestoreMain g = new FirestoreMain();
    return Scaffold(
      appBar: AppBar(
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
                Text('fName lName', )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
