import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/AlertDialogs/startANewConversationDialog.dart';
import 'package:flutter_with_firebase/Firestore/firestoreMain.dart';
import 'package:flutter_with_firebase/Scoped/userModel.dart';
import 'package:flutter_with_firebase/SideDrawerItems/homepageDrawer.dart';
import 'package:flutter_with_firebase/Homepage/generalSearchPage.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  static final String route = 'HomePage';
  HomePage();
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  TextEditingController search = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirestoreMain g = new FirestoreMain();

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
          return HomepageDrawer(model.email);
        },
      ),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => _scaffoldKey.currentState.openDrawer(),
          child: Container(
            width: 40,
            child: ScopedModelDescendant<UserModel>(
                builder: (context, child, model) {
              return g.getUserProfileImage(model.email, 25);
            }),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[300],
        title: Text('Your Conversations',
            style: TextStyle(color: Colors.grey[850])),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return GeneralSearchPage();
                  },
                ),
              );
            },
            icon: Icon(
              Icons.search,
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
        child: ScopedModelDescendant<UserModel>(
          builder: (context, child, model) {
            return g.showConversations(model.email);
          },
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScopedModelDescendant<UserModel>(
          builder: (context, child, model) {
            return StartANewConversationDialog(model.email);
          },
        );
      },
    );
  }
}
