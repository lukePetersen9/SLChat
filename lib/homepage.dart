import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/userSettings.dart';
import 'searchDialog.dart';
import 'firestoreMain.dart';
import 'generalSearchPage.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    FirestoreMain g = new FirestoreMain();
    return Scaffold(
      key: _scaffoldKey,
      drawer: new Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  g.getUserNameAndUsernameCurrentUser(
                      widget.email, MediaQuery.of(context).size.width, 100),
                ],
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(43, 158, 179, 1),
              ),
            ),
            ListTile(
              title: Text('Your Profile'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return UserSettings(widget.email);
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => _scaffoldKey.currentState.openDrawer(),
          child: Container(
            width: 40,
            child: g.getUserProfileImage(widget.email, 25),
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
                    return GeneralSearchPage(widget.email);
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
