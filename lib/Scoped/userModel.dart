import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends Model {
  String lastName, username;
  String firstName = 'dsjfklsdjfklsdjf';
  String bio = 'Default Bio (From UserModel)';
  String profileImage = 'https://previews.123rf.com/images/salamatik/salamatik1801/salamatik180100019/92979836-profile-anonymous-face-icon-gray-silhouette-person-male-default-avatar-photo-placeholder-isolated-on.jpg';
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
      followers = data.documents[0]['followers'];
      following = data.documents[0]['following'];
      isPrivate = data.documents[0]['isPrivate'];
      lastName = data.documents[0]['lastName'];
      profileImage = data.documents[0]['profile_image'];
      username = data.documents[0]['username'];
      notifyListeners();
    });
  }
  static of (BuildContext context){
    return ScopedModel.of<UserModel>(context);
  }
}
