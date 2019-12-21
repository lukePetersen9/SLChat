import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/Firestore/firestoreMain.dart';

class DeleteDialog extends StatefulWidget {
  final String userEmail;
  final String docID;
  final String time;

  DeleteDialog(this.userEmail, this.docID, this.time);
  @override
  State<StatefulWidget> createState() {
    return DeleteDialogState();
  }
}

class DeleteDialogState extends State<DeleteDialog> {
  FirestoreMain fire = new FirestoreMain();
  final databaseReference = Firestore.instance;
  String searchText = "";
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
        'This action is permanent and cannot be undone',
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
            'Delete',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Garamond',
              color: Color.fromRGBO(43, 158, 179, .8),
            ),
          ),
          onPressed: () {
            fire.addInteraction(
                'delete', widget.userEmail, widget.docID, widget.time);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
