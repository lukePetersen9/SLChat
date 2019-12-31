import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _colorTween;
  FirestoreMain fire = new FirestoreMain();
  DateTimeFormat timeFormat = new DateTimeFormat();
  bool showTime = false;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _colorTween = ColorTween(
            begin: Colors.transparent, end: Color.fromRGBO(43, 158, 179, .6))
        .animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data['interactions'].contains(widget.email + '@delete')) {
      return Container();
    }
    if (widget.data['sentBy'] == widget.email) {
      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: .1,
        secondaryActions: <Widget>[
          IconButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              fire.addInteraction(
                  'favorite', widget.email, widget.data.reference.path);
            },
            icon: Icon(
              Icons.favorite,
              color: Color.fromRGBO(43, 158, 179, .6),
            ),
          ),
          IconButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              fire.addInteraction(
                  'like', widget.email, widget.data.reference.path);
            },
            icon: Icon(
              Icons.thumb_up,
              color: Color.fromRGBO(43, 158, 179, .6),
            ),
          ),
          IconButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              fire.addInteraction(
                  'dislike', widget.email, widget.data.reference.path);
            },
            icon: Icon(
              Icons.thumb_down,
              color: Color.fromRGBO(43, 158, 179, .6),
            ),
          ),
          IconButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              //showDeleteDialog();
            },
            icon: Icon(
              Icons.delete,
              color: Color.fromRGBO(43, 158, 179, .6),
            ),
          ),
        ],
        child: Row(
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
                  final model = ScopedModel.of<UserModel>(context);
                  HapticFeedback.lightImpact();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MessageDetailsDialog(
                          widget.data, model, widget.userMap);
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
                  duration: Duration(seconds: 1),
                  constraints: BoxConstraints(
                      minWidth: 20,
                      maxWidth: MediaQuery.of(context).size.width * .6),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: widget.data['readBy'].length > 1
                        ? Color.fromRGBO(43, 158, 179, 1)
                        : Color.fromRGBO(43, 158, 179, .6),
                  ),
                  child: Text(
                    widget.data['content'],
                    style: TextStyle(fontSize: 25, color: Colors.grey[100]),
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
      return Container();
    }
  }
}
