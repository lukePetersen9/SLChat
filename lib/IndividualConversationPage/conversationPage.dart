import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/HelperClass/dateTimeFormat.dart';
import 'package:flutter_with_firebase/IndividualConversationPage/textMessage.dart';
import '../Scoped/userModel.dart';
import '../Scoped/userModel.dart';
import '../Scoped/userModel.dart';
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
  Map<dynamic, UserModel> userMap = new Map<dynamic, UserModel>();
  int numMessages;

  @override
  void initState() {
    scrollController.addListener(_scrollListener);
    numMessages = 30;
    for (String e in widget.members) {
      userMap[e] = UserModel.simple();
      UserModel.simple().getSimpleUserModel(e).then(
        (data) {
          userMap[e] = data;
          setState(() {});
        },
      );
    }
    userMap[widget.currentUserEmail] = UserModel.simple();
    UserModel.simple().getSimpleUserModel(widget.currentUserEmail).then(
      (data) {
        userMap[widget.currentUserEmail] = data;
        setState(() {});
      },
    );

    super.initState();
  }

  _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        numMessages += 30;
      });
    }
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
            displayProfileImages(),
            Text(
              namesInGroup(),
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Garamond',
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
      body: Flex(
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
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border:
                            Border.all(color: Color.fromRGBO(43, 158, 179, 1)),
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
    );
  }

  String namesInGroup() {
    List<String> names = new List<String>();
    for (String e in widget.members) {
      names.add(
        userMap[e].firstName +
            ' ' +
            (userMap[e].lastName.isNotEmpty
                ? userMap[e].lastName.toString().substring(0, 1) + '.'
                : ''),
      );
    }
    String formattedNames = "";
    for (int i = 0; i < names.length - 2; i++) {
      formattedNames += names[i] + ', ';
    }
    if (names.length > 2) {
      formattedNames +=
          names[names.length - 2] + ' & ' + names[names.length - 1];
    } else if (names.length == 2) {
      formattedNames += names[0] + ' & ' + names[1];
    } else {
      formattedNames = names[0];
    }
    if (formattedNames.length > 30) {
      formattedNames = formattedNames.substring(0, 27) + '...';
    }
    return formattedNames;
  }

  Widget displayProfileImages() {
    List<Widget> images = new List<Widget>();
    images.add(
      Container(
        width: 1,
        height: 1,
      ),
    );
    for (int i = 0;
        i < (widget.members.length > 4 ? 5 : widget.members.length);
        i++) {
      UserModel user = userMap[widget.members.elementAt(i)];
      images.add(
        Positioned(
          left: i * 25.0,
          child: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(user.profileImage),
          ),
        ),
      );
    }
    return Container(
      width: 25.0 * images.length + 5,
      child: Stack(
          overflow: Overflow.visible,
          alignment: Alignment.centerLeft,
          children: images),
    );
  }

  Widget displayMessages(String docID) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('conversations')
          .document(docID)
          .collection('messages')
          .orderBy('sentAt', descending: true)
          .limit(numMessages)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: ListView(
              children: <Widget>[
                Text('Send a message!'),
              ],
            ),
          );
        }
        print(snapshot.data.documents.length);
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10),
          controller: scrollController,
          reverse: true,
          itemBuilder: (context, index) {
            if (snapshot.data.documents[index]['sentBy'] !=
                widget.currentUserEmail) {
              bool alreadyRead = false;
              for (String s in snapshot.data.documents[index]['readBy']) {
                if (s.contains(widget.currentUserEmail)) {
                  alreadyRead = true;
                }
              }
              if (!alreadyRead) {
                try {
                  Firestore.instance
                      .document(snapshot.data.documents[index].reference.path)
                      .updateData(
                    {
                      'readBy': FieldValue.arrayUnion(
                        [
                          widget.currentUserEmail +
                              '@' +
                              DateTime.now().toString()
                        ],
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
            }
            return TextMessage(
                widget.currentUserEmail,
                snapshot.data.documents[index],
                widget.docID,
                snapshot.data.documents[index].documentID,
                userMap);
          },
          itemCount: snapshot.data.documents.length,
          scrollDirection: Axis.vertical,
        );
      },
    );
  }

  void addToMessages(String value) async {
    var now = new DateTime.now();
    msgController.clear();
    try {
      databaseReference
          .collection("conversations")
          .document(widget.docID)
          .collection('messages')
          .document()
          .setData(
        {
          'sentAt': now.toString(),
          'content': value,
          'sentBy': widget.currentUserEmail,
          'readBy': [widget.currentUserEmail],
          'interactions': [],
        },
      );
      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } catch (e) {
      print(e);
    }
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
