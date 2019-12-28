import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/Homepage/homepage.dart';
import 'package:flutter_with_firebase/SideDrawerItems/homepageDrawer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'LoginAndSignup/login.dart';
import 'Scoped/userModel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // static final UserModel model = UserModel('l@p.com');
  // final routes = <String, WidgetBuilder>{
  //   HomePage.route: (BuildContext context) => HomePage('l@p.com', model),
  //   HomepageDrawer.route: (BuildContext context) => HomepageDrawer('l@p.com')
  // };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scoped Model MultiPage Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login(),
      // routes: routes,

      // home: DefaultTabController(
      //   length: 2,
      //   child: ScopedModel<AppModel>(
      //     model: AppModel(),
      //     child: Scaffold(
      //       appBar: AppBar(
      //         title: Text('Scoped Model Demo'),
      //         bottom: TabBar(
      //           tabs: <Widget>[
      //             Tab(
      //               icon: Icon(Icons.home),
      //               text: 'Home Page',
      //             ),
      //             Tab(
      //               icon: Icon(Icons.screen_rotation),
      //               text: 'Display',
      //             )
      //           ],
      //         ),
      //       ),
      //       body: TabBarView(
      //         children: <Widget>[
      //           HomePage(),
      //           DisplayPage(),
      //         ],
      //       ),
      //     ),
      //   ),
      // )
    );
  }
}

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(
//     new MediaQuery(
//       data: new MediaQueryData(),
//       child: new MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: Login(),
//       ),
//     ),
//   );
// }
