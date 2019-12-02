import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/dateTimeFormat.dart';
import 'GeneralMessageWithInteractionsForCurrentUser.dart';
import 'GeneralMessageWithInteractionsForOtherUser.dart';
import 'firestoreMain.dart';

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
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
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
                  fire.getUsersInGroup(
                      widget.currentUserEmail, widget.members, TextStyle())
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
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue[200]),
                        ),
                        child: TextField(
                          cursorColor: Colors.blue[200],
                          style: TextStyle(
                              fontSize: 22,
                              fontFamily: 'Garamond',
                              color: Colors.white),
                          controller: msgController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration.collapsed(
                            hintStyle: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Garamond',
                                color: Colors.white),
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
                          color: Colors.green,
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
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              messages.add(getTextMessage(snapshot.data.documents[i],
                  i == snapshot.data.documents.length - 1));
            }
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
        databaseReference
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
      return GeneralMessageWithInteractionsForOtherUser(d.data['content'],
          d.data['sentBy'], d.documentID, d.data['interactions'],widget.docID);
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
          'lastMessage': value,
          'lastMessageTime': now.toString(),
        },
      );
    } catch (e) {}
  }
}
