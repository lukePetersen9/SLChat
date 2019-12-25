import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/HelperClass/dateTimeFormat.dart';
import 'GeneralMessageWithInteractionsForCurrentUser.dart';
import 'GeneralMessageWithInteractionsForOtherUser.dart';
import 'package:flutter_with_firebase/Firestore/firestoreMain.dart';

class ConversationPage extends StatefulWidget {
  final List<dynamic> members;
  final String currentUserEmail;
  final String docID;
  ConversationPage(this.currentUserEmail, this.docID, this.members);

  @override
  State<StatefulWidget> createState() {
    return ConversationPageState();
  }
}

class ConversationPageState extends State<ConversationPage> {
  ScrollController scrollController = new ScrollController();
  TextEditingController msgController = new TextEditingController();
  final databaseReference = Firestore.instance;
  DateTimeFormat dateTimeFormat = new DateTimeFormat();
  FirestoreMain fire = new FirestoreMain();
  bool showTime = false, interactWithMessage = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        leading: FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.back,
            color: Color.fromRGBO(43, 158, 179, 1),
          ),
        ),
        backgroundColor: Colors.grey[100],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                children: <Widget>[
                  fire.displayProfileImages(widget.members),
                  SizedBox(
                    width: 7,
                  ),
                  fire.getUsersInGroup(widget.currentUserEmail, widget.members,
                      TextStyle(color: Colors.grey[850]))
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              flex: MediaQuery.of(context).viewInsets.bottom == 0 ? 8 : 5,
              child: displayMessages(widget.docID),
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
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: Color.fromRGBO(43, 158, 179, 1)),
                        ),
                        child: TextField(
                          cursorColor: Color.fromRGBO(43, 158, 179, 1),
                          style: TextStyle(
                              fontSize: 22,
                              fontFamily: 'Garamond',
                              color: Colors.grey[850]),
                          controller: msgController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration.collapsed(
                            hintStyle: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Garamond',
                                color: Colors.grey[400]),
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
                          Icons.send,
                          color: Color.fromRGBO(43, 158, 179, 1),
                          size: 35,
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
    );
  }

  Widget displayMessages(String docID) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('conversations')
          .document(docID)
          .collection('messages')
          .snapshots(),
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
            List<Widget> messages = new List<Widget>();
            bool foundLast = false;
            for (int i = snapshot.data.documents.length - 1; i > -1; i--) {
              bool delete = snapshot.data.documents[i].data['interactions']
                  .contains(widget.currentUserEmail + '@delete');
              Widget singleMessage = getTextMessage(
                  snapshot.data.documents[i], !foundLast && !delete);
              if (!foundLast) {
                foundLast = !foundLast && !delete;
              }
              if (!delete) {
                messages.add(singleMessage);
              }
            }
            messages = messages.reversed.toList();
            return SingleChildScrollView(
              controller: scrollController,
              reverse: true,
              child: Column(
                children: messages,
              ),
            );
          default:
            return Text('error');
        }
      },
    );
  }

  Widget getTextMessage(DocumentSnapshot d, bool isLast) {
    List<dynamic> readList = d.data['readBy'];
    bool alreadyRead = false;
    for (String s in readList) {
      if (s.contains(widget.currentUserEmail)) {
        alreadyRead = true;
      }
    }
    if (!alreadyRead) {
      try {
        Firestore.instance
            .collection("conversations")
            .document(widget.docID)
            .collection('messages')
            .document(d.documentID)
            .updateData(
          {
            'readBy': FieldValue.arrayUnion(
              [widget.currentUserEmail + '@' + DateTime.now().toString()],
            ),
          },
        );
      } catch (e) {}
      try {
        Firestore.instance
            .collection("conversations")
            .document(widget.docID)
            .updateData(
          {
            'readBy': FieldValue.arrayUnion(
              [widget.currentUserEmail],
            ),
          },
        );
      } catch (e) {}
    }
    String readDelivered = readList.length > 1
        ? 'read ' +
            dateTimeFormat.getDisplayDateText(
                DateTime.parse(readList[1]
                    .toString()
                    .substring(readList[1].toString().lastIndexOf('@') + 1)),
                DateTime.now())
        : 'delivered';
    if (d.data['sentBy'] == widget.currentUserEmail) {
      return GeneralMessageWithInteractionsForCurrentUser(
          d.data['content'],
          d.documentID,
          d.data['interactions'],
          widget.currentUserEmail,
          isLast,
          readDelivered,
          widget.docID);
    } else {
      return GeneralMessageWithInteractionsForOtherUser(
          d.data['content'],
          d.data['sentBy'],
          widget.currentUserEmail,
          d.documentID,
          d.data['interactions'],
          widget.docID);
    }
  }

  void addToMessages(String value) async {
    var now = new DateTime.now();
    try {
      databaseReference
          .collection("conversations")
          .document(widget.docID)
          .collection('messages')
          .document(now.toString())
          .setData(
        {
          'content': value,
          'sentBy': widget.currentUserEmail,
          'readBy': [widget.currentUserEmail],
          'interactions': ['init'],
        },
      );
    } catch (e) {}
    try {
      databaseReference
          .collection("conversations")
          .document(widget.docID)
          .updateData(
        {
          'readBy': FieldValue.arrayRemove(widget.members),
          'lastMessage': value,
          'lastMessageTime': now.toString(),
        },
      );
    } catch (e) {}
  }
}
