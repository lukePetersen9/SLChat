import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: Text('Your Conversations'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
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
