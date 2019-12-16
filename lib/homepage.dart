import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/userSettings.dart';
import 'searchDialog.dart';
import 'login.dart';
import 'firestoreMain.dart';

class HomePage extends StatefulWidget {
  final String email;
  HomePage(this.email);
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  TextEditingController search = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    FirestoreMain g = new FirestoreMain();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[100],
        leading: Container(),
        title: Text('Your Conversations', style: TextStyle(color: Colors.grey[850])),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return UserSettings();
            },
          ),
        );
            },
            child: Icon(
              Icons.settings,
              color: Color.fromRGBO(43, 158, 179, 1),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(43, 158, 179, 1),
        child: Icon(Icons.chat),
        onPressed: () {
          _showDialog();
        },
      ),
      body: SingleChildScrollView(
        child: g.showConversations(widget.email),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchDialog(widget.email);
      },
    );
  }
}
