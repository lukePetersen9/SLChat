import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/signup.dart';
import 'homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:simple_animations/simple_animations.dart';
import 'Animation/FadeAnimation.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class Login extends StatelessWidget {
  final databaseReference = Firestore.instance;
  String uname = "";
  String pwd = "";
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return StyledToast(
        textStyle: TextStyle(fontSize: 16.0, color: Colors.black),
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        textPadding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 10.0),
        toastAnimation: StyledToastAnimation.slideFromTopFade,
        reverseAnimation: StyledToastAnimation.fade,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastLinearToSlowEaseIn,
        dismissOtherOnShow: true,
        movingOnWindowChange: true,
        toastPositions: StyledToastPosition.top,
        child: Scaffold(
            body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FadeAnimation(
                1,
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(60)),
                      image: DecorationImage(
                        image: AssetImage('images/low-poly-elephant.png'),
                        fit: BoxFit.fill,
                      )),
                ),
              ),
              SizedBox(height: 20),
              FadeAnimation(
                  1.5,
                  Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(148, 104, 244, .3),
                                      blurRadius: 5,
                                      offset: Offset(0, 5),
                                    )
                                  ]),
                              child: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(),
                                        child: Text(
                                          'Welcome!',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 45,
                                          ),
                                        )),
                                  ),
                                  Container(
                                    height: 50,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[200]))),
                                    child: TextField(
                                      decoration: InputDecoration.collapsed(
                                          border: InputBorder.none,
                                          hintText: "Username",
                                          hintStyle:
                                              TextStyle(color: Colors.grey)),
                                      onChanged: (text) {
                                        uname = text;
                                      },
                                    ),
                                  ),
                                  Container(
                                    height: 50,
                                    padding: EdgeInsets.all(10),
                                    child: TextField(
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Password",
                                          hintStyle:
                                              TextStyle(color: Colors.grey)),
                                      onChanged: (text) {
                                        pwd = text;
                                      },
                                      obscureText: true,
                                    ),
                                  )
                                ],
                              )),
                          SizedBox(height: 25),
                          FadeAnimation(
                              2.0,
                              Container(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: RaisedButton(
                                    color: Color.fromRGBO(148, 104, 244, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Container(
                                      height: 50,
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Login',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25,
                                            ),
                                          )),
                                    ),
                                    onPressed: () {
                                      signIn(context, uname, pwd);
                                    },
                                  ),
                                ),
                              )),
                          SizedBox(height: 5),
                          FadeAnimation(
                              2.5,
                              Container(
                                  child: FlatButton(
                                child: Text(
                                  'Create a new Account',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return Signup();
                                    }),
                                  );
                                },
                              ))),
                        ],
                      )))
            ],
          ),

          // physics: ClampingScrollPhysics(),
          scrollDirection: Axis.vertical,
        )));
  }

  Future<void> signIn(
      BuildContext context, String username, String password) async {
    if (username == null) {
      username = '';
    }
    if (password == null) {
      password = '';
    }
    try {
      String email = username + '@slchat.com';
      print(email);
      AuthResult result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      if (user != null && await user.getIdToken() != null) {
        // createRecord(username, password);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return HomePage(
                  username,
                  username == 'lukepetersen29'
                      ? 'shubham24'
                      : 'lukepetersen29');
            },
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      showToast("Wrong Username/Password =(");
    }
  }

  void createRecord(String username, String password) async {
    await databaseReference.collection('users').document(username).setData(
      {
        'name': username,
        'password': password,
        'username': username,
        'profile_image':
            'https://i.pinimg.com/236x/10/ae/df/10aedff18fca7367122784b4453c86bb--geometric-art-geometric-patterns.jpg'
      },
    );
  }

// Container(
//                 width: width,
//                 height: height,
//                 padding: EdgeInsets.symmetric(horizontal: width / 20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     // Where the linear gradient begins and ends
//                     begin: Alignment.topRight,
//                     end: Alignment.bottomLeft,
//                     // Add one stop for each color. Stops should increase from 0 to 1
//                     stops: [0.1, 0.2, 0.3, 0.4, .5, .6, .7, .8, .9],
//                     colors: [
//                       // Colors are easy thanks to Flutter's Colors class.

//                       Colors.amber[300],
//                       Colors.amber[200],
//                       Colors.amber[100],
//                       Colors.amber[50],
//                       Colors.blue[50],
//                       Colors.blue[100],
//                       Colors.blue[200],
//                       Colors.blue[300],
//                       Colors.blue[300],
//                     ],
//                   ),
//                 ),
//                 child: Flex(
//                   direction: Axis.vertical,
//                   children: <Widget>[
//                     Expanded(
//                       flex: 3,
//                       child: Align(
//                         alignment: Alignment.bottomLeft,
//                         child: Text(
//                           'Welcome!',
//                           style: TextStyle(
//                               fontSize: height / 14, color: Colors.black45),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 2,
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Login to start using this exclusive service',
//                           style: TextStyle(
//                               fontSize: height / 45, color: Colors.black45),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 4,
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Container(
//                           alignment: Alignment.centerLeft,
//                           padding: EdgeInsets.symmetric(horizontal: 8),
//                           height: height / 15,
//                           decoration: BoxDecoration(
//                             color: Colors.white24,
//                             borderRadius: BorderRadius.circular(height / 40),
//                           ),
//                           child: TextField(
//                             //controller: uNameController,
//                             onChanged: (text) {
//                               uname = text;
//                             },
//                             cursorColor: Colors.grey[50],
//                             style: TextStyle(
//                                 fontSize: height / 31, color: Colors.black45),
//                             decoration: InputDecoration.collapsed(
//                               hintText: 'email',
//                               hintStyle: TextStyle(
//                                   fontSize: height / 31, color: Colors.black26),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 3,
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Container(
//                           alignment: Alignment.centerLeft,
//                           padding: EdgeInsets.symmetric(horizontal: 8),
//                           height: height / 15,
//                           decoration: BoxDecoration(
//                             color: Colors.white24,
//                             borderRadius: BorderRadius.circular(height / 40),
//                           ),
//                           child: TextField(
//                             onChanged: (text) {
//                               pwd = text;
//                             },
//                             cursorColor: Colors.grey[50],
//                             style: TextStyle(
//                                 fontSize: height / 31, color: Colors.black45),
//                             obscureText: true,
//                             decoration: InputDecoration.collapsed(
//                               hintText: 'password',
//                               hintStyle: TextStyle(
//                                   fontSize: height / 31, color: Colors.black26),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 6,
//                       child: Align(
//                         alignment: Alignment.center,
//                         child: FlatButton(
//                           highlightColor: Colors.transparent,
//                           splashColor: Colors.transparent,
//                           child: Container(
//                             child: Text(
//                               'Login',
//                               style: TextStyle(
//                                   fontSize: width / 13, color: Colors.white60),
//                             ),
//                           ),
//                           onPressed: () {
//                             signIn(context, uname, pwd);
//                           },
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 8,
//                       child: Container(),
//                     )
//                   ],
//                 ),
//               )

}
