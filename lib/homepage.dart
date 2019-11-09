import 'package:flutter/material.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  List<Message> messages;
  final databaseReference = Firestore.instance;

  @override
  void initState() {
    super.initState();
    CollectionReference reference =
        Firestore.instance.collection('conversations');
    reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        setState(() {});
      });
    });
    
  }

  @override
  Widget build(BuildContext context) {
    print(databaseReference.collection('users').document('df'));
    return Scaffold(
        appBar: AppBar(
          title: Text('FireStore Demo'),
        ),
        body: Flex(
          children: <Widget>[
            Expanded(
              child: FutureBuilder(
                future: databaseReference
                    .collection('conversations')
                    .getDocuments(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return new Text('loading...');
                    default:
                      if (snapshot.hasError)
                        return new Text('Error: ${snapshot.error}');
                      else
                        return createListView(context, snapshot);
                  }
                },
              ),
            ),
            Expanded(
              child: Container(
                child: TextField(),
              ),
            )
          ],
          direction: Axis.vertical,
        )
        //center
        );
  }

  void createRecord() async {
    await databaseReference.collection("books").document("1").setData({
      'title': 'Mastering Flutter',
      'description': 'Programming Guide for Dart'
    });

    DocumentReference ref = await databaseReference.collection("books").add({
      'title': 'Flutter in Action',
      'description': 'Complete Programming Guide to learn Flutter'
    });
    print(ref.documentID);
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    QuerySnapshot values = snapshot.data;
    print(values.documents.length);
    List<DocumentSnapshot> texts = new List<DocumentSnapshot>();
    for (DocumentSnapshot s in values.documents) {
      print(s.data['content']);
      texts.add(s);
    }
    return new ListView.builder(
      itemCount: texts.length,
      itemBuilder: (BuildContext context, int index) {
        return new Column(
          children: <Widget>[
            new ListTile(
              title: new Text(texts[index].data['content']),
            ),
            new Divider(
              height: 2.0,
            ),
          ],
        );
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
}

class Message {
  String text, from, date;
  Message(this.text, this.from, this.date);
}
