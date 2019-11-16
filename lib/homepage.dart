import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  var a;
  var b;
  String otherUserProfilePicture = '';
  String currentUserProfilePicture = '';

  @override
  void initState() {
    super.initState();
    getUserImageData(widget.userName);
    getUserImageData(widget.otherUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  style: TextStyle(fontSize: 30, fontFamily: 'Garamond'),
                ),
              ),
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

            if (!isNew) {
              DocumentSnapshot s = snapshot.data.documents.where(
                (DocumentSnapshot d) {
                  return d.documentID == firstUser + ' ' + secondUser;
                },
              ).first;

              List<dynamic> i = s.data['allTexts'];

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
      list.add(singleMessage(d[i]['content'], d[i]['sender'], d[i]['sent'],
          widget.userName, MediaQuery.of(context).size.width));
    }
    if (list.length == 0) {
      return Column(
        children: <Widget>[Text('Start a conversation')],
      );
    }
    return Column(children: list);
  }

  Widget singleMessage(String text, String sender, String time,
      String currentUser, double width) {
    var dateTime = DateTime.parse(time);
    var now = DateTime.now();
    String displayDate = getDisplayDateText(dateTime, now);

    if (sender == widget.otherUser) {
      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actions: <Widget>[
          Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  displayDate,
                  style: TextStyle(fontSize: 12, fontFamily: 'Garamond'),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  padding: EdgeInsets.symmetric(vertical: 1),
                  iconSize: 35,
                  onPressed: () {
                    print('do more');
                  },
                  icon: Icon(Icons.more_horiz),
                ),
              ),
            ],
          )
        ],
        child: Padding(
          padding: EdgeInsets.all(3),
          child: Align(
              alignment: currentUser == sender
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: widget.otherUser == sender
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: <Widget>[
                  profileImage(sender),
                  Container(
                    constraints:
                        BoxConstraints(minWidth: 20, maxWidth: width * .7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: currentUser == sender
                          ? Colors.blue[100]
                          : Colors.amber[100],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 22, fontFamily: 'Garamond'),
                    ),
                  )
                ],
              )),
        ),
      );
    } else {
      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  displayDate,
                  style: TextStyle(fontSize: 12, fontFamily: 'Garamond'),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  padding: EdgeInsets.symmetric(vertical: 1),
                  iconSize: 35,
                  onPressed: () {
                    print('do more');
                  },
                  icon: Icon(Icons.more_horiz),
                ),
              ),
            ],
          )
        ],
        child: Padding(
          padding: EdgeInsets.all(3),
          child: Align(
              alignment: currentUser == sender
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: widget.otherUser == sender
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    constraints:
                        BoxConstraints(minWidth: 20, maxWidth: width * .7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: currentUser == sender
                          ? Colors.blue[100]
                          : Colors.amber[100],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 22, fontFamily: 'Garamond'),
                    ),
                  ),
                  profileImage(sender),
                ],
              )),
        ),
      );
    }
  }

  Widget profileImage(String sender) {
    if (sender == widget.otherUser) {
      return Container(
        padding: EdgeInsets.all(5),
        child: CircleAvatar(
          radius: 15,
          backgroundImage: NetworkImage(otherUserProfilePicture),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(5),
        child: CircleAvatar(
          radius: 15,
          backgroundImage: NetworkImage(currentUserProfilePicture),
        ),
      );
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
          {'first': 'message'}
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
      return 'Today ' +
          (sent.hour % 12 == 0 ? '12' : (sent.hour % 12).toString()) +
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
