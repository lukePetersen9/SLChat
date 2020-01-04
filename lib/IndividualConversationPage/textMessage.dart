import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_with_firebase/AlertDialogs/deleteDialogConfirmation.dart';
import 'package:flutter_with_firebase/AlertDialogs/messageDetails.dart';
import 'package:flutter_with_firebase/Firestore/firestoreMain.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_with_firebase/HelperClass/dateTimeFormat.dart';
import '../HelperClass/dateTimeFormat.dart';
import 'package:flutter/services.dart';
import '../Scoped/userModel.dart';

class TextMessage extends StatefulWidget {
  final DocumentSnapshot data;
  final String email, docID, messID;
  final Map<dynamic, UserModel> userMap;
  TextMessage(this.email, this.data, this.docID, this.messID, this.userMap);
  @override
  State<StatefulWidget> createState() {
    return TextMessageState();
  }
}

class TextMessageState extends State<TextMessage>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  AnimationController favoriteController;
  AnimationController likeController;
  AnimationController dislikeController;
  AnimationController _otherAnimationController;
  Animation _otherColorTween;
  Animation _favTween;
  Animation _likeTween;
  Animation _dislikeTween;
  Animation _colorTween;
  FirestoreMain fire = new FirestoreMain();
  DateTimeFormat timeFormat = new DateTimeFormat();
  List<dynamic> interactions;
  bool showTime = false;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _colorTween = ColorTween(
            begin: Colors.transparent, end: Color.fromRGBO(43, 158, 179, .6))
        .animate(_animationController);
    _otherAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _otherColorTween = ColorTween(
            begin: Colors.transparent, end: Color.fromRGBO(240, 198, 20, 1))
        .animate(_otherAnimationController);
    favoriteController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _favTween = ColorTween(
      begin: Color.fromRGBO(43, 158, 179, .6),
      end: Colors.red[200],
    ).animate(favoriteController);
    likeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _likeTween = ColorTween(
      begin: Color.fromRGBO(43, 158, 179, .6),
      end: Colors.green[200],
    ).animate(likeController);
    dislikeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _dislikeTween = ColorTween(
      begin: Color.fromRGBO(43, 158, 179, .6),
      end: Colors.orange[200],
    ).animate(dislikeController);
    super.initState();
  }

  @override
  void dispose() {
    favoriteController.dispose();
    likeController.dispose();
    dislikeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    syncInteractions();
    if (widget.data['interactions'].contains(widget.email + '@delete')) {
      return Container();
    }
    if (widget.data['sentBy'] == widget.email) {
      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: .1,
        secondaryActions: <Widget>[
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
        ],
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            AnimatedBuilder(
              animation: _colorTween,
              builder: (context, child) => Text(
                timeFormat.getDisplayDateText(
                      DateTime.parse(widget.data['sentAt']),
                      DateTime.now(),
                    ) +
                    ' ',
                style: TextStyle(fontSize: 15, color: _colorTween.value),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 3),
              child: GestureDetector(
                onLongPress: () {
                  HapticFeedback.lightImpact();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MessageDetailsDialog(
                          widget.email, widget.data, widget.userMap);
                    },
                  );
                },
                onTap: () {
                  if (_animationController.status ==
                      AnimationStatus.completed) {
                    _animationController.reverse();
                  } else {
                    _animationController.forward();
                  }
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  constraints: BoxConstraints(
                      minWidth: 20,
                      maxWidth: MediaQuery.of(context).size.width * .6),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: widget.data['readBy'] != null &&
                            widget.data['readBy'].length > 1
                        ? Color.fromRGBO(43, 158, 179, 1)
                        : Color.fromRGBO(43, 158, 179, .6),
                  ),
                  child: interactions.length > 0
                      ? Stack(
                          overflow: Overflow.visible,
                          children: <Widget>[
                            Positioned(
                              left: -17,
                              top: -10,
                              child: ClipOval(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    widget.data['interactions'].length
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color.fromRGBO(43, 158, 179, 1),
                                    ),
                                  ),
                                  width: 20,
                                  height: 20,
                                  color: Colors.teal[100],
                                ),
                              ),
                            ),
                            Text(
                              widget.data['content'],
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey[100],
                              ),
                            ),
                          ],
                        )
                      : Text(
                          widget.data['content'],
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.grey[100],
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: ScopedModelDescendant<UserModel>(
                builder: (context, widget, model) {
                  return CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(model.profileImage),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: .1,
        actions: <Widget>[
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
          interactionButton('dislike'),
          interactionButton('like'),
          interactionButton('favorite'),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(
                    widget.userMap[widget.data['sentBy']].profileImage),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 3),
              child: GestureDetector(
                onLongPress: () {
                  HapticFeedback.lightImpact();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MessageDetailsDialog(
                          widget.email, widget.data, widget.userMap);
                    },
                  );
                },
                onTap: () {
                  if (_otherAnimationController.status ==
                      AnimationStatus.completed) {
                    _otherAnimationController.reverse();
                  } else {
                    _otherAnimationController.forward();
                  }
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  constraints: BoxConstraints(
                      minWidth: 20,
                      maxWidth: MediaQuery.of(context).size.width * .6),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color.fromRGBO(240, 198, 20, 1)),
                  child: interactions.length > 0
                      ? Stack(
                          overflow: Overflow.visible,
                          children: <Widget>[
                            Positioned(
                              right: -17,
                              top: -10,
                              child: ClipOval(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    widget.data['interactions'].length
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color.fromRGBO(240, 198, 20, 1),
                                    ),
                                  ),
                                  width: 20,
                                  height: 20,
                                  color: Colors.orange[600],
                                ),
                              ),
                            ),
                            Text(
                              widget.data['content'],
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey[100],
                              ),
                            ),
                          ],
                        )
                      : Text(
                          widget.data['content'],
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.grey[100],
                          ),
                        ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _otherColorTween,
              builder: (context, child) => Text(
                ' ' +
                    timeFormat.getDisplayDateText(
                      DateTime.parse(widget.data['sentAt']),
                      DateTime.now(),
                    ),
                style: TextStyle(fontSize: 15, color: _otherColorTween.value),
              ),
            ),
          ],
        ),
      );
    }
  }

  void syncInteractions() {
    interactions = List.of(widget.data['interactions']);

    if (interactions.contains(widget.email + '@favorite')) {
      if (!favoriteController.isCompleted) {
        favoriteController.forward();
      }
    } else if (favoriteController.isCompleted) {
      favoriteController.reverse();
    }
    if (interactions.contains(widget.email + '@like')) {
      if (!likeController.isCompleted) {
        likeController.forward();
      }
    } else if (likeController.isCompleted) {
      likeController.reverse();
    }
    if (interactions.contains(widget.email + '@dislike')) {
      if (!dislikeController.isCompleted) {
        dislikeController.forward();
      }
    } else if (dislikeController.isCompleted) {
      dislikeController.reverse();
    }
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(widget.email, widget.data.reference.path);
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
            if (interactions.contains(widget.email + '@' + type)) {
              fire
                  .removeInteraction(
                      type, widget.email, widget.data.reference.path)
                  .then(
                (data) {
                  interactions.remove(widget.email + '@' + type);
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
                  setState(() {});
                },
              );
            } else {
              fire
                  .addInteraction(
                      type, widget.email, widget.data.reference.path)
                  .then(
                (data) {
                  interactions.add(widget.email + '@' + type);
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
                  setState(() {});
                },
              );
            }
          },
        );
      },
    );
  }
}
