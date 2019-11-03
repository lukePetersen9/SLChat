import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String uname = "";
    String pwd = "";
    TextEditingController tE = new TextEditingController();
    final dataBaseReference = Firestore.instance;
    return Scaffold(
        body: Container(
          child: Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                  child: Image.network(
                      'http://drawdoo.com/wp-content/themes/blogfolio/themify/img.php?src=http://drawdoo.com/wp-content/uploads/tutorials/Geometric%20Animals/lesson13/step_00.png&w=665&h=&zc=1&q=60&a=t')),
              Expanded(
                child: Container(
                  child: TextField(
                    controller: tE,
                    onChanged: (text) {
                      uname = text;
                    },
                    decoration: InputDecoration.collapsed(
                      hintText: 'username',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: TextField(
                    obscureText: true,
                    onChanged: (text) {
                      pwd = text;
                    },
                    decoration: InputDecoration.collapsed(
                      hintText: 'password',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {

          //dataBaseReference.collection('users').document(tE.text).get()
          if ((uname == 'lukePetersen19' && pwd == '1234') ||
              (uname == 'shubham24' && pwd == 'qwerty')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
          else
          {
            
          }
        }));
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
