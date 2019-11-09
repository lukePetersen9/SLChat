
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
  List<Message> messages = new List<Message>();
  TextEditingController msgController = new TextEditingController();

  final databaseReference = Firestore.instance;

  @override
  void initState() {
    super.initState();
    CollectionReference reference =
        Firestore.instance.collection('conversations');
    reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        if (!(change.document.data['sender'] == (widget.userName))) {
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(messages.length);
    print(databaseReference.collection('users').document('df'));
    return Scaffold(
        appBar: AppBar(
          title: Text('SL Chat'),
        ),
        body: Flex(
          children: <Widget>[
            Expanded(
              child: FutureBuilder(
                future: databaseReference
                    .collection('conversations').orderBy('sent',descending: true)
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
                child: TextField(
                  controller: msgController,
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: FloatingActionButton(
                  onPressed: () {
                    addToMessages();
                    setState(() {});
                  },
                  child: Icon(Icons.send),
                  backgroundColor: const Color(0xff937acc),
                ),
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
      reverse: true,
      // controller: scrollController,
      itemCount: texts.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: new Text(texts[index].data['content']),
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
