import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/Firestore/firestoreMain.dart';
import 'package:flutter_with_firebase/Scoped/userModel.dart';
import 'package:flutter_with_firebase/User/profilepage.dart';
import 'package:scoped_model/scoped_model.dart';

class LeaveEditingProfilePageConfirmationDialog extends StatelessWidget {
  final String email;
  LeaveEditingProfilePageConfirmationDialog(this.email);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.grey[100],
        title: Text(
          'Are you sure?',
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'Garamond',
            color: Colors.black54,
          ),
        ),
        content: Text(
          'Any changes that you have made will not be saved.',
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'Garamond',
              color: Color.fromRGBO(43, 158, 179, 1)),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text(
              'Cancel',
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
          new FlatButton(
            child: new Text(
              'Discard Changes',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Garamond',
                color: Color.fromRGBO(43, 158, 179, .8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder:(context) => ProfilePage(email)));
            },
          ),
        ],
      );
  }
}
