import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                  decoration: InputDecoration.collapsed(
                    hintText: 'username',
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: TextField(
                  decoration: InputDecoration.collapsed(
                    hintText: 'password',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
