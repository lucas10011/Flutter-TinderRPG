
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_isekai/inventario_pages/inventory.dart';
import 'package:my_isekai/login_page/login.dart';
import 'package:my_isekai/login_page/signup.page.dart';
import 'package:my_isekai/redirect.dart';
import 'package:my_isekai/services/state_widget.dart';



void main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  StateWidget stateWidget = new StateWidget(
    child: new MyApp(),
  );
  

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      runApp(stateWidget);
    });
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'MyIsekai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'SAO'),
      // home: HomePage(),
      routes: {
        '/': (context) => LandingPage(),
        '/signup': (context) => SignUpScreen(),
        '/sigin': (context) => LoginPage(),
        '/inventory': (context) => Inventory(),

      },
    );
  }
}






