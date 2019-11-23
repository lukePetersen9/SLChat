import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class GeneralMessageWithInteractionsForOtherUser extends StatefulWidget {
  final String text;
  final String username;
  final String time;
  final String userProfileImage;
  final bool isLast;
  final String readDelivered;
  final Map<String, String> interactions;

  GeneralMessageWithInteractionsForOtherUser(
    this.text,
    this.username,
    this.time,
    this.interactions,
    this.userProfileImage,
    this.isLast,
    this.readDelivered,
  );
  @override
  _GeneralMessageWithInteractionsForOtherUserState createState() =>
      _GeneralMessageWithInteractionsForOtherUserState();
}

class _GeneralMessageWithInteractionsForOtherUserState
    extends State<GeneralMessageWithInteractionsForOtherUser>
    with SingleTickerProviderStateMixin {
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
      actions: makeInteractionItemList(widget.interactions).length > 8
          ? makeInteractionItemList(widget.interactions).sublist(0, 9)
          : makeInteractionItemList(widget.interactions),
      secondaryActions: <Widget>[
        IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () {},
          icon: Icon(
            Icons.favorite,
            color: Colors.white70,
          ),
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () {},
          icon: Icon(
            Icons.thumb_up,
            color: Colors.white70,
          ),
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () {},
          icon: Icon(
            Icons.thumb_down,
            color: Colors.white70,
          ),
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () {},
          icon: Icon(
            Icons.delete,
            color: Colors.white70,
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
              messageCharacteristics(widget.text, widget.username, widget.time,
                  widget.isLast, widget.readDelivered, showTime),
            ],
          ),
        ),
      ),
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
          '(' + notif.toString() + ')',
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
          profileImage(widget.userProfileImage),
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            constraints: BoxConstraints(
                minWidth: 20, maxWidth: MediaQuery.of(context).size.width * .7),
            decoration: BoxDecoration(
              border: Border.all(color: messageBorder),
              borderRadius: BorderRadius.circular(10),
              color: messageColor,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 22, fontFamily: 'Garamond', color: textColor),
            ),
          ),
          widget.interactions.length == 0
              ? Container()
              : showNotification(widget.interactions.length),
        ],
      ),
    );
  }

  Widget messageCharacteristics(String text, String username, String time,
      bool isLast, String readDelivered, bool shouldShow) {
    if (shouldShow) {
      return textMessageWithoutReadRecipt(
        Colors.transparent,
        Colors.amber[300],
        Colors.white70,
        'Sent: ' + getDisplayDateText(DateTime.parse(time), DateTime.now()),
      );
    } else {
      return textMessageWithoutReadRecipt(
          Colors.amber[300], Colors.amber[300], Colors.grey[850], text);
    }
  }
}

List<Widget> makeInteractionItemList(Map<String, String> inter) {
  List<Widget> all = new List<Widget>();
  Icon icon = Icon(Icons.favorite);
  inter.forEach(
    (String key, String value) {
      switch (value) {
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
          ;
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
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(key),
                    radius: 15,
                  ),
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
    },
  );
  if (all.length > 7) {
    all.insert(
      8,
      Icon(Icons.more_horiz),
    );
  }
  return all;
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

Widget profileImage(String url) {
  return Padding(
    padding: EdgeInsets.only(left: 7, right: 10),
    child: Container(
      child: CircleAvatar(
        radius: 15,
        backgroundImage: NetworkImage(url),
      ),
    ),
  );
}
