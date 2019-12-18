import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_with_firebase/dateTimeFormat.dart';
import 'package:flutter_with_firebase/firestoreMain.dart';
import 'deleteDialogConfirmation.dart';

class GeneralMessageWithInteractionsForCurrentUser extends StatefulWidget {
  final String text;
  final String time;
  final String email;
  final bool isLast;
  final String readDelivered;
  final List<dynamic> interactions;
  final String docID;

  GeneralMessageWithInteractionsForCurrentUser(
    this.text,
    this.time,
    this.interactions,
    this.email,
    this.isLast,
    this.readDelivered,
    this.docID,
  );
  @override
  _GeneralMessageWithInteractionsForCurrentUserState createState() =>
      _GeneralMessageWithInteractionsForCurrentUserState();
}

class _GeneralMessageWithInteractionsForCurrentUserState
    extends State<GeneralMessageWithInteractionsForCurrentUser>
    with SingleTickerProviderStateMixin {
  FirestoreMain fire = new FirestoreMain();
  DateTimeFormat dateTimeFormat = new DateTimeFormat();
  bool showTime = false;
  Color textBackgroundColor = Color.fromRGBO(43, 158, 179, 1);
  GlobalKey<State> extentChange = new GlobalKey<State>();
  Color notifBackColor = Colors.red[300];
  Color notifTextColor = Color.fromRGBO(43, 158, 179, 1);
  Widget profileImage = Text('Something went wong');

  @override
  void initState() {
    super.initState();
    profileImage = fire.getUserProfileImage(widget.email);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double maxExtent = .1;
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: maxExtent,
      actions: makeInteractionItemList(widget.interactions).length > 8
          ? makeInteractionItemList(widget.interactions).sublist(0, 9)
          : makeInteractionItemList(widget.interactions),
      secondaryActions: <Widget>[
        IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            fire.addInteraction(
                'favorite', widget.email, widget.docID, widget.time);
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
                'like', widget.email, widget.docID, widget.time);
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
                'dislike', widget.email, widget.docID, widget.time);
          },
          icon: Icon(
            Icons.thumb_down,
            color: Color.fromRGBO(43, 158, 179, .6),
          ),
        ),
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
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              messageCharacteristics(widget.text, widget.time, widget.isLast,
                  widget.readDelivered, showTime),
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
        return DeleteDialog(widget.email, widget.docID, widget.time);
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
          '(' + (notif - 1).toString() + ')',
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
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          widget.interactions.length < 2
              ? Container()
              : showNotification(widget.interactions.length),
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            constraints: BoxConstraints(
                minWidth: 20, maxWidth: MediaQuery.of(context).size.width * .7),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[400],
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
          fire.getUserProfileImage(widget.email),
        ],
      ),
    );
  }

  Widget textMessageAndReadRecipt(Color messageColor, Color messageBorder,
      Color textColor, String text, String readDelivered) {
    return GestureDetector(
      onTap: () {
        setState(
          () {
            showTime = !showTime;
          },
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              widget.interactions.length < 2
                  ? Container()
                  : showNotification(widget.interactions.length),
              AnimatedContainer(
                duration: Duration(milliseconds: 400),
                constraints: BoxConstraints(
                    minWidth: 20,
                    maxWidth: MediaQuery.of(context).size.width * .7),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[400],
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
              fire.getUserProfileImage(widget.email),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 10, top: 3),
            child: Text(
              readDelivered,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Garamond',
                  color: Color.fromRGBO(43, 158, 179, 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget messageCharacteristics(String text, String time, bool isLast,
      String readDelivered, bool shouldShow) {
    if (!isLast) {
      if (shouldShow) {
        return textMessageWithoutReadRecipt(
          Color.fromRGBO(43, 158, 179, 1),
          Colors.teal[700],
          Colors.grey[100],
          'Sent: ' +
              dateTimeFormat.getDisplayDateText(
                  DateTime.parse(time), DateTime.now()),
        );
      } else {
        return textMessageWithoutReadRecipt(Color.fromRGBO(43, 158, 179, 1),
            Color.fromRGBO(43, 158, 179, 1), Colors.grey[100], text);
      }
    } else {
      if (shouldShow) {
        return textMessageAndReadRecipt(
          Color.fromRGBO(43, 158, 179, 1),
          Colors.teal[700],
          Colors.grey[100],
          'Sent: ' +
              dateTimeFormat.getDisplayDateText(
                  DateTime.parse(time), DateTime.now()),
          readDelivered,
        );
      } else {
        return textMessageAndReadRecipt(
            Color.fromRGBO(43, 158, 179, 1),
            Color.fromRGBO(43, 158, 179, 1),
            Colors.grey[100],
            text,
            readDelivered);
      }
    }
  }

  List<Widget> makeInteractionItemList(List<dynamic> inter) {
    List<Widget> all = new List<Widget>();
    Icon icon = Icon(Icons.favorite);

    for (int i = 1; i < inter.length; i++) {
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
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: fire.getUserProfileImage(widget.email),
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
