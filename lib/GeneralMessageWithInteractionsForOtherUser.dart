import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_with_firebase/dateTimeFormat.dart';
import 'package:flutter_with_firebase/firestoreMain.dart';
import 'deleteDialogConfirmation.dart';

class GeneralMessageWithInteractionsForOtherUser extends StatefulWidget {
  final String text;
  final String email;
  final String loggedInUser;
  final String time;
  final List<dynamic> interactions;
  final String docID;

  GeneralMessageWithInteractionsForOtherUser(
    this.text,
    this.email,
    this.loggedInUser,
    this.time,
    this.interactions,
    this.docID,
  );
  @override
  _GeneralMessageWithInteractionsForOtherUserState createState() =>
      _GeneralMessageWithInteractionsForOtherUserState();
}

class _GeneralMessageWithInteractionsForOtherUserState
    extends State<GeneralMessageWithInteractionsForOtherUser>
    with SingleTickerProviderStateMixin {
  FirestoreMain fire = new FirestoreMain();
  DateTimeFormat dateTimeFormat = new DateTimeFormat();
  bool showTime = false;
  Color textBackgroundColor = Colors.amber[300];
  GlobalKey<State> extentChange = new GlobalKey<State>();
  Color notifBackColor = Colors.white38;
  Color notifTextColor = Colors.grey[850];

  @override
  Widget build(BuildContext context) {
    double maxExtent = .1;
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: maxExtent,
      secondaryActions: makeInteractionItemList(widget.interactions).length > 8
          ? makeInteractionItemList(widget.interactions).sublist(0, 9)
          : makeInteractionItemList(widget.interactions),
      actions: <Widget>[
        IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            fire.addInteraction(
                'favorite', widget.loggedInUser, widget.docID, widget.time);
          },
          icon: Icon(
            Icons.favorite,
            color: Colors.black38,
          ),
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            fire.addInteraction(
                'like', widget.loggedInUser, widget.docID, widget.time);
          },
          icon: Icon(
            Icons.thumb_up,
            color: Colors.black38,
          ),
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            fire.addInteraction(
                'dislike', widget.loggedInUser, widget.docID, widget.time);
          },
          icon: Icon(
            Icons.thumb_down,
            color: Colors.black38,
          ),
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            showDeleteDialog();
          },
          icon: Icon(
            Icons.delete,
            color: Colors.black38,
          ),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              messageCharacteristics(widget.text, widget.time, showTime),
            ],
          ),
        ),
      ),
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(widget.loggedInUser, widget.docID, widget.time);
      },
    );
  }

  Widget showNotification(int notif) {
    return Padding(
      padding: EdgeInsets.only(right: 5),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 50),
        alignment: Alignment.center,
        padding: EdgeInsets.all(0),
        width: 20,
        height: 20,
        child: Text(
          '(' + (notif-1).toString() + ')',
          style: TextStyle(
              fontSize: 15, fontFamily: 'Garamond', color: notifTextColor),
        ),
      ),
    );
  }

  Widget textMessageWithoutReadRecipt(
      Color messageColor, Color messageBorder, Color textColor, String text) {
    return GestureDetector(
      onTap: () {
        setState(
          () {
            showTime = !showTime;
          },
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          fire.getUserProfileImage(widget.email,15),
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            constraints: BoxConstraints(
                minWidth: 20, maxWidth: MediaQuery.of(context).size.width * .7),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[350],
                  blurRadius: 5,
                  offset: Offset(0, 5),
                )
              ],
              border: Border.all(color: messageBorder),
              borderRadius: BorderRadius.circular(25),
              color: messageColor,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 22, fontFamily: 'Garamond', color: textColor),
            ),
          ),
          widget.interactions.length <2
              ? Container()
              : showNotification(widget.interactions.length),
        ],
      ),
    );
  }

  Widget messageCharacteristics(String text, String time, bool shouldShow) {
    if (shouldShow) {
      return textMessageWithoutReadRecipt(
        Colors.blueGrey[50],
        Colors.blueGrey[800],
        Colors.grey[150],
        'Sent: ' +
            dateTimeFormat.getDisplayDateText(
                DateTime.parse(time), DateTime.now()),
      );
    } else {
      return textMessageWithoutReadRecipt(
          Colors.blueGrey[50], Colors.blueGrey[50], Colors.grey[850], text);
    }
  }

  List<Widget> makeInteractionItemList(List<dynamic> inter) {
    List<Widget> all = new List<Widget>();
    Icon icon = Icon(Icons.favorite);
    for (int i = 1; i < inter.length; i++) {
      String e = inter[i]
          .toString()
          .substring(0, inter[i].toString().lastIndexOf('@'));
      String interaction = inter[i]
          .toString()
          .substring(inter[i].toString().lastIndexOf('@') + 1);
      switch (interaction) {
        case 'favorite':
          icon = Icon(
            Icons.favorite,
            color: Colors.red[300],
            size: 20,
          );
          break;
        case 'like':
          icon = Icon(
            Icons.thumb_up,
            color: Colors.green[300],
            size: 20,
          );
          break;
        case 'dislike':
          icon = Icon(
            Icons.thumb_down,
            color: Colors.red,
            size: 20,
          );
          break;
      }
      all.add(
        Container(
          height: 40,
          width: 40,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(0),
                  child: fire.getUserProfileImage(e,15),
                  width: 40,
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: icon,
              ),
            ],
          ),
        ),
      );
    }

    if (all.length > 7) {
      all.insert(
        8,
        Icon(Icons.more_horiz),
      );
    }
    return all;
  }
}
