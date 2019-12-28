import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends Model {
  String lastName, profileImage, username;
  String firstName = 'dsjfklsdjfklsdjf';
  String bio = 'Default Bio (From UserModel)';
  String email = 'email';
  var followers, following;
  bool isPrivate;
  UserModel(String e) {
    print('Getting data from firestore for ' + e);
    Firestore.instance
        .collection('users')
        .where('email', isEqualTo: e)
        .snapshots()
        .listen((data) {
      bio = data.documents[0]['bio'];
      email = e;
      firstName = data.documents[0]['firstName'];
      lastName = data.documents[0]['lastName'];
      notifyListeners();
    });
  }
}
