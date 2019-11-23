import 'package:flutter/material.dart';
import 'login.dart';
import 'homepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    new MediaQuery(
      data: new MediaQueryData(),
      child: new MaterialApp(
        home: Login(),
      ),
    ),
  );
}
