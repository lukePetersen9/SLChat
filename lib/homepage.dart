import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'GeneralMessageWithInteractionsForCurrentUser.dart';
import 'GeneralMessageWithInteractionsForOtherUser.dart';

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
  String otherUserActive = 'false';
  bool showTime = false, interactWithMessage = false;
  Map<String, String> interactions = new Map<String, String>();
  var a;
  var b;
  String otherUserProfilePicture =
      'https://icon-library.net/images/no-profile-picture-icon-female/no-profile-picture-icon-female-0.jpg';
  String currentUserProfilePicture =
      'https://icon-library.net/images/no-profile-picture-icon-female/no-profile-picture-icon-female-0.jpg';

  @override
  void initState() {
    super.initState();
    getUserImageData(widget.userName);
    getUserImageData(widget.otherUser);
    
  }

  @override
  void dispose(){
    updateLastActiveTime(false, firstUser, secondUser, widget.userName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    interactions[currentUserProfilePicture] = 'like';
    interactions[otherUserProfilePicture] = 'favorite';

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () {},
          )
        ],
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(otherUserProfilePicture),
            ),
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                widget.otherUser,
                style: TextStyle(fontSize: 25, fontFamily: 'Garamond'),
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
    updateLastActiveTime(true, firstUser, secondUser, widget.userName);
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
            if (!isNew) {
              DocumentSnapshot s = snapshot.data.documents.where(
                (DocumentSnapshot d) {
                  return d.documentID == firstUser + ' ' + secondUser;
                },
              ).first;
              List<dynamic> i = s.data['allTexts'];
              otherUserActive = s.data['readAt'];
              return SingleChildScrollView(
                controller: scrollController,
                reverse: true,
                child: getTextMessages(i),
              );
            } else {
              makeNewConversation(
                  widget.userName, widget.otherUser, widget.userName);
            }
            return SingleChildScrollView(
              controller: scrollController,
              reverse: true,
              child: Text(
                'Start a new conversation with ' + widget.otherUser,
                style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Garamond',
                    color: Colors.white60),
              ),
            );
          default:
            return Text('error');
        }
      },
    );
  }

  Widget getTextMessages(List<dynamic> d) {
    Map<String, String> m = new Map<String, String>();
    List<Widget> list = new List<Widget>();
    for (int i = 1; i < d.length - 1; i++) {
      if (d[i]['sender'] == widget.userName) {
        list.add(
          GeneralMessageWithInteractionsForCurrentUser(
            d[i]['content'],
            widget.userName,
            d[i]['sent'],
            m,
            currentUserProfilePicture,
            false,
            otherUserActive == 'false'
                ? 'delivered'
                : 'Read ' +
                    (getDisplayDateText(
                      DateTime.parse(otherUserActive),
                      DateTime.now(),
                    ).replaceAll('Today', '')),
          ),
        );
      } else {
        list.add(
          GeneralMessageWithInteractionsForOtherUser(
              d[i]['content'],
              d[i]['sender'],
              d[i]['sent'],
              interactions,
              otherUserProfilePicture,
              false,
              ''),
        );
      }
    }
    if (d[d.length - 1]['sender'] != widget.userName &&
        otherUserActive == 'false' &&
        d.length > 1) {
      sendReadRecipt(d);
      list.add(
        GeneralMessageWithInteractionsForOtherUser(
            d[d.length - 1]['content'],
            d[d.length - 1]['sender'],
            d[d.length - 1]['sent'],
            interactions,
            otherUserProfilePicture,
            false,
            ''),
      );
    } else if (d[d.length - 1]['sender'] == widget.userName && d.length > 1) {
      list.add(
        GeneralMessageWithInteractionsForCurrentUser(
          d[d.length - 1]['content'],
          widget.userName,
          d[d.length - 1]['sent'],
          interactions,
          currentUserProfilePicture,
          true,
          otherUserActive == 'false'
              ? 'delivered'
              : 'Read ' +
                  (getDisplayDateText(
                    DateTime.parse(otherUserActive),
                    DateTime.now(),
                  ).replaceAll('Today', '')),
        ),
      );
    } else if (d.length > 1) {
      list.add(
        GeneralMessageWithInteractionsForOtherUser(
            d[d.length - 1]['content'],
            d[d.length - 1]['sender'],
            d[d.length - 1]['sent'],
            interactions,
            otherUserProfilePicture,
            false,
            ''),
      );
    }
    if (list.length == 0) {
      return Column(
        children: <Widget>[
          Text(
            'Start a conversation with ' + widget.otherUser,
            style: TextStyle(
                fontSize: 22, fontFamily: 'Garamond', color: Colors.white60),
          ),
        ],
      );
    }
    return Column(children: list);
  }

  void sendReadRecipt(List<dynamic> d) {
    DateTime now = DateTime.now();
    try {
      databaseReference
          .collection('conversations')
          .document(firstUser + ' ' + secondUser)
          .updateData(
        {
          'readAt': now.toString(),
        },
      );
    } catch (e) {
      print(e.toString());
    }
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

  void updateLastActiveTime(
      bool isActive, String first, String second, String user) async {
    var now = new DateTime.now();
    try {
      databaseReference
          .collection("conversations")
          .document(first + ' ' + second)
          .updateData(
        {
          user + 'IsActive': isActive.toString(),
        },
      );
    } catch (e) {}
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
          'readAt': 'false',
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
        'readAt': 'false',
        'allTexts': [
          {
            'content': 'initialization',
            'sender': widget.userName,
            'sent': now.toString(),
          }
        ],
      },
    );
  }

  void getUserImageData(String username) {
    if (username == widget.otherUser) {
      a = Firestore.instance
          .collection('users')
          .document(widget.otherUser)
          .get()
          .then(
        (DocumentSnapshot snap) {
          otherUserProfilePicture = snap.data['profile_image'];
          setState(() {});
        },
      );
    } else {
      b = Firestore.instance
          .collection('users')
          .document(widget.userName)
          .get()
          .then(
        (DocumentSnapshot snap) {
          currentUserProfilePicture = snap.data['profile_image'];
          setState(() {});
        },
      );
    }
  }

  String getDisplayDateText(DateTime sent, DateTime now) {
    if (now.difference(sent).inHours < 24) {
      return (sent.hour % 12 == 0 ? '12' : (sent.hour % 12).toString()) +
          ':' +
          (sent.minute < 10
              ? '0' + sent.minute.toString()
              : sent.minute.toString()) +
          (sent.hour > 11 && sent.hour < 23 ? ' pm' : ' am');
    } else if (now.difference(sent).inDays < 7) {
      return sent.weekday.toString() +
          ' ' +
          (sent.hour % 12 == 0 ? '12' : (sent.hour % 12).toString()) +
          ':' +
          (sent.minute < 10
              ? '0' + sent.minute.toString()
              : sent.minute.toString()) +
          (sent.hour > 11 && sent.hour < 23 ? ' pm' : ' am');
    } else {
      return monthAbreviation(sent.month) +
          ' ' +
          sent.day.toString() +
          ', ' +
          (sent.hour % 12 == 0 ? '12' : (sent.hour % 12).toString()) +
          ':' +
          (sent.minute < 10
              ? '0' + sent.minute.toString()
              : sent.minute.toString());
    }
  }

  String monthAbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sept';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return 'idk';
    }
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
