import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:simple_animations/simple_animations.dart';
import 'Animation/FadeAnimation.dart';
import 'login.dart';

class Signup extends StatelessWidget {
  final databaseReference = Firestore.instance;
  String uname = "";
  String pwd = "";
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
                    image: AssetImage('images/th.png'),
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
                                  color: Color.fromRGBO(205, 98, 64, .3),
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
                                      hintText: "First Name",
                                      hintStyle: TextStyle(color: Colors.grey)),
                                  onChanged: (text) {},
                                ),
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
                                      hintText: "Last Name",
                                      hintStyle: TextStyle(color: Colors.grey)),
                                  onChanged: (text) {},
                                ),
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
                                      hintStyle: TextStyle(color: Colors.grey)),
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
                                            color: Colors.grey[200]))),
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Password",
                                      hintStyle: TextStyle(color: Colors.grey)),
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
                                      hintText: "Confirm Password",
                                      hintStyle: TextStyle(color: Colors.grey)),
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
                                color: Color.fromRGBO(205, 98, 64, 1),
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
                                onPressed: () {},
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

      // physics: ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
    ));
  }
}
