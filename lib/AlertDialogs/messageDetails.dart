import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Firestore/firestoreMain.dart';
import '../HelperClass/dateTimeFormat.dart';
import 'package:flutter_with_firebase/Scoped/userModel.dart';
import '../Scoped/userModel.dart';
import 'deleteDialogConfirmation.dart';

class MessageDetailsDialog extends StatefulWidget {
  final DocumentSnapshot messageData;
  final String currentUserEmail;
  final Map<dynamic, UserModel> userMap;

  MessageDetailsDialog(
    this.currentUserEmail,
    this.messageData,
    this.userMap,
  );
  @override
  State<StatefulWidget> createState() {
    return MessageDetailsDialogState();
  }
}

class MessageDetailsDialogState extends State<MessageDetailsDialog>
    with TickerProviderStateMixin {
  StreamSubscription<DocumentSnapshot> s;
  DateTimeFormat timeFormat = new DateTimeFormat();
  FirestoreMain fire = new FirestoreMain();
  List<dynamic> interactions;
  List<dynamic> readBy;
  AnimationController favoriteController;
  AnimationController likeController;
  AnimationController dislikeController;
  Animation _favTween;
  Animation _likeTween;
  Animation _dislikeTween;
  @override
  void initState() {
    readBy = List.from(widget.messageData['readBy']);
    interactions = List.from(widget.messageData.data['interactions']);
    favoriteController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _favTween = ColorTween(
      begin: Color.fromRGBO(43, 158, 179, .6),
      end: Colors.red[200],
    ).animate(favoriteController);
    likeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _likeTween = ColorTween(
      begin: Color.fromRGBO(43, 158, 179, .6),
      end: Colors.green[200],
    ).animate(likeController);
    dislikeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _dislikeTween = ColorTween(
      begin: Color.fromRGBO(43, 158, 179, .6),
      end: Colors.orange[200],
    ).animate(dislikeController);
    if (interactions.contains(widget.currentUserEmail + '@favorite')) {
      favoriteController.forward();
    }
    if (interactions.contains(widget.currentUserEmail + '@like')) {
      likeController.forward();
    }
    if (interactions.contains(widget.currentUserEmail + '@dislike')) {
      dislikeController.forward();
    }
    s = Firestore.instance
        .document(widget.messageData.reference.path)
        .snapshots()
        .listen(
      (data) {
        if (this.mounted) {
          setState(
            () {
              interactions = data.data['interactions'];
              readBy = data.data['readBy'];
            },
          );
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    s.cancel();
    favoriteController.dispose();
    likeController.dispose();
    dislikeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.only(top: 20, left: 15, right: 15),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.grey[100],
      title: Text(
        widget.messageData['content'],
        style: TextStyle(
          fontSize: 30,
          fontFamily: 'Garamond',
          color: Color.fromRGBO(43, 158, 179, 1),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Text(
              'sent ' +
                  timeFormat.getDisplayDateText(
                    DateTime.parse(widget.messageData['sentAt']),
                    DateTime.now(),
                  ),
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'Garamond',
                color: Color.fromRGBO(43, 158, 179, .8),
              ),
            ),
          ),
          Text(
            'Sent by: ',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Garamond',
              color: Color.fromRGBO(43, 158, 179, 1),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget
                          .userMap[widget.messageData['sentBy']].profileImage),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                widget.userMap[widget.messageData['sentBy']]
                                        .firstName +
                                    ' ' +
                                    widget.userMap[widget.messageData['sentBy']]
                                        .lastName +
                                    ' ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Garamond',
                                  color: Color.fromRGBO(43, 158, 179, 1),
                                ),
                              ),
                              Icon(
                                widget.userMap[widget.messageData['sentBy']]
                                        .isPrivate
                                    ? Icons.lock
                                    : Icons.lock_open,
                                color: widget
                                        .userMap[widget.messageData['sentBy']]
                                        .isPrivate
                                    ? Color.fromRGBO(43, 158, 179, .5)
                                    : Colors.transparent,
                                size: 15,
                              ),
                            ],
                          ),
                          Text(
                            '    ' +
                                widget.userMap[widget.messageData['sentBy']]
                                    .username,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Garamond',
                              color: Color.fromRGBO(43, 158, 179, .5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                widget.userMap[widget.messageData['sentBy']].followers
                        .contains(widget.currentUserEmail)
                    ? widget.userMap[widget.messageData['sentBy']].following
                            .contains(widget.currentUserEmail)
                        ? Text(
                            'follows you',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Garamond',
                              color: Color.fromRGBO(43, 158, 179, .7),
                            ),
                          )
                        : Container()
                    : widget.currentUserEmail ==
                            widget.userMap[widget.messageData['sentBy']].email
                        ? Container()
                        : GestureDetector(
                            child: Container(
                              child: Icon(Icons.add),
                            ),
                          ),
              ],
            ),
          ),
          widget.messageData['readBy'].length == 0
              ? Container(
                  child: Text(
                    'No one has seen this message yet',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Garamond',
                      color: Color.fromRGBO(43, 158, 179, 1),
                    ),
                  ),
                )
              : Text(
                  'Read by: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Garamond',
                    color: Color.fromRGBO(43, 158, 179, 1),
                  ),
                ),
          Column(
            children: displayItems(),
          ),
          Text(
            'Interactions:',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Garamond',
              color: Color.fromRGBO(43, 158, 179, 1),
            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: 100, maxHeight: 200),
            width: MediaQuery.of(context).size.width * .8,
            height: MediaQuery.of(context).size.height * .15,
            child: GridView.builder(
                itemCount: interactions.length,
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                itemBuilder: (BuildContext context, int index) {
                  String email = interactions[index].toString().substring(
                      0, interactions[index].toString().lastIndexOf('@'));
                  return Padding(
                    padding: EdgeInsets.all(3),
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topCenter,
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                                widget.userMap[email].profileImage),
                          ),
                        ),
                        Align(
                            alignment: Alignment.topLeft,
                            child: interactions[index].toString().substring(
                                        interactions[index]
                                                .toString()
                                                .lastIndexOf('@') +
                                            1) ==
                                    'favorite'
                                ? Icon(
                                    Icons.favorite,
                                    size: 25,
                                    color: Colors.red[200],
                                  )
                                : interactions[index].toString().substring(
                                            interactions[index]
                                                    .toString()
                                                    .lastIndexOf('@') +
                                                1) ==
                                        'like'
                                    ? Icon(
                                        Icons.thumb_up,
                                        size: 25,
                                        color: Colors.green[200],
                                      )
                                    : Icon(
                                        Icons.thumb_down,
                                        size: 25,
                                        color: Colors.orange[200],
                                      )),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            widget.userMap[email].firstName.length > 12
                                ? widget.userMap[email].firstName
                                        .substring(0, 12) +
                                    '...'
                                : widget.userMap[email].firstName,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Garamond',
                              color: Color.fromRGBO(43, 158, 179, 1),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
      actions: <Widget>[
        interactionButton('favorite'),
        interactionButton('like'),
        interactionButton('dislike'),
        IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            showDeleteDialog();
          },
          icon: Icon(
            Icons.delete,
            color: Color.fromRGBO(43, 158, 179, .6),
          ),
        ),
        new FlatButton(
          child: new Text(
            'close',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Garamond',
              color: Color.fromRGBO(43, 158, 179, .8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
            widget.currentUserEmail, widget.messageData.reference.path);
      },
    ).whenComplete(
      () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget interactionButton(String type) {
    return AnimatedBuilder(
      animation: type == 'favorite'
          ? favoriteController
          : type == 'like' ? likeController : dislikeController,
      builder: (context, w) {
        return IconButton(
          icon: Icon(
            type == 'favorite'
                ? Icons.favorite
                : type == 'like' ? Icons.thumb_up : Icons.thumb_down,
            color: type == 'favorite'
                ? _favTween.value
                : type == 'like' ? _likeTween.value : _dislikeTween.value,
          ),
          onPressed: () {
            if (interactions.contains(widget.currentUserEmail + '@' + type)) {
              fire
                  .removeInteraction(type, widget.currentUserEmail,
                      widget.messageData.reference.path)
                  .then(
                (data) {
                  switch (type) {
                    case 'favorite':
                      favoriteController.reverse();
                      break;
                    case 'like':
                      likeController.reverse();
                      break;
                    case 'dislike':
                      dislikeController.reverse();
                      break;
                    default:
                      break;
                  }
                },
              );
            } else {
              fire
                  .addInteraction(type, widget.currentUserEmail,
                      widget.messageData.reference.path)
                  .then(
                (data) {
                  switch (type) {
                    case 'favorite':
                      favoriteController.forward();
                      break;
                    case 'like':
                      likeController.forward();
                      break;
                    case 'dislike':
                      dislikeController.forward();
                      break;
                    default:
                      break;
                  }
                },
              );
            }
          },
        );
      },
    );
  }

  List<Widget> displayItems() {
    List<Widget> i = new List<Widget>();

    for (String e in readBy.sublist(1)) {
      i.add(displayItem(e));
    }
    return i;
  }

  Widget displayItem(String eAndT) {
    String e = eAndT.substring(0, eAndT.lastIndexOf('@'));
    String time = eAndT.substring(eAndT.lastIndexOf('@') + 1);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.userMap[e].profileImage),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          widget.userMap[e].firstName +
                              ' ' +
                              widget.userMap[e].lastName,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Garamond',
                            color: Color.fromRGBO(43, 158, 179, 1),
                          ),
                        ),
                        Icon(
                          widget.userMap[e].isPrivate
                              ? Icons.lock
                              : Icons.lock_open,
                          color: widget.userMap[e].isPrivate
                              ? Color.fromRGBO(43, 158, 179, .5)
                              : Colors.transparent,
                          size: 15,
                        ),
                      ],
                    ),
                    Text(
                      '    ' + widget.userMap[e].username,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Garamond',
                        color: Color.fromRGBO(43, 158, 179, .5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Text(
                timeFormat.getDisplayDateText(
                      DateTime.parse(time),
                      DateTime.now(),
                    ) +
                    ' ',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Garamond',
                  color: Color.fromRGBO(43, 158, 179, 1),
                ),
              ),
              widget.userMap[e].followers.contains(widget.currentUserEmail)
                  ? widget.userMap[e].following
                          .contains(widget.currentUserEmail)
                      ? Text(
                          'follows you',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Garamond',
                            color: Color.fromRGBO(43, 158, 179, .7),
                          ),
                        )
                      : Container()
                  : widget.currentUserEmail == e
                      ? Container()
                      : GestureDetector(
                          child: Container(
                            child: Icon(Icons.add),
                          ),
                        ),
            ],
          ),
        ],
      ),
    );
  }
}
