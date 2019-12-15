import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/signup.dart';
import 'homePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:simple_animations/simple_animations.dart';
import 'Animation/FadeAnimation.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;
  String email = "";
  String pwd = "";
  @override
  void initState() {
    super.initState();
    getUser().then((user) {
      if (user != null) {
      //  print(user.email);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return HomePage(user.email);
            },
          ),
        );
      }
    });
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

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
                        fit: BoxFit.cover,
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
                            height: 300,
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
                            child: Flex(
                              direction: Axis.vertical,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(),
                                    child: Text(
                                      'Welcome!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 45,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[200]))),
                                    child: TextField(
                                      decoration: InputDecoration.collapsed(
                                          border: InputBorder.none,
                                          hintText: 'Email',
                                          hintStyle:
                                              TextStyle(color: Colors.grey)),
                                      onChanged: (text) {
                                        email = text;
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.all(10),
                                    child: TextField(
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Password',
                                          hintStyle:
                                              TextStyle(color: Colors.grey)),
                                      onChanged: (text) {
                                        pwd = text;
                                      },
                                      obscureText: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                      signIn(context, email, pwd);
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
          scrollDirection: Axis.vertical,
        ),
      ),
    );
  }

  Future<void> signIn(
      BuildContext context, String email, String password) async {
    if (email == null) {
      email = '';
    }
    if (password == null) {
      password = '';
    }
    try {
      AuthResult result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      if (user != null && await user.getIdToken() != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return HomePage(user.email);
            },
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      print(e.toString());
      if (email == '' && password == '') {
        showToast("Email and Password field are empty");
      } else if (password == '') {
        showToast("Please Input A Password");
      } else if (email == '') {
        showToast("Please Input An email");
      } else if (e.toString() ==
          'PlatformException(ERROR_USER_NOT_FOUND, There is no user record corresponding to this identifier. The user may have been deleted., null)') {
        showToast("User not found");
      } else if (e.toString() ==
          'PlatformException(ERROR_WRONG_PASSWORD, The password is invalid or the user does not have a password., null)') {
        showToast("Incorrect Password");
      } else if (e.toString() ==
          'PlatformException(ERROR_TOO_MANY_REQUESTS, We have blocked all requests from this device due to unusual activity. Try again later. [ Too many unsuccessful login attempts.  Please include reCaptcha verification or try again later ], null)') {
        showToast("Too many incorrect attempts! Try again later");
      }
    }
  }
}
