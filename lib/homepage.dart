import 'package:flutter/material.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  final String userName;
  HomePage(this.userName);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  ScrollController scrollController = new ScrollController();
  TextEditingController msgController = new TextEditingController();

  final databaseReference = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SLChat"),
      ),
      body: displayMessages(),
    );
  }

  Widget displayMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("users").snapshots(),
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
            if (!snapshot.hasData) return Text('No data finded!');
            return Card(
              child: SingleChildScrollView(
                child: Column(
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                  return new Text(document['name']);
                }).toList()),
              ),
            );
          default:
            return Text('error');
        }
      },
    );
  }

  void updateData() {
    try {
      databaseReference
          .collection('books')
          .document('1')
          .updateData({'description': 'Head First Flutter'});
    } catch (e) {
      print(e.toString());
    }
  }

  void deleteData() {
    try {
      databaseReference.collection('books').document('1').delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<String>> getSomeData() async {
    List<String> list = new List<String>();
    databaseReference
        .collection("users")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => list.add(f.data['name']));
    });
    return list;
  }

  void addToMessages() async {
    if (msgController.text != null && msgController.text != '') {
      var now = new DateTime.now();
      await databaseReference
          .collection("conversations")
          .document(now.toString())
          .setData({
        'content': msgController.text,
        'sender': widget.userName,
        'sent': now.toString(),
      });
    }

    msgController.clear();
  }
}

class Message {
  String text, from, date;
  Message(this.text, this.from, this.date);
}
