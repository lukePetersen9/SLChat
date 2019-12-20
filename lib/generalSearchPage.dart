import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'conversationPage.dart';
import 'firestoreMain.dart';

class GeneralSearchPage extends StatefulWidget {
  final String userEmail;
  GeneralSearchPage(this.userEmail);
  @override
  State<StatefulWidget> createState() {
    return GeneralSearchPageState();
  }
}

class GeneralSearchPageState extends State<GeneralSearchPage> {
  FirestoreMain fire = new FirestoreMain();
  final databaseReference = Firestore.instance;
  String searchText = "";
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'All Users',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Garamond',
                      color: Colors.white54),
                ),
              ),
              Tab(
                child: Text(
                  'Followers',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Garamond',
                      color: Colors.white54),
                ),
              ),
              Tab(
                child: Text(
                  'Following',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Garamond',
                      color: Colors.white54),
                ),
              ),
            ],
          ),
          title: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              cursorColor: Colors.white38,
              decoration: InputDecoration.collapsed(
                hintText: 'Search...',
                hintStyle: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Garamond',
                    color: Colors.white54),
              ),
              style: TextStyle(
                  fontSize: 22, fontFamily: 'Garamond', color: Colors.white54),
              onChanged: (change) {
                setState(() {
                  searchText = change;
                });
              },
            ),
          ),
        ),
        body: TabBarView(
          children: [
            displaySearch(searchText),
            Icon(Icons.directions_transit),
            Icon(Icons.directions_bike),
          ],
        ),
      ),
    );
  }

  Widget displaySearch(String s) {
    List<String> searchResults = new List<String>();
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return new Text('${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            if (!snapshot.hasData) return Text('No data found!');

            for (DocumentSnapshot d in snapshot.data.documents) {
              if (d.documentID.contains(s)) {
                searchResults.add(d.documentID);
              }
            }
            List<Widget> searchResultTextBox = new List<Widget>();
            for (String name in searchResults) {
              searchResultTextBox.add(fire.getUserNameAndUsernameCurrentUser(
                  name, MediaQuery.of(context).size.width, 100));
            }

            return SingleChildScrollView(
              child: Column(
                children: searchResultTextBox,
              ),
            );

          default:
            return Text('error');
        }
      },
    );
  }
}
