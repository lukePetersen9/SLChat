import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'dart:async';

class Login extends StatelessWidget {
  String uname = "";
  String pwd = "";
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    TextEditingController uNameController = new TextEditingController();
    TextEditingController pwdController = new TextEditingController();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String uname = uNameController.text;
    String pwd = pwdController.text;
    return Scaffold(
      body: SingleChildScrollView(
        // physics: ClampingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: width / 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // Where the linear gradient begins and ends
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              // Add one stop for each color. Stops should increase from 0 to 1
              stops: [0.1, 0.2, 0.3, 0.4, .5, .6, .7, .8, .9],
              colors: [
                // Colors are easy thanks to Flutter's Colors class.

                Colors.amber[300],
                Colors.amber[200],
                Colors.amber[100],
                Colors.amber[50],
                Colors.blue[50],
                Colors.blue[100],
                Colors.blue[200],
                Colors.blue[300],
                Colors.blue[300],
              ],
            ),
          ),
          child: Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                flex: 15,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: height / 3.8,
                    child: Image.asset('images/elephant.png'),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Welcome!',
                    style:
                        TextStyle(fontSize: height / 14, color: Colors.black45),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '  Login to start using this exclusive service',
                    style:
                        TextStyle(fontSize: height / 40, color: Colors.black45),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    height: height / 15,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(height / 40),
                    ),
                    child: TextField(
                      controller: uNameController,
                      onChanged: (text) {
                        uname = uNameController.text;
                      },
                      cursorColor: Colors.grey[50],
                      style: TextStyle(
                          fontSize: height / 31, color: Colors.black45),
                      decoration: InputDecoration.collapsed(
                        hintText: 'email',
                        hintStyle: TextStyle(
                            fontSize: height / 31, color: Colors.black26),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    height: height / 15,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(height / 40),
                    ),
                    child: TextField(
                      controller: pwdController,
                      onChanged: (text) {
                        pwd = pwdController.text;
                      },
                      cursorColor: Colors.grey[50],
                      style: TextStyle(
                          fontSize: height / 31, color: Colors.black45),
                      obscureText: true,
                      decoration: InputDecoration.collapsed(
                        hintText: 'password',
                        hintStyle: TextStyle(
                            fontSize: height / 31, color: Colors.black26),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Align(
                  alignment: Alignment.center,
                  child: FlatButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Container(
                      child: Text(
                        'Login',
                        style: TextStyle(
                            fontSize: width / 13, color: Colors.white60),
                      ),
                    ),
                    onPressed: () {
                      
                      signIn(context, uNameController.text, pwdController.text);
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(),
              )
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.

      //dataBaseReference.collection('users').document(tE.text).get()
    );
  }

  Future<void> signIn(BuildContext context, String username, String password) async {
   if(username == null)
   {
     username = '';
   }
   if(password == null)
   {
     password = '';
   }
   try{
   AuthResult result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: username + "@slchat.com", password: password);
        FirebaseUser user = result.user;

        if(user != null && await user.getIdToken() != null)
        {
          Navigator.push(context,MaterialPageRoute(builder: (context) => HomePage(username)));
        }        
   }
   catch(e)
   {
     print('Error: $e');
   }
        
  }

  // bool checkPassword(String pwd)
  // {
  //   bool correctPassword = true;
  //   if(pwd != )
  //   {

  //   }
  //   return correctPassword;
  // }
}
