import 'package:flutter/material.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  final String userName;
  final String otherUser;
  HomePage(this.userName, this.otherUser);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  ScrollController scrollController = new ScrollController();
  TextEditingController msgController = new TextEditingController();
  final databaseReference = Firestore.instance;
  String firstUser = '', secondUser = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userName);
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.black,
          ),
          Text("SL Chat")
        ],
      )),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              flex: MediaQuery.of(context).viewInsets.bottom == 0 ? 8 : 5,
              child: displayMessages(),
            ),
            Expanded(
              child: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue[200]),
                        ),
                        child: TextField(
                          cursorColor: Colors.blue[200],
                          style:
                              TextStyle(fontSize: 22, fontFamily: 'Garamond'),
                          controller: msgController,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration.collapsed(
                            hintStyle:
                                TextStyle(fontSize: 22, fontFamily: 'Garamond'),
                            hintText: 'your message...',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: Icon(
                          Icons.blur_circular,
                          color: Colors.blue,
                          size: 40,
                        ),
                        onPressed: () {
                          if (msgController.text != null &&
                              msgController.text != "") {
                            addToMessages(msgController.text, firstUser,
                                secondUser, widget.userName);
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
    );
  }

  Widget displayMessages() {
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
            bool isNew = true;

            for (DocumentSnapshot d in snapshot.data.documents) {
              if (d.documentID.contains(widget.userName) &&
                  d.documentID.contains(widget.otherUser) &&
                  d.documentID.length ==
                      widget.otherUser.length + widget.userName.length + 1) {
                firstUser =
                    d.documentID.substring(0, d.documentID.indexOf(' '));
                secondUser =
                    d.documentID.substring(d.documentID.indexOf(' ') + 1);
                isNew = false;
              }
            }
            // print(isNew);
            if (!isNew) {
              DocumentSnapshot s = snapshot.data.documents.where(
                (DocumentSnapshot d) {
                  print(d.documentID);
                  print(firstUser + ' ' + secondUser);
                  return d.documentID == firstUser + ' ' + secondUser;
                },
              ).first;

              List<dynamic> i = s.data['allTexts'];
              print(i);
              return SingleChildScrollView(
                controller: scrollController,
                reverse: true,
                child: getTextMessages(i),
              );
            } else {
              makeNewConversation(firstUser, secondUser, widget.userName);
            }
            return Text('empty');
          default:
            return Text('error');
        }
      },
    );
  }

  Widget getTextMessages(List<dynamic> d) {
    List<Widget> list = new List<Widget>();
    for (var i = 0; i < d.length; i++) {
      list.add(singleMessage(d[i]['content'], d[i]['sender'], d[i]['time'],
          widget.userName, MediaQuery.of(context).size.width));
    }
    if (list.length == 0) {
      return Column(
        children: <Widget>[Text('sag')],
      );
    }
    return new Column(children: list);
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
          constraints: BoxConstraints(minWidth: 20, maxWidth: width * .7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: currentUser == sender ? Colors.blue[100] : Colors.amber[100],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            text,
            style: TextStyle(fontSize: 22, fontFamily: 'Garamond'),
          ),
        ),
      ),
    );
  }

  void updateData() {
    try {
      databaseReference
          .collection('conversations')
          .document(widget.userName + ' ' + widget.otherUser)
          .setData({'shubham24': 'data'});
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

  void addToMessages(
      String value, String first, String second, String user) async {
    var now = new DateTime.now();
    try {
      databaseReference
          .collection("conversations")
          .document(first + ' ' + second)
          .updateData(
        {
          'lastOpen' + user: now.toString(),
          'allTexts': FieldValue.arrayUnion([
            {
              'content': msgController.text,
              'sender': widget.userName,
              'sent': now.toString(),
            }
          ]),
        },
      );
    } catch (e) {}
  }

  void makeNewConversation(String first, String second, String user) async {
    var now = new DateTime.now();
    await databaseReference
        .collection("conversations")
        .document(first + ' ' + second)
        .setData(
      {
        'lastOpen' + user: now.toString(),
        'allTexts': [
          {'hiya': 'buddy'}
        ],
      },
    );
  }
}

class Message {
  String text, from, date;
  Message(this.text, this.from, this.date);
}

/************************************Here is how to do it with a listView.builder 
 * 
ListView.builder(
            reverse: true,
            controller: scrollController,
            itemCount: length,
            itemBuilder: (BuildContext context, int index) {
              return singleMessage(
                  i[length - index - 1]['content'],
                  i[length - index - 1]['sender'],
                  i[length - index - 1]['time'],
                  widget.userName,
                  MediaQuery.of(context).size.width);
            },
          );
 * 
*/
