import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/conversationPage.dart';
import 'searchDialog.dart';

class HomePage extends StatefulWidget {
  final String email;
  HomePage(this.email);
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final databaseReference = Firestore.instance;
  String searchText = "";
  TextEditingController search = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Conversations'),),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showDialog();
        },
      ),
      body: SingleChildScrollView(
        child: showConversations(widget.email),
      ),
    );
  }

  // user defined function
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SearchDialog(widget.email);
      },
    );
  }

  Widget showConversations(String email) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('conversations').snapshots(),
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
            List<String> searchResults = new List<String>();
            for (DocumentSnapshot d in snapshot.data.documents) {
              //   print(d.documentID);
              if (d.documentID.contains(email)) {
                searchResults.add(d.documentID.replaceFirst(email, '').trim());
              }
            }
            List<Widget> searchResultTextBox = new List<Widget>();
            for (String name in searchResults) {
              print(name);
              searchResultTextBox.add(
                new FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ConversationPage(email, name);
                        },
                      ),
                    );
                  },
                  child: Text(name),
                ),
              );
            }
            print(searchResultTextBox.length);
            return Column(
              children: searchResultTextBox,
            );

          default:
            return Text('error');
        }
      },
    );
  }
}
