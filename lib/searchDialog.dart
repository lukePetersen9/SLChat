import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'conversationPage.dart';
import 'firestoreMain.dart';

class SearchDialog extends StatefulWidget {
  final String userEmail;
  SearchDialog(this.userEmail);
  @override
  State<StatefulWidget> createState() {
    return SearchDialogState();
  }
}

class SearchDialogState extends State<SearchDialog> {
  FirestoreMain fire = new FirestoreMain();
  final databaseReference = Firestore.instance;
  String searchText = "";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextField(
        onChanged: (change) {
       //   print(searchText);
          setState(() {
            searchText = change;
          });
        },
      ),
      content: displaySearch(searchText),
      actions: <Widget>[
        new FlatButton(
          child: new Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
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
              searchResultTextBox.add(
                new FlatButton(
                  onPressed: () {
                    List<String> user = new List<String>();
                    user.add(name);
                    fire.makeNewConversation(widget.userEmail, user);
                  },
                  child: Text(name),
                ),
              );
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
