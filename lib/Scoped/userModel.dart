import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends Model {
  String lastName, profileImage, username;
  String firstName = 'dsjfklsdjfklsdjf';
  String bio = 'Default Bio (From UserModel)';
  var followers, following;
  bool isPrivate;
  UserModel(String email) {
    print('Getting data from firestore');
    Firestore.instance.collection('users').where('email', isEqualTo: email).snapshots().listen((data) {
      bio = data.documents[0]['bio'];
      firstName = data.documents[0]['firstName'];
      lastName = data.documents[0]['lastName'];
      notifyListeners();
    } );
  }
}
