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
    print(widget.userName);
    return Scaffold(
      appBar: AppBar(
        title: Text("SLChat"),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: displayMessages(),
              ),
              Expanded(
                child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: TextField(
                          controller: msgController,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration.collapsed(
                            hintText: 'your message...',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: IconButton(
                          icon: Icon(
                            Icons.blur_circular,
                            color: Colors.blue,
                            size: 40,
                          ),
                          onPressed: () {
                            if (msgController.text != null &&
                                msgController.text != "") {
                              addToMessages(msgController.text);
                              setState(() {
                                scrollController.jumpTo(
                                    scrollController.position.maxScrollExtent);
                                msgController.clear();
                              });
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget displayMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("conversations").snapshots(),
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
            return SingleChildScrollView(
              reverse: true,
              controller: scrollController,
              child: Column(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                return singleMessage(
                    document['content'],
                    document['sender'],
                    document['sent'],
                    widget.userName,
                    MediaQuery.of(context).size.width);
              }).toList()),
            );
          default:
            return Text('error');
        }
      },
    );
  }

  Widget singleMessage(String text, String sender, String time,
      String currentUser, double width) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Align(
        alignment: currentUser == sender
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(minWidth: 35, maxWidth: width*6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: currentUser == sender ? Colors.blue[300] : Colors.amber[200],
          ),
          padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: Text(
            text,
            style: TextStyle(fontSize: 30, fontFamily: 'Garamond'),
          ),
        ),
      ),
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

  void addToMessages(String value) async {
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
}

class Message {
  String text, from, date;
  Message(this.text, this.from, this.date);
}
