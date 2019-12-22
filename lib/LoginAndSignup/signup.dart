import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/Firestore/firestoreMain.dart';
import 'package:flutter_with_firebase/Homepage/homepage.dart';
import 'package:flutter_with_firebase/Animation/FadeAnimation.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignupState();
}

class SignupState extends State<Signup> {
  FirestoreMain fire = new FirestoreMain();
  String uname = '';
  String pwd = '';
  String first = '';
  String last = '';
  String email = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FadeAnimation(
              1,
              Container(
                height: 205,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(60)),
                    image: DecorationImage(
                      image: AssetImage('images/wp1902577.png'),
                      fit: BoxFit.fill,
                    )),
              ),
            ),
            SizedBox(height: 10),
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
                                    color: Color.fromRGBO(68, 187, 0, .3),
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
                                        'Join Us!',
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
                                        hintText: 'First Name',
                                        hintStyle:
                                            TextStyle(color: Colors.grey)),
                                    onChanged: (text) {
                                      first = text;
                                    },
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[200],
                                      ),
                                    ),
                                  ),
                                  child: TextField(
                                    decoration: InputDecoration.collapsed(
                                        border: InputBorder.none,
                                        hintText: 'Last Name',
                                        hintStyle:
                                            TextStyle(color: Colors.grey)),
                                    onChanged: (text) {
                                      last = text;
                                    },
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[200],
                                      ),
                                    ),
                                  ),
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
                                Container(
                                  height: 50,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[200],
                                      ),
                                    ),
                                  ),
                                  child: TextField(
                                    decoration: InputDecoration.collapsed(
                                        border: InputBorder.none,
                                        hintText: 'Username',
                                        hintStyle:
                                            TextStyle(color: Colors.grey)),
                                    onChanged: (text) {
                                      uname = text;
                                    },
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[200],
                                      ),
                                    ),
                                  ),
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
                                Container(
                                  height: 50,
                                  padding: EdgeInsets.all(10),
                                  child: TextField(
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Confirm Password',
                                        hintStyle:
                                            TextStyle(color: Colors.grey)),
                                    onChanged: (text) {},
                                    obscureText: true,
                                  ),
                                )
                              ],
                            )),
                        SizedBox(height: 15),
                        FadeAnimation(
                            2.0,
                            Container(
                              child: Align(
                                alignment: Alignment.center,
                                child: RaisedButton(
                                  color: Color.fromRGBO(68, 187, 0, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Container(
                                    height: 50,
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        )),
                                  ),
                                  onPressed: () async {
                                    try {
                                      AuthResult result = await FirebaseAuth
                                          .instance
                                          .createUserWithEmailAndPassword(
                                              email: email, password: pwd);
                                      FirebaseUser user = result.user;
                                      fire.createNewUser(
                                          email, uname, first, last);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return HomePage(user.email);
                                        }),
                                      );
                                    } catch (e) {
                                      print(e);
                                    }
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
                                'Nevermind',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return Login();
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
    );
  }
}
