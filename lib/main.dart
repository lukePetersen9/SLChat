import 'package:flutter/material.dart';
import 'LoginAndSignup/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    new MediaQuery(
      data: new MediaQueryData(),
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Login(),
      ),
    ),
  );
}
